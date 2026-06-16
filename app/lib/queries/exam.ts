"use client";

import { invokeEdge } from "@/lib/edge/invoke";
import type {
  ExamAttempt,
  ExamFilters,
  ExamGradeSummary,
  ExamQuestion,
} from "@/lib/types";

/**
 * Consultas y corrección de la PRÁCTICA DE EXAMEN (v3, RF-24…29).
 *
 * Como el resto del cliente, toda llamada pasa por una Edge Function dedicada
 * (nunca consulta tablas directamente). Las preguntas llegan con las respuestas
 * ya DESORDENADAS (RF-28); la corrección autoritativa y el registro del intento
 * los hace `certdeck-exam-grade` (Q-06: registra intento, no toca repaso).
 */

/** Lee preguntas de examen filtrables por tema/dificultad (RF-26). */
export async function getExamQuestions(filters: ExamFilters): Promise<ExamQuestion[]> {
  const query: Record<string, string | undefined> = { course_id: filters.courseId };
  if (filters.topicId) query.topic_id = filters.topicId;
  if (filters.difficulty != null) query.difficulty = String(filters.difficulty);
  if (filters.limit != null) query.limit = String(filters.limit);
  return invokeEdge<ExamQuestion[]>("certdeck-exam-questions", { query });
}

/**
 * Corrige de forma autoritativa un lote de respuestas y registra los intentos.
 * El servidor reconfirma la regla de conjunto exacto (RF-29) y persiste en
 * `certdeck_user_question_attempts` SIN alterar la repetición espaciada (Q-06).
 */
export async function gradeExam(attempts: ExamAttempt[]): Promise<ExamGradeSummary> {
  if (attempts.length === 0) return { results: [], correctCount: 0, total: 0 };
  return invokeEdge<ExamGradeSummary>("certdeck-exam-grade", {
    method: "POST",
    body: {
      attempts: attempts.map((a) => ({
        question_id: a.questionId,
        selected_answers: a.selectedAnswers,
      })),
    },
  });
}
