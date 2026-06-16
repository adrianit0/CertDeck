// =============================================================================
// CertDeck — Edge Function: certdeck-report-create
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Da de alta un REPORTE DE ERROR de una tarjeta (asistencia técnica). El cliente
// envía la pregunta reportada (id + origen), el motivo (combo) y un detalle
// libre opcional; la función inserta la fila en certdeck_user_question_reports
// como el usuario autenticado (RLS exige auth.uid() = user_id).
//
// Relacionado: ADR 0008, RF-30, script-007.sql.
//
// IMPORTANTE (Constitución §4): CORS propio. El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SOURCES = ["flashcard", "exam"];
const CATEGORIES = ["bug", "spelling", "wrong_answer", "confusing", "other"];
const MAX_DETAILS = 2000;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

interface ReportPayload {
  question_id?: string;
  question_source?: string;
  lesson_id?: string | null;
  course_id?: string | null;
  question_text?: string | null;
  category?: string;
  details?: string | null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  let payload: ReportPayload;
  try {
    payload = (await req.json()) as ReportPayload;
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const questionId = payload.question_id;
  const source = payload.question_source;
  const category = payload.category;

  // Validación de entrada (no se confía en el cliente).
  if (!questionId || typeof questionId !== "string") {
    return json({ error: "invalid_question_id" }, 400);
  }
  if (!source || !SOURCES.includes(source)) {
    return json({ error: "invalid_question_source" }, 400);
  }
  if (!category || !CATEGORIES.includes(category)) {
    return json({ error: "invalid_category" }, 400);
  }

  const details =
    typeof payload.details === "string" && payload.details.trim().length > 0
      ? payload.details.trim().slice(0, MAX_DETAILS)
      : null;
  const questionText =
    typeof payload.question_text === "string" && payload.question_text.length > 0
      ? payload.question_text.slice(0, 2000)
      : null;
  const lessonId = typeof payload.lesson_id === "string" ? payload.lesson_id : null;
  const courseId = typeof payload.course_id === "string" ? payload.course_id : null;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  const { data, error } = await supabase
    .from("certdeck_user_question_reports")
    .insert({
      user_id: userId,
      question_id: questionId,
      question_source: source,
      lesson_id: lessonId,
      course_id: courseId,
      question_text: questionText,
      category,
      details,
    })
    .select("id")
    .single();

  if (error) return json({ error: "persist_failed", detail: error.message }, 500);

  return json({ data: { ok: true, id: data.id } });
});
