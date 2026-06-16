"use client";

import { invokeEdge } from "@/lib/edge/invoke";
import type {
  Course,
  FlashcardQuestion,
  Lesson,
  PlayableLesson,
  StageWithTopics,
} from "@/lib/types";

/**
 * Consultas de CONTENIDO (solo lectura).
 *
 * TODA obtención de datos pasa por una Edge Function dedicada (nunca se consulta
 * a las tablas directamente desde el cliente). Cada recurso tiene su propia
 * función; el método HTTP distingue la operación. La RLS de Supabase, aplicada
 * dentro de cada función con el JWT del usuario, filtra a lo publicado
 * (ver script-001/002.sql y ADR 0003).
 */

export async function getCourses(): Promise<Course[]> {
  return invokeEdge<Course[]>("certdeck-courses");
}

/**
 * Token de versión del CATÁLOGO del curso (etapas + temas + lecciones). Llamada
 * ligera: solo sirve para decidir si la caché local sigue vigente (ADR 0009).
 */
export async function getCourseContentVersion(courseId: string): Promise<string> {
  const res = await invokeEdge<{ version: string }>("certdeck-content-version", {
    query: { course_id: courseId },
  });
  return res?.version ?? "0.0";
}

/** Etapas del curso, cada una con sus temas, todo ordenado por posición. */
export async function getStagesWithTopics(courseId: string): Promise<StageWithTopics[]> {
  return invokeEdge<StageWithTopics[]>("certdeck-stages-with-topics", {
    query: { course_id: courseId },
  });
}

export async function getLessonsByTopic(topicId: string): Promise<Lesson[]> {
  return invokeEdge<Lesson[]>("certdeck-lessons-by-topic", {
    query: { topic_id: topicId },
  });
}

/** Preguntas de un conjunto de lecciones (para repasos por tema / generales). */
export async function getQuestionsByLessons(lessonIds: string[]): Promise<FlashcardQuestion[]> {
  if (lessonIds.length === 0) return [];
  return invokeEdge<FlashcardQuestion[]>("certdeck-questions-by-lessons", {
    query: { lesson_ids: lessonIds },
  });
}

/** Preguntas concretas por id (para repasos de errores acumulados). */
export async function getQuestionsByIds(questionIds: string[]): Promise<FlashcardQuestion[]> {
  if (questionIds.length === 0) return [];
  return invokeEdge<FlashcardQuestion[]>("certdeck-questions-by-ids", {
    query: { ids: questionIds },
  });
}

export async function getPlayableLesson(lessonId: string): Promise<PlayableLesson | null> {
  return invokeEdge<PlayableLesson | null>("certdeck-playable-lesson", {
    query: { lesson_id: lessonId },
  });
}
