"use client";

import { invokeEdge } from "@/lib/edge/invoke";
import { normalize, type ProgressState } from "@/lib/progress/progressState";
import type { CardReview, SessionResult } from "@/lib/types";

/**
 * Persistencia del PROGRESO contra la base de datos (ADR 0006).
 *
 * La BD es la única fuente de verdad: no hay caché en disco. El cliente mantiene
 * un estado optimista EN MEMORIA (ver `AppShell`) y estas funciones hacen la
 * escritura/lectura write-through vía Edge Functions. Si una llamada falla, el
 * `AppShell` muestra el aviso de "sin conexión"; el optimismo en memoria
 * mantiene la UI usable hasta recargar (donde se reconcilia con `getProgress`).
 */

export type ReviewType = "topic-review" | "general-review" | "topic-errors" | "general-errors";

/** Lee el estado completo de progreso del usuario desde la BD. */
export async function getProgress(): Promise<ProgressState> {
  const dto = await invokeEdge<unknown>("certdeck-progress-get");
  return normalize(dto);
}

/** Persiste la finalización de una lección (score/xp recalculados en servidor). */
export async function completeLesson(lessonId: string, result: SessionResult): Promise<void> {
  await invokeEdge("certdeck-progress-complete-lesson", {
    method: "POST",
    body: {
      lesson_id: lessonId,
      correct_count: result.correctCount,
      incorrect_count: result.incorrectCount,
      anki_count: result.ankiCount,
      failed_questions: result.failedQuestions,
      passed_question_ids: result.passedQuestionIds,
    },
  });
}

/** Persiste una sesión de repaso (no atada a una lección). */
export async function recordReview(reviewType: ReviewType, result: SessionResult): Promise<void> {
  await invokeEdge("certdeck-progress-record-review", {
    method: "POST",
    body: {
      review_type: reviewType,
      correct_count: result.correctCount,
      incorrect_count: result.incorrectCount,
      anki_count: result.ankiCount,
      failed_questions: result.failedQuestions,
      passed_question_ids: result.passedQuestionIds,
    },
  });
}

/** Borra todo el progreso del usuario en la BD. */
export async function resetProgress(): Promise<void> {
  await invokeEdge("certdeck-progress-reset", { method: "POST" });
}

/**
 * Actualiza el estado de repetición espaciada (SM-2) de las tarjetas revisadas.
 * Autoritativo: el servidor recalcula intervalo/ease/due (ver Edge Function).
 */
export async function submitCardReviews(reviews: CardReview[]): Promise<void> {
  if (reviews.length === 0) return;
  await invokeEdge("certdeck-spaced-review-update", {
    method: "POST",
    body: { reviews: reviews.map((r) => ({ question_id: r.questionId, grade: r.grade })) },
  });
}
