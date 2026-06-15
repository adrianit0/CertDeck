"use client";

import { getSupabaseClient } from "@/lib/supabase/client";
import type {
  Course,
  FlashcardQuestion,
  Lesson,
  LessonScreen,
  PlayableLesson,
  Stage,
  StageWithTopics,
  Topic,
} from "@/lib/types";

/**
 * Consultas de CONTENIDO (solo lectura). La RLS de Supabase ya filtra a lo
 * publicado para usuarios autenticados (ver script-001/002.sql).
 * Toda la obtención de datos es en cliente (ADR 0003).
 */

const COURSE_COLUMNS = "id, title, slug, description, icon, color, difficulty";

export async function getCourses(): Promise<Course[]> {
  const { data, error } = await getSupabaseClient()
    .from("certdeck_courses")
    .select(COURSE_COLUMNS)
    .order("difficulty", { ascending: true })
    .order("title", { ascending: true });
  if (error) throw error;
  return (data ?? []) as Course[];
}

export async function getCourseBySlug(slug: string): Promise<Course | null> {
  const { data, error } = await getSupabaseClient()
    .from("certdeck_courses")
    .select(COURSE_COLUMNS)
    .eq("slug", slug)
    .maybeSingle();
  if (error) throw error;
  return (data as Course) ?? null;
}

/** Etapas del curso, cada una con sus temas, todo ordenado por posición. */
export async function getStagesWithTopics(courseId: string): Promise<StageWithTopics[]> {
  const supabase = getSupabaseClient();

  const { data: stages, error: stagesError } = await supabase
    .from("certdeck_stages")
    .select("id, course_id, title, description, position")
    .eq("course_id", courseId)
    .order("position", { ascending: true });
  if (stagesError) throw stagesError;

  const stageList = (stages ?? []) as Stage[];
  if (stageList.length === 0) return [];

  const { data: topics, error: topicsError } = await supabase
    .from("certdeck_topics")
    .select("id, stage_id, title, description, summary, position")
    .in(
      "stage_id",
      stageList.map((s) => s.id),
    )
    .order("position", { ascending: true });
  if (topicsError) throw topicsError;

  const topicList = (topics ?? []) as Topic[];
  return stageList.map((stage) => ({
    ...stage,
    topics: topicList.filter((t) => t.stage_id === stage.id),
  }));
}

export async function getTopic(topicId: string): Promise<Topic | null> {
  const { data, error } = await getSupabaseClient()
    .from("certdeck_topics")
    .select("id, stage_id, title, description, summary, position")
    .eq("id", topicId)
    .maybeSingle();
  if (error) throw error;
  return (data as Topic) ?? null;
}

export async function getLessonsByTopic(topicId: string): Promise<Lesson[]> {
  const { data, error } = await getSupabaseClient()
    .from("certdeck_lessons")
    .select("id, topic_id, title, description, lesson_type, position")
    .eq("topic_id", topicId)
    .order("position", { ascending: true });
  if (error) throw error;
  return (data ?? []) as Lesson[];
}

export async function getPlayableLesson(lessonId: string): Promise<PlayableLesson | null> {
  const supabase = getSupabaseClient();

  const { data: lesson, error: lessonError } = await supabase
    .from("certdeck_lessons")
    .select("id, topic_id, title, description, lesson_type, position")
    .eq("id", lessonId)
    .maybeSingle();
  if (lessonError) throw lessonError;
  if (!lesson) return null;

  const { data: screens, error: screensError } = await supabase
    .from("certdeck_lesson_screens")
    .select("id, lesson_id, title, body, position")
    .eq("lesson_id", lessonId)
    .order("position", { ascending: true });
  if (screensError) throw screensError;

  // Se extraen TODAS las preguntas activas de la lección; el orden de
  // presentación lo decide el reproductor (aleatorio), no la base de datos.
  const { data: questions, error: questionsError } = await supabase
    .from("certdeck_flashcard_questions")
    .select(
      "id, lesson_id, exercise_type, question, correct_answer, incorrect_answer_1, incorrect_answer_2, explanation",
    )
    .eq("lesson_id", lessonId);
  if (questionsError) throw questionsError;

  return {
    lesson: lesson as Lesson,
    screens: (screens ?? []) as LessonScreen[],
    questions: (questions ?? []) as FlashcardQuestion[],
  };
}
