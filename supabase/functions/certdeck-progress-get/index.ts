// =============================================================================
// CertDeck — Edge Function: certdeck-progress-get
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Devuelve el ESTADO COMPLETO de progreso del usuario (ADR 0006), ensamblado a
// partir de sus tablas `certdeck_user_*` (RLS por auth.uid()). Es la única
// lectura de progreso: la app ya NO usa localStorage como fuente de verdad.
//
// Forma de respuesta (envoltorio { data }):
//   {
//     lessons: { [lessonId]: { status, scorePercentage, correctCount,
//                              incorrectCount, ankiCount, xp, completedAt } },
//     failedQuestions: { [questionId]: lessonId },
//     review: { xp, totalAnswers, correctAnswers, ankiCards },
//     activeDays: string[]  // YYYY-MM-DD (lecciones completadas ∪ repasos)
//   }
//
// Función NUEVA y autocontenida (Constitución §4): CORS propio. NO desplegada
// por el agente.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** YYYY-MM-DD en UTC a partir de un timestamptz. */
function dayOf(ts: string | null): string | null {
  return ts ? ts.slice(0, 10) : null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  // Las tres lecturas en paralelo (cada una filtrada por RLS al usuario).
  const [progressRes, reviewRes, failedRes] = await Promise.all([
    supabase
      .from("certdeck_user_lesson_progress")
      .select("lesson_id, status, score_percentage, correct_count, incorrect_count, anki_count, xp, completed_at"),
    supabase
      .from("certdeck_user_review_sessions")
      .select("xp, total_answers, correct_answers, anki_cards, created_at"),
    supabase
      .from("certdeck_user_failed_questions")
      .select("question_id, lesson_id"),
  ]);

  if (progressRes.error) return json({ error: "query_failed", detail: progressRes.error.message }, 500);
  if (reviewRes.error) return json({ error: "query_failed", detail: reviewRes.error.message }, 500);
  if (failedRes.error) return json({ error: "query_failed", detail: failedRes.error.message }, 500);

  const activeDays = new Set<string>();

  const lessons: Record<string, unknown> = {};
  for (const row of progressRes.data ?? []) {
    lessons[row.lesson_id] = {
      status: row.status,
      scorePercentage: row.score_percentage ?? 0,
      correctCount: row.correct_count ?? 0,
      incorrectCount: row.incorrect_count ?? 0,
      ankiCount: row.anki_count ?? 0,
      xp: row.xp ?? 0,
      completedAt: row.completed_at ?? null,
    };
    const day = dayOf(row.completed_at);
    if (row.status === "completed" && day) activeDays.add(day);
  }

  const review = { xp: 0, totalAnswers: 0, correctAnswers: 0, ankiCards: 0 };
  for (const row of reviewRes.data ?? []) {
    review.xp += row.xp ?? 0;
    review.totalAnswers += row.total_answers ?? 0;
    review.correctAnswers += row.correct_answers ?? 0;
    review.ankiCards += row.anki_cards ?? 0;
    const day = dayOf(row.created_at);
    if (day) activeDays.add(day);
  }

  const failedQuestions: Record<string, string | null> = {};
  for (const row of failedRes.data ?? []) {
    failedQuestions[row.question_id] = row.lesson_id ?? null;
  }

  return json({
    data: {
      lessons,
      failedQuestions,
      review,
      activeDays: [...activeDays].sort(),
    },
  });
});
