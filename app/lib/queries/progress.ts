"use client";

import { getSupabaseClient } from "@/lib/supabase/client";
import { markLessonCompleted } from "@/lib/progress/localProgress";
import type { SessionResult } from "@/lib/types";

/**
 * Persiste la finalización de una lección.
 *
 * 1) Actualiza el progreso OPTIMISTA local (siempre, inmediato).
 * 2) Llama a la Edge Function autoritativa `certdeck-progress-complete-lesson`
 *    (ADR 0002). Si aún no está desplegada o falla, NO rompe la experiencia:
 *    el progreso local mantiene la app usable y se reconciliará más adelante.
 */
export async function completeLesson(lessonId: string, result: SessionResult): Promise<void> {
  markLessonCompleted(lessonId, result);

  try {
    await getSupabaseClient().functions.invoke("certdeck-progress-complete-lesson", {
      body: {
        lesson_id: lessonId,
        correct_count: result.correctCount,
        incorrect_count: result.incorrectCount,
        score_percentage: result.scorePercentage,
      },
    });
  } catch {
    // Silencioso a propósito: el progreso local ya quedó guardado.
  }
}
