/**
 * Lógica PURA de corrección de examen (RF-27…29, RN-10/RN-11).
 *
 * Se mantiene aislada y sin dependencias de React/red para poder testearla
 * (RNF-09). La Edge Function `certdeck-exam-grade` replica esta misma regla del
 * lado servidor (corrección autoritativa, RT-03/RSP-03).
 *
 *  - Respuesta única (type_id = 1): acierto si se marca exactamente la opción
 *    correcta (y solo esa).
 *  - Respuesta múltiple (type_id = 2): acierto SOLO si el conjunto marcado es
 *    EXACTAMENTE igual al conjunto correcto (ni de menos ni de más) — RF-29.
 */

import type { ExamAnswerOption, ExamTypeId } from "@/lib/types";

/** Normaliza un texto de respuesta para comparar sin ruido de formato. */
function clean(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "");
}

/** Conjunto (sin duplicados) de respuestas normalizadas. */
function toSet(values: string[]): Set<string> {
  return new Set(values.map(clean));
}

/** ¿Dos conjuntos de respuestas (por texto) son exactamente iguales? */
export function isExactSetMatch(selected: string[], correct: string[]): boolean {
  const a = toSet(selected);
  const b = toSet(correct);
  if (a.size !== b.size) return false;
  for (const item of a) if (!b.has(item)) return false;
  return true;
}

/** Textos de las opciones correctas de una pregunta. */
export function correctTexts(options: ExamAnswerOption[]): string[] {
  return options.filter((o) => o.isCorrect).map((o) => o.text);
}

/**
 * Corrige una respuesta de examen aplicando la regla de conjunto exacto.
 * Vale tanto para única como para múltiple: en única, el conjunto correcto
 * tiene un solo elemento, así que marcar de más también falla.
 */
export function gradeExamAnswer(
  selected: string[],
  options: ExamAnswerOption[],
): boolean {
  return isExactSetMatch(selected, correctTexts(options));
}

/** El tipo de ejercicio para registrar el intento (script-003). */
export function examExerciseType(typeId: ExamTypeId): "exam_single" | "exam_multiple" {
  return typeId === 2 ? "exam_multiple" : "exam_single";
}
