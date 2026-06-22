/**
 * Cálculo de XP por sesión (lección / repaso / examen).
 *
 * Regla de producto (2026-06-22):
 *   - La XP NO depende del número de preguntas. Máximo 100 XP por sesión.
 *   - Base 50 XP + 1 XP por cada 2% de porcentaje de acierto → `50 + floor(score/2)`.
 *     (100% de acierto = 50 + 50 = 100 XP; 0% = 50 XP.)
 *   - Volver a hacer una lección ya completada da un 80% MENOS del total
 *     (es decir, el 20% de la XP que habría dado la primera vez).
 *
 * Esta es la fórmula CANÓNICA. El cliente la usa para el valor OPTIMISTA, pero la
 * cantidad real se recalcula de forma AUTORITATIVA en las Edge Functions
 * (`certdeck-progress-*`, `certdeck-exam-grade`) con esta misma lógica replicada
 * (patrón RT-03, como `srs.ts`): el front no puede inflar la XP.
 */

export const XP_BASE = 50;
export const XP_MAX = 100;
/** Factor de XP al repetir una lección ya completada (80% menos = 20% del total). */
export const XP_REPEAT_FACTOR = 0.2;

/**
 * XP de una sesión a partir del % de acierto (0–100).
 * @param scorePercentage porcentaje de acierto de la sesión.
 * @param isRepeat true si es una lección que ya estaba completada.
 */
export function sessionXp(scorePercentage: number, isRepeat = false): number {
  const score = Math.max(0, Math.min(100, Math.round(scorePercentage)));
  const full = Math.min(XP_MAX, XP_BASE + Math.floor(score / 2));
  return isRepeat ? Math.round(full * XP_REPEAT_FACTOR) : full;
}
