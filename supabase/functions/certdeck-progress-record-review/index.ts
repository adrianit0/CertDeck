// =============================================================================
// CertDeck — Edge Function: certdeck-progress-record-review
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Persiste una SESIÓN DE REPASO (no atada a una lección) de forma autoritativa
// (ADR 0006): inserta una fila en certdeck_user_review_sessions con el XP
// recalculado en servidor y reconcilia certdeck_user_failed_questions (alta de
// fallos / baja de recuperados).
//
// IMPORTANTE (Constitución §4): CORS propio. El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// XP autoritativo de repaso (réplica de app/lib/xp.ts, RT-03): base 50 + 1 por
// cada 2% de acierto (máx 100), independiente del nº de preguntas. El front no la
// puede inflar. Un repaso cuenta como "una lección más".
const XP_BASE = 50;
const XP_MAX = 100;

function sessionXp(scorePercentage: number): number {
  const s = Math.max(0, Math.min(100, Math.round(scorePercentage)));
  return Math.min(XP_MAX, XP_BASE + Math.floor(s / 2));
}

const REVIEW_TYPES = ["topic-review", "general-review", "topic-errors", "general-errors"];

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

interface FailedRef {
  id?: string;
  lessonId?: string | null;
}

interface RecordReviewPayload {
  review_type?: string;
  correct_count?: number;
  incorrect_count?: number;
  anki_count?: number;
  failed_questions?: FailedRef[];
  passed_question_ids?: string[];
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  let payload: RecordReviewPayload;
  try {
    payload = (await req.json()) as RecordReviewPayload;
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const reviewType = payload.review_type;
  const correct = Number(payload.correct_count ?? 0);
  const incorrect = Number(payload.incorrect_count ?? 0);
  const ankiCount = Math.max(0, Number(payload.anki_count ?? 0));

  if (!reviewType || !REVIEW_TYPES.includes(reviewType)) {
    return json({ error: "invalid_review_type" }, 400);
  }
  if (!Number.isFinite(correct) || !Number.isFinite(incorrect) || correct < 0 || incorrect < 0) {
    return json({ error: "invalid_counts" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  // XP recalculado en servidor (no se confía en el cliente).
  const total = correct + incorrect;
  const score = total === 0 ? 100 : Math.round((correct / total) * 100);
  const xp = sessionXp(score);

  const { data, error } = await supabase
    .from("certdeck_user_review_sessions")
    .insert({
      user_id: userId,
      review_type: reviewType,
      xp,
      total_answers: correct + incorrect,
      correct_answers: correct,
      anki_cards: ankiCount,
    })
    .select()
    .single();

  if (error) return json({ error: "persist_failed", detail: error.message }, 500);

  // --- Reconciliación de errores pendientes (best-effort) ---
  const passedIds = (payload.passed_question_ids ?? []).filter(
    (id): id is string => typeof id === "string",
  );
  if (passedIds.length > 0) {
    await supabase
      .from("certdeck_user_failed_questions")
      .delete()
      .eq("user_id", userId)
      .in("question_id", passedIds);
  }

  const failedRows = (payload.failed_questions ?? [])
    .filter((q): q is { id: string; lessonId?: string | null } => typeof q?.id === "string")
    .map((q) => ({ user_id: userId, question_id: q.id, lesson_id: q.lessonId ?? null }));
  if (failedRows.length > 0) {
    await supabase
      .from("certdeck_user_failed_questions")
      .upsert(failedRows, { onConflict: "user_id,question_id" });
  }

  return json({ data: { ok: true, review: data } });
});
