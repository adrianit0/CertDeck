// =============================================================================
// CertDeck — Edge Function: certdeck-progress-complete-lesson
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Persiste de forma AUTORITATIVA la finalización de una lección (ADR 0002/0006):
//  - Verifica la sesión del usuario (JWT del header Authorization).
//  - Recalcula en servidor el `score` y el `xp` (no confía en el cliente).
//  - Hace upsert en certdeck_user_lesson_progress (incl. xp y anki_count).
//  - Reconcilia certdeck_user_failed_questions: alta de los fallos de la sesión
//    y baja de las preguntas recuperadas. (ADR 0006)
//
// IMPORTANTE (Constitución §4): define su propio CORS. El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// XP autoritativo (réplica de app/lib/xp.ts, patrón RT-03): no depende del nº de
// preguntas. Base 50 + 1 por cada 2% de acierto (máx 100). Repetir una lección ya
// completada da el 20% (80% menos). El front NO puede inflar esta cantidad.
const XP_BASE = 50;
const XP_MAX = 100;
const XP_REPEAT_FACTOR = 0.2;

function sessionXp(scorePercentage: number, isRepeat: boolean): number {
  const s = Math.max(0, Math.min(100, Math.round(scorePercentage)));
  const full = Math.min(XP_MAX, XP_BASE + Math.floor(s / 2));
  return isRepeat ? Math.round(full * XP_REPEAT_FACTOR) : full;
}

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

interface CompleteLessonPayload {
  lesson_id?: string;
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

  let payload: CompleteLessonPayload;
  try {
    payload = (await req.json()) as CompleteLessonPayload;
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const lessonId = payload.lesson_id;
  const correct = Number(payload.correct_count ?? 0);
  const incorrect = Number(payload.incorrect_count ?? 0);
  const ankiCount = Math.max(0, Number(payload.anki_count ?? 0));

  if (!lessonId || typeof lessonId !== "string") return json({ error: "missing_lesson_id" }, 400);
  if (!Number.isFinite(correct) || !Number.isFinite(incorrect) || correct < 0 || incorrect < 0) {
    return json({ error: "invalid_counts" }, 400);
  }

  // Cliente con el JWT del usuario => RLS y auth.uid() activos.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  // ¿La lección ya estaba completada? → repetición (XP reducida). Se determina en
  // SERVIDOR consultando el estado previo; no se confía en una bandera del cliente.
  const { data: existing } = await supabase
    .from("certdeck_user_lesson_progress")
    .select("status, xp")
    .eq("user_id", userId)
    .eq("lesson_id", lessonId)
    .maybeSingle();
  const isRepeat = existing?.status === "completed";

  // Score y XP recalculados en servidor (no se confía en el cliente). En una
  // repetición, la XP reducida (20%) se ACUMULA sobre la ya obtenida para que
  // repetir nunca baje la XP total (ADR 0010).
  const total = correct + incorrect;
  const score = total === 0 ? 100 : Math.round((correct / total) * 100);
  const xp = isRepeat
    ? Number(existing?.xp ?? 0) + sessionXp(score, true)
    : sessionXp(score, false);

  const { data, error } = await supabase
    .from("certdeck_user_lesson_progress")
    .upsert(
      {
        user_id: userId,
        lesson_id: lessonId,
        status: "completed",
        score_percentage: score,
        correct_count: correct,
        incorrect_count: incorrect,
        anki_count: ankiCount,
        xp,
        completed_at: new Date().toISOString(),
      },
      { onConflict: "user_id,lesson_id" },
    )
    .select()
    .single();

  if (error) return json({ error: "persist_failed", detail: error.message }, 500);

  // --- Reconciliación de errores pendientes (best-effort, no bloquea el OK) ---
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

  return json({ data: { ok: true, progress: data } });
});
