// =============================================================================
// CertDeck — Edge Function: certdeck-playable-lesson
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Recurso LECCIÓN REPRODUCIBLE: la lección + sus pantallas de teoría + sus
// preguntas activas (solo lectura). El orden de presentación de las preguntas
// lo decide el reproductor (aleatorio), no la base de datos.
//
// COMPOSICIÓN DINÁMICA por tipo de lección (ADR 0005 + v2.2, decisión 2026-06-16
// de usar REPETICIÓN ESPACIADA en lugar del modo posicional):
//   - `normal`           -> sus propias `certdeck_flashcard_questions`.
//   - `review`           -> tarjetas del tema (lecciones ANTERIORES a esta),
//                           priorizando las VENCIDAS (`due_at <= now`) según
//                           `certdeck_user_spaced_repetition`.
//   - `final`            -> tarjetas de TODO el tema, misma priorización.
//   - `error_correction` -> tarjetas del tema con problemas (lapses>0 o
//                           problemática); si no hay, degrada a repaso del tema.
//   - `expansion`        -> profundización reciclando tarjetas del tema ya visto
//                           (RF-45b, base reservada): mismo pool que `final`.
// La priorización por vencimiento implementa la lógica de
// `certdeck-review-build-lesson` (T-v2-006); se integra aquí para evitar un
// viaje de red extra del cliente.
//
// Parámetros (query): `lesson_id` (obligatorio).
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

// Cuántas tarjetas lleva cada tipo de lección compuesta.
const REVIEW_CARD_COUNT = 6;
const FINAL_CARD_COUNT = 8;
const ERROR_CARD_COUNT = 6;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Supa = ReturnType<typeof createClient>;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Question = Record<string, any>;

interface SrsInfo {
  due: number; // epoch ms de due_at
  lapses: number;
  problematic: boolean;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Fisher-Yates (para desempatar al ordenar y para el fallback sin historial). */
function shuffle<T>(items: T[]): T[] {
  const arr = items.slice();
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/** Ids de las lecciones del mismo tema (opcionalmente solo las anteriores). */
async function topicLessonIds(
  supabase: Supa,
  lesson: Question,
  onlyBefore: boolean,
): Promise<string[]> {
  const { data } = await supabase
    .from("certdeck_lessons")
    .select("id, position")
    .eq("topic_id", lesson.topic_id)
    .neq("id", lesson.id);
  return (data ?? [])
    .filter((l: Question) => !onlyBefore || l.position < lesson.position)
    .map((l: Question) => l.id as string);
}

async function flashcardsOfLessons(supabase: Supa, lessonIds: string[]): Promise<Question[]> {
  if (lessonIds.length === 0) return [];
  const { data } = await supabase
    .from("certdeck_flashcard_questions")
    .select(QUESTION_COLUMNS)
    .in("lesson_id", lessonIds);
  return data ?? [];
}

/** Estado SRS del usuario para un conjunto de preguntas. */
async function srsFor(
  supabase: Supa,
  userId: string,
  questionIds: string[],
): Promise<Map<string, SrsInfo>> {
  const map = new Map<string, SrsInfo>();
  if (questionIds.length === 0) return map;
  const { data } = await supabase
    .from("certdeck_user_spaced_repetition")
    .select("question_id, due_at, lapses, is_problematic")
    .eq("user_id", userId)
    .in("question_id", questionIds);
  for (const r of data ?? []) {
    map.set(r.question_id as string, {
      due: new Date(r.due_at).getTime(),
      lapses: r.lapses ?? 0,
      problematic: Boolean(r.is_problematic),
    });
  }
  return map;
}

/**
 * Ordena por prioridad de repaso: vistas y más vencidas primero (due_at asc);
 * las nunca vistas al final (con desempate aleatorio). Devuelve `count` cartas.
 */
function rankByDue(cards: Question[], srs: Map<string, SrsInfo>, count: number): Question[] {
  return shuffle(cards)
    .sort((a, b) => {
      const ka = srs.get(a.id)?.due ?? Number.MAX_SAFE_INTEGER;
      const kb = srs.get(b.id)?.due ?? Number.MAX_SAFE_INTEGER;
      return ka - kb;
    })
    .slice(0, count);
}

async function composeReview(supabase: Supa, userId: string, lesson: Question): Promise<Question[]> {
  const lessonIds = await topicLessonIds(supabase, lesson, /* onlyBefore */ true);
  const cards = await flashcardsOfLessons(supabase, lessonIds);
  const srs = await srsFor(supabase, userId, cards.map((c) => c.id as string));
  return rankByDue(cards, srs, REVIEW_CARD_COUNT);
}

async function composeFinal(supabase: Supa, userId: string, lesson: Question): Promise<Question[]> {
  const lessonIds = await topicLessonIds(supabase, lesson, /* onlyBefore */ false);
  const cards = await flashcardsOfLessons(supabase, lessonIds);
  const srs = await srsFor(supabase, userId, cards.map((c) => c.id as string));
  return rankByDue(cards, srs, FINAL_CARD_COUNT);
}

async function composeErrors(supabase: Supa, userId: string, lesson: Question): Promise<Question[]> {
  const lessonIds = await topicLessonIds(supabase, lesson, /* onlyBefore */ false);
  const cards = await flashcardsOfLessons(supabase, lessonIds);
  const srs = await srsFor(supabase, userId, cards.map((c) => c.id as string));
  // Solo tarjetas con problemas (algún fallo o marcadas problemáticas).
  const failing = cards.filter((c) => {
    const s = srs.get(c.id as string);
    return s && (s.lapses > 0 || s.problematic);
  });
  // RF-44: si no hay falladas, funciona como un repaso del tema.
  if (failing.length === 0) return rankByDue(cards, srs, REVIEW_CARD_COUNT);
  return rankByDue(failing, srs, ERROR_CARD_COUNT);
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
  const userId = userData.user.id;

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

  // Preguntas: propias (normal) o compuestas por repetición espaciada.
  let questions: Question[];
  if (lesson.lesson_type === "final" || lesson.lesson_type === "expansion") {
    // `expansion` recicla el tema ya visto (RF-45b, base reservada).
    questions = await composeFinal(supabase, userId, lesson);
  } else if (lesson.lesson_type === "review") {
    questions = await composeReview(supabase, userId, lesson);
  } else if (lesson.lesson_type === "error_correction") {
    questions = await composeErrors(supabase, userId, lesson);
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
