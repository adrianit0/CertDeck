// =============================================================================
// CertDeck — Edge Function: certdeck-questions-by-lessons
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso PREGUNTAS de un conjunto de lecciones (solo lectura), para los
// repasos por tema / generales. Un recurso = una función; aquí solo GET. RLS
// (script-001.sql) filtra a lo publicado para usuarios autenticados.
//
// Parámetros (query): `lesson_ids` repetido (`?lesson_ids=a&lesson_ids=b`).
//
// Función NUEVA y autocontenida (Constitución §4). El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

const QUESTION_COLUMNS =
  "id, lesson_id, exercise_type, question, correct_answer, incorrect_answer_1, incorrect_answer_2, explanation";

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

  const lessonIds = new URL(req.url).searchParams.getAll("lesson_ids");
  if (lessonIds.length === 0) return json({ data: [] });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  const { data, error } = await supabase
    .from("certdeck_flashcard_questions")
    .select(QUESTION_COLUMNS)
    .in("lesson_id", lessonIds);

  if (error) return json({ error: "query_failed", detail: error.message }, 500);

  return json({ data: data ?? [] });
});
