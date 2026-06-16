// =============================================================================
// CertDeck — Edge Function: certdeck-content-version
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Devuelve un TOKEN de versión del CATÁLOGO de un curso (etapas + temas +
// lecciones). El cliente lo compara con el de su caché local y solo vuelve a
// descargar el contenido pesado si difiere (ADR 0009 · RNF-17). Llamada muy
// ligera: una sola RPC a certdeck_course_catalog_version (script-008.sql).
//
// Parámetros (query): `course_id` (obligatorio).
//
// Función NUEVA y autocontenida (Constitución §4). El agente NO la despliega.
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

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  const courseId = new URL(req.url).searchParams.get("course_id");
  if (!courseId) return json({ error: "missing_course_id" }, 400);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  const { data, error } = await supabase.rpc("certdeck_course_catalog_version", {
    p_course_id: courseId,
  });
  if (error) return json({ error: "query_failed", detail: error.message }, 500);

  return json({ data: { version: (data as string | null) ?? "0.0" } });
});
