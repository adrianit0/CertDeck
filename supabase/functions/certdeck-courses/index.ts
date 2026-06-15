// =============================================================================
// CertDeck — Edge Function: certdeck-courses
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso CURSOS (solo lectura). Un recurso = una función; el método HTTP
// distingue la operación (aquí solo GET = listar). La RLS de Supabase
// (script-001.sql) filtra a lo publicado para usuarios autenticados.
//
// Función NUEVA y autocontenida (Constitución §4): define su propio CORS y no
// comparte código con otras funciones. El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

const COURSE_COLUMNS = "id, title, slug, description, icon, color, difficulty";

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

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  const { data, error } = await supabase
    .from("certdeck_courses")
    .select(COURSE_COLUMNS)
    .order("difficulty", { ascending: true })
    .order("title", { ascending: true });

  if (error) return json({ error: "query_failed", detail: error.message }, 500);

  return json({ data: data ?? [] });
});
