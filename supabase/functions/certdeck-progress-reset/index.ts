// =============================================================================
// CertDeck — Edge Function: certdeck-progress-reset
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Borra TODO el progreso del usuario (ADR 0006): progreso de lecciones,
// sesiones de repaso, errores pendientes y sesiones de examen. Sustituye al `resetProgress()` que
// antes solo limpiaba localStorage. RLS garantiza que cada usuario solo borra
// sus propias filas.
//
// IMPORTANTE (Constitución §4): CORS propio. El agente NO la despliega.
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

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  // Borrado en las tablas de progreso (RLS limita a las filas propias).
  const results = await Promise.all([
    supabase.from("certdeck_user_lesson_progress").delete().eq("user_id", userId),
    supabase.from("certdeck_user_review_sessions").delete().eq("user_id", userId),
    supabase.from("certdeck_user_failed_questions").delete().eq("user_id", userId),
    supabase.from("certdeck_user_exam_sessions").delete().eq("user_id", userId),
  ]);

  const failed = results.find((r) => r.error);
  if (failed?.error) return json({ error: "reset_failed", detail: failed.error.message }, 500);

  return json({ data: { ok: true } });
});
