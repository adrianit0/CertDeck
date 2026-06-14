// =============================================================================
// CertDeck — Edge Function: certdeck-progress-complete-lesson
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Persiste de forma AUTORITATIVA la finalización de una lección (ADR 0002):
//  - Verifica la sesión del usuario (JWT del header Authorization).
//  - Recalcula el score en servidor (no confía en el cliente).
//  - Hace upsert en certdeck_user_lesson_progress respetando RLS.
//
// IMPORTANTE (Constitución §4): es una función NUEVA. NO modifica ni comparte
// CORS con auth-login / auth-register; define su propio CORS.
//
// El agente NO la despliega. El propietario la despliega manualmente.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

interface CompleteLessonPayload {
  lesson_id?: string;
  correct_count?: number;
  incorrect_count?: number;
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

  // Score recalculado en servidor (no se confía en el cliente).
  const total = correct + incorrect;
  const score = total === 0 ? 100 : Math.round((correct / total) * 100);

  const { data, error } = await supabase
    .from("certdeck_user_lesson_progress")
    .upsert(
      {
        user_id: userData.user.id,
        lesson_id: lessonId,
        status: "completed",
        score_percentage: score,
        correct_count: correct,
        incorrect_count: incorrect,
        completed_at: new Date().toISOString(),
      },
      { onConflict: "user_id,lesson_id" },
    )
    .select()
    .single();

  if (error) return json({ error: "persist_failed", detail: error.message }, 500);

  return json({ ok: true, progress: data });
});
