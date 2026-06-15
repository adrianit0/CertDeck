// =============================================================================
// CertDeck — Edge Function: certdeck-playable-lesson
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso LECCIÓN REPRODUCIBLE: la lección + sus pantallas de teoría + sus
// preguntas activas (solo lectura). El orden de presentación de las preguntas
// lo decide el reproductor (aleatorio), no la base de datos. Un recurso = una
// función; aquí solo GET. RLS (script-001.sql) filtra a lo publicado.
//
// Parámetros (query): `lesson_id` (obligatorio).
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

  const lessonId = new URL(req.url).searchParams.get("lesson_id");
  if (!lessonId) return json({ error: "missing_lesson_id" }, 400);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  const { data: lesson, error: lessonError } = await supabase
    .from("certdeck_lessons")
    .select("id, topic_id, title, description, lesson_type, position")
    .eq("id", lessonId)
    .maybeSingle();
  if (lessonError) return json({ error: "query_failed", detail: lessonError.message }, 500);
  if (!lesson) return json({ data: null });

  const { data: screens, error: screensError } = await supabase
    .from("certdeck_lesson_screens")
    .select("id, lesson_id, title, body, position")
    .eq("lesson_id", lessonId)
    .order("position", { ascending: true });
  if (screensError) return json({ error: "query_failed", detail: screensError.message }, 500);

  const { data: questions, error: questionsError } = await supabase
    .from("certdeck_flashcard_questions")
    .select(
      "id, lesson_id, exercise_type, question, correct_answer, incorrect_answer_1, incorrect_answer_2, explanation",
    )
    .eq("lesson_id", lessonId);
  if (questionsError) return json({ error: "query_failed", detail: questionsError.message }, 500);

  return json({
    data: {
      lesson,
      screens: screens ?? [],
      questions: questions ?? [],
    },
  });
});
