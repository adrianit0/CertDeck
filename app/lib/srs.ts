/**
 * Repetición espaciada — algoritmo tipo SM-2 simplificado (ADR 0002, RN-13…17).
 *
 * Función PURA y testeable (RNF-09): no toca red ni almacenamiento. La capa
 * autoritativa (Edge Function `certdeck-spaced-review-update`, v2.2) aplicará
 * estos mismos parámetros sobre `certdeck_user_spaced_repetition`. Los valores
 * por defecto (Q-03) son AJUSTABLES sin reescribir la lógica (RN-16).
 *
 * Estado por tarjeta y usuario: `easeFactor`, `intervalDays`, `repetitions`,
 * `lapses`, `isProblematic`, `dueAt`, `lastReviewedAt` (RF-33).
 */

/** Autoevaluación de una tarjeta ANKI (coincide con `LessonPlayer`). */
export type ReviewGrade = "fail" | "correct" | "easy";

export interface SrsCardState {
  /** Factor de facilidad; nunca baja de `minEase`. */
  easeFactor: number;
  /** Intervalo actual en días (0 = vence de inmediato). */
  intervalDays: number;
  /** Aciertos consecutivos (se reinicia a 0 al fallar). */
  repetitions: number;
  /** Fallos acumulados (histórico). */
  lapses: number;
  /** Marcada como problemática al alcanzar `lapsesToProblematic` fallos (Q-02). */
  isProblematic: boolean;
  /** Próxima fecha de revisión (ISO). */
  dueAt: string;
  /** Última revisión (ISO) o null si nunca se revisó. */
  lastReviewedAt: string | null;
}

export interface SrsParams {
  /** Ease inicial de una tarjeta nueva. */
  initialEase: number;
  /** Cota inferior del ease. */
  minEase: number;
  /** Cuánto baja el ease al fallar (Incorrecto). */
  easePenalty: number;
  /** Cuánto sube el ease en "Muy fácil". */
  easyEaseBonus: number;
  /** Pasos fijos (días) para los primeros aciertos "Correcto". */
  correctSteps: number[];
  /** Pasos fijos (días) para los primeros "Muy fácil". */
  easySteps: number[];
  /** Factor extra de crecimiento del intervalo en "Muy fácil". */
  easyIntervalBonus: number;
  /** Fallos a partir de los cuales la tarjeta es problemática (Q-02). */
  lapsesToProblematic: number;
}

/** Valores por defecto fijados en Q-03 (RN-16). Ajustables. */
export const DEFAULT_SRS_PARAMS: SrsParams = {
  initialEase: 2.5,
  minEase: 1.3,
  easePenalty: 0.2,
  easyEaseBonus: 0.15,
  correctSteps: [1, 3, 7],
  easySteps: [3, 7],
  easyIntervalBonus: 1.3,
  lapsesToProblematic: 3,
};

/** Redondeo a 2 decimales para evitar deriva de coma flotante en el ease. */
function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

/** Suma `days` días naturales a una fecha (conservando la hora). */
function addDays(base: Date, days: number): Date {
  const d = new Date(base.getTime());
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

/**
 * Siguiente intervalo: si aún quedan pasos fijos, usa el paso correspondiente;
 * si no, crece de forma multiplicativa (`intervalo × ease × bonus`, mínimo 1).
 */
function nextInterval(
  repetitions: number,
  prevInterval: number,
  ease: number,
  steps: number[],
  bonus: number,
): number {
  if (repetitions <= steps.length) return steps[repetitions - 1] ?? 1;
  const base = prevInterval > 0 ? prevInterval : (steps[steps.length - 1] ?? 1);
  return Math.max(1, Math.round(base * ease * bonus));
}

/** Estado inicial de una tarjeta nunca revisada (vence de inmediato). */
export function initialCardState(
  now: Date = new Date(),
  params: SrsParams = DEFAULT_SRS_PARAMS,
): SrsCardState {
  return {
    easeFactor: params.initialEase,
    intervalDays: 0,
    repetitions: 0,
    lapses: 0,
    isProblematic: false,
    dueAt: now.toISOString(),
    lastReviewedAt: null,
  };
}

/**
 * Aplica una autoevaluación y devuelve el NUEVO estado (inmutable).
 *
 * - **Incorrecto** (RN-13): `lapses += 1`, `ease -= 0.2` (mín. 1.3),
 *   `interval = 0`, `repetitions = 0`; problemática a los 3 fallos.
 * - **Correcto** (RN-14): `repetitions += 1`; pasos 1/3/7 y luego `× ease`.
 * - **Muy fácil** (RN-15): `repetitions += 1`; `ease += 0.15`; pasos 3/7 y
 *   luego `× ease × bonus`.
 */
export function reviewCard(
  state: SrsCardState,
  grade: ReviewGrade,
  now: Date = new Date(),
  params: SrsParams = DEFAULT_SRS_PARAMS,
): SrsCardState {
  let { easeFactor, intervalDays, repetitions, lapses, isProblematic } = state;

  if (grade === "fail") {
    lapses += 1;
    easeFactor = Math.max(params.minEase, round2(easeFactor - params.easePenalty));
    repetitions = 0;
    intervalDays = 0;
    if (lapses >= params.lapsesToProblematic) isProblematic = true;
  } else if (grade === "correct") {
    repetitions += 1;
    intervalDays = nextInterval(repetitions, intervalDays, easeFactor, params.correctSteps, 1);
  } else {
    repetitions += 1;
    easeFactor = round2(easeFactor + params.easyEaseBonus);
    intervalDays = nextInterval(
      repetitions,
      intervalDays,
      easeFactor,
      params.easySteps,
      params.easyIntervalBonus,
    );
  }

  return {
    easeFactor,
    intervalDays,
    repetitions,
    lapses,
    isProblematic,
    dueAt: addDays(now, intervalDays).toISOString(),
    lastReviewedAt: now.toISOString(),
  };
}

/** True si la tarjeta ya está vencida (su `dueAt` llegó). */
export function isCardDue(state: SrsCardState, now: Date = new Date()): boolean {
  return new Date(state.dueAt).getTime() <= now.getTime();
}
