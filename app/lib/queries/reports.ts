"use client";

import { invokeEdge } from "@/lib/edge/invoke";
import type { QuestionReportInput } from "@/lib/types";

/**
 * Reporte de errores en tarjetas (asistencia técnica, ADR 0008 / RF-30).
 *
 * Como toda escritura, pasa por una Edge Function (`certdeck-report-create`),
 * nunca por la tabla directamente. El servidor fija `user_id` con el JWT y RLS
 * garantiza la propiedad. El reporte se guarda para que el propietario lo revise
 * y corrija el contenido más adelante.
 */
export async function submitQuestionReport(input: QuestionReportInput): Promise<void> {
  await invokeEdge("certdeck-report-create", {
    method: "POST",
    body: {
      question_id: input.questionId,
      question_source: input.questionSource,
      category: input.category,
      details: input.details ?? null,
      lesson_id: input.lessonId ?? null,
      course_id: input.courseId ?? null,
      question_text: input.questionText ?? null,
    },
  });
}
