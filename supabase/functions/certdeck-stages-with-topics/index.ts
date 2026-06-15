// =============================================================================
// CertDeck — Edge Function: certdeck-stages-with-topics
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso ETAPAS de un curso, cada una con sus TEMAS (solo lectura), ordenado
// por posición. Un recurso = una función; aquí solo GET. RLS (script-001.sql)
// filtra a lo publicado para usuarios autenticados.
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

interface Stage {
  id: string;
  course_id: string;
  title: string;
  description: string | null;
  position: number;
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

  const { data: stages, error: stagesError } = await supabase
    .from("certdeck_stages")
    .select("id, course_id, title, description, position")
    .eq("course_id", courseId)
    .order("position", { ascending: true });
  if (stagesError) return json({ error: "query_failed", detail: stagesError.message }, 500);

  const stageList = (stages ?? []) as Stage[];
  if (stageList.length === 0) return json({ data: [] });

  const { data: topics, error: topicsError } = await supabase
    .from("certdeck_topics")
    .select("id, stage_id, title, description, summary, position")
    .in("stage_id", stageList.map((s) => s.id))
    .order("position", { ascending: true });
  if (topicsError) return json({ error: "query_failed", detail: topicsError.message }, 500);

  const topicList = (topics ?? []) as Array<{ stage_id: string }>;
  const result = stageList.map((stage) => ({
    ...stage,
    topics: topicList.filter((t) => t.stage_id === stage.id),
  }));

  return json({ data: result });
});
