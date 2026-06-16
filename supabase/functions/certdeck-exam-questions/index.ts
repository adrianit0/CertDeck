// =============================================================================
// CertDeck — Edge Function: certdeck-exam-questions
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso PRÁCTICA DE EXAMEN (solo lectura, v3 · RF-24…29). Devuelve preguntas
// de `certdeck_exam_questions` filtrables por tema y dificultad, con las
// respuestas YA DESORDENADAS y sin revelar el orden interno (RF-28/RN-10): la
// correcta es `answer_1` (única) o las primeras `correct_answers_count`
// (múltiple); aquí se mezclan y se marca `isCorrect` por opción para el feedback
// inmediato (RNF-14). La corrección autoritativa la hace `certdeck-exam-grade`.
//
// Parámetros (query):
//   - course_id   (obligatorio)
//   - topic_id    (opcional) — filtra a un tema concreto
//   - difficulty  (opcional, 1..5)
//   - limit       (opcional, por defecto 10, máximo 40)
//
// RLS (script-002.sql) restringe a preguntas activas de cursos publicados.
// Función NUEVA y autocontenida (Constitución §4). El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 40;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Row = Record<string, any>;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function shuffle<T>(items: T[]): T[] {
  const arr = items.slice();
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/**
 * Convierte una fila a la pregunta de cliente: junta answer_1..6, marca como
 * correctas las primeras `correct_answers_count` y DESORDENA (RF-28).
 */
function toExamQuestion(row: Row) {
  const raw = [row.answer_1, row.answer_2, row.answer_3, row.answer_4, row.answer_5, row.answer_6];
  const answers = raw.filter((a): a is string => typeof a === "string" && a.length > 0);
  const correctCount = Math.max(1, Math.min(Number(row.correct_answers_count ?? 1), answers.length));
  const options = answers.map((text, idx) => ({ text, isCorrect: idx < correctCount }));
  return {
    id: row.id as string,
    courseId: row.course_id as string,
    topicId: (row.topic_id ?? null) as string | null,
    lessonId: (row.lesson_id ?? null) as string | null,
    question: row.question as string,
    typeId: (row.type_id === 2 ? 2 : 1) as 1 | 2,
    options: shuffle(options),
    correctAnswersCount: correctCount,
    extraInformation: (row.extra_information ?? null) as string | null,
    difficulty: Number(row.difficulty ?? 3),
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  const params = new URL(req.url).searchParams;
  const courseId = params.get("course_id");
  if (!courseId) return json({ error: "missing_course_id" }, 400);

  const topicId = params.get("topic_id");
  const difficulty = params.get("difficulty");
  const limit = Math.min(Math.max(Number(params.get("limit") ?? DEFAULT_LIMIT), 1), MAX_LIMIT);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  let query = supabase
    .from("certdeck_exam_questions")
    .select(
      "id, course_id, topic_id, lesson_id, question, type_id, answer_1, answer_2, answer_3, answer_4, answer_5, answer_6, correct_answers_count, extra_information, difficulty",
    )
    .eq("course_id", courseId)
    .eq("is_active", true);

  if (topicId) query = query.eq("topic_id", topicId);
  if (difficulty) query = query.eq("difficulty", Number(difficulty));

  const { data, error } = await query;
  if (error) return json({ error: "query_failed", detail: error.message }, 500);

  const questions = shuffle(data ?? []).slice(0, limit).map(toExamQuestion);
  return json({ data: questions });
});
