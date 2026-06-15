// =============================================================================
// CertDeck — Edge Function: certdeck-playable-lesson
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso LECCIÓN REPRODUCIBLE: la lección + sus pantallas de teoría + sus
// preguntas activas (solo lectura). El orden de presentación de las preguntas
// lo decide el reproductor (aleatorio), no la base de datos. Un recurso = una
// función; aquí solo GET. RLS (script-001.sql) filtra a lo publicado.
//
// COMPOSICIÓN DINÁMICA (ADR 0005, regla del propietario 2026-06-16):
//   - lecciones `normal`         -> sus propias `certdeck_flashcard_questions`.
//   - lecciones `review`         -> ~4 tarjetas AL AZAR de las 5 lecciones
//                                   inmediatamente anteriores en el recorrido
//                                   (puede cruzar al tema anterior).
//   - lecciones `final`          -> ~6 tarjetas AL AZAR de cualquier lección
//                                   del MISMO tema.
// (Estas lecciones ya NO almacenan preguntas propias; se reciclan en runtime.)
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

const QUESTION_COLUMNS =
  "id, lesson_id, exercise_type, question, correct_answer, incorrect_answer_1, incorrect_answer_2, explanation";

// Parámetros de composición (regla del propietario).
const REVIEW_SOURCE_LESSONS = 5; // de cuántas lecciones anteriores se recicla
const REVIEW_CARD_COUNT = 4; // cuántas tarjetas lleva un repaso
const FINAL_CARD_COUNT = 6; // cuántas tarjetas lleva una evaluación final

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Supa = ReturnType<typeof createClient>;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Question = Record<string, any>;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Fisher-Yates + recorte: `n` elementos al azar (o todos si hay menos). */
function pickRandom<T>(items: T[], n: number): T[] {
  const arr = items.slice();
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr.slice(0, n);
}

/** Preguntas de un conjunto de lecciones. */
async function questionsOfLessons(supabase: Supa, lessonIds: string[]): Promise<Question[]> {
  if (lessonIds.length === 0) return [];
  const { data } = await supabase
    .from("certdeck_flashcard_questions")
    .select(QUESTION_COLUMNS)
    .in("lesson_id", lessonIds);
  return data ?? [];
}

/** FINAL: ~6 tarjetas al azar de cualquier lección del mismo tema. */
async function composeFinal(supabase: Supa, lesson: Question): Promise<Question[]> {
  const { data: siblings } = await supabase
    .from("certdeck_lessons")
    .select("id")
    .eq("topic_id", lesson.topic_id)
    .neq("id", lesson.id);
  const ids = (siblings ?? []).map((l: Question) => l.id as string);
  return pickRandom(await questionsOfLessons(supabase, ids), FINAL_CARD_COUNT);
}

/**
 * REVIEW: ~4 tarjetas al azar de las 5 lecciones inmediatamente anteriores en el
 * recorrido del curso (orden etapa.position → tema.position → lección.position),
 * pudiendo cruzar al tema anterior.
 */
async function composeReview(supabase: Supa, lesson: Question): Promise<Question[]> {
  const { data: topic } = await supabase
    .from("certdeck_topics")
    .select("id, stage_id, position")
    .eq("id", lesson.topic_id)
    .maybeSingle();
  if (!topic) return [];

  const { data: stage } = await supabase
    .from("certdeck_stages")
    .select("id, course_id, position")
    .eq("id", topic.stage_id)
    .maybeSingle();
  if (!stage) return [];

  // Jerarquía del curso para construir el orden global de lecciones.
  const { data: stages } = await supabase
    .from("certdeck_stages")
    .select("id, position")
    .eq("course_id", stage.course_id);
  const stagePos = new Map(
    (stages ?? []).map((s: Question): [string, number] => [s.id, s.position]),
  );
  const stageIds = (stages ?? []).map((s: Question) => s.id as string);

  const { data: topics } = await supabase
    .from("certdeck_topics")
    .select("id, stage_id, position")
    .in("stage_id", stageIds);
  const topicMeta = new Map(
    (topics ?? []).map((t: Question): [string, Question] => [t.id, t]),
  );
  const topicIds = (topics ?? []).map((t: Question) => t.id as string);

  const { data: allLessons } = await supabase
    .from("certdeck_lessons")
    .select("id, topic_id, position")
    .in("topic_id", topicIds);

  const ordered = (allLessons ?? []).slice().sort((a: Question, b: Question) => {
    const ta = topicMeta.get(a.topic_id);
    const tb = topicMeta.get(b.topic_id);
    const sa = stagePos.get(ta?.stage_id) ?? 0;
    const sb = stagePos.get(tb?.stage_id) ?? 0;
    if (sa !== sb) return sa - sb;
    if ((ta?.position ?? 0) !== (tb?.position ?? 0)) return (ta?.position ?? 0) - (tb?.position ?? 0);
    return (a.position ?? 0) - (b.position ?? 0);
  });

  const idx = ordered.findIndex((l: Question) => l.id === lesson.id);
  if (idx <= 0) return [];
  const precedingIds = ordered
    .slice(Math.max(0, idx - REVIEW_SOURCE_LESSONS), idx)
    .map((l: Question) => l.id as string);

  return pickRandom(await questionsOfLessons(supabase, precedingIds), REVIEW_CARD_COUNT);
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

  // Preguntas: propias (normal) o compuestas en runtime (review/final).
  let questions: Question[];
  if (lesson.lesson_type === "final") {
    questions = await composeFinal(supabase, lesson);
  } else if (lesson.lesson_type === "review") {
    questions = await composeReview(supabase, lesson);
  } else {
    const { data, error } = await supabase
      .from("certdeck_flashcard_questions")
      .select(QUESTION_COLUMNS)
      .eq("lesson_id", lessonId);
    if (error) return json({ error: "query_failed", detail: error.message }, 500);
    questions = data ?? [];
  }

  return json({
    data: {
      lesson,
      screens: screens ?? [],
      questions,
    },
  });
});
