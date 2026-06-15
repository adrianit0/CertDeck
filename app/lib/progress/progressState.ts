import type { FailedQuestionRef, LessonStatus, SessionResult, UserStats } from "@/lib/types";

/**
 * Estado de progreso en MEMORIA (ADR 0006).
 *
 * Ya NO se persiste en localStorage: la fuente de verdad es la base de datos
 * (Edge Functions `certdeck-progress-*`). Este módulo solo contiene:
 *   - Los tipos del estado.
 *   - Funciones PURAS para derivar UI (desbloqueo, racha, métricas).
 *   - Reductores PUROS para la actualización OPTIMISTA en memoria, que el
 *     `AppShell` aplica al instante mientras la escritura viaja a la BD.
 *
 * Al recargar, el estado se vuelve a leer de la BD (`getProgress`), de modo que
 * cualquier optimismo se reconcilia con la verdad del servidor.
 */

export interface LessonProgress {
  status: Extract<LessonStatus, "in_progress" | "completed">;
  scorePercentage: number;
  correctCount: number;
  incorrectCount: number;
  ankiCount: number;
  xp: number;
  completedAt: string | null;
}

/** Actividad acumulada de las sesiones de repaso (no atadas a una lección). */
export interface ReviewActivity {
  xp: number;
  totalAnswers: number;
  correctAnswers: number;
  ankiCards: number;
}

export interface ProgressState {
  lessons: Record<string, LessonProgress>;
  /** Preguntas pendientes de recuperar: id -> lessonId. */
  failedQuestions: Record<string, string>;
  review: ReviewActivity;
  /** Días (YYYY-MM-DD) con actividad, para calcular la racha. */
  activeDays: string[];
}

export function emptyState(): ProgressState {
  return {
    lessons: {},
    failedQuestions: {},
    review: { xp: 0, totalAnswers: 0, correctAnswers: 0, ankiCards: 0 },
    activeDays: [],
  };
}

/**
 * Normaliza la respuesta de `certdeck-progress-get` (o cualquier objeto parcial)
 * al `ProgressState` actual, tolerando campos ausentes.
 */
export function normalize(parsed: unknown): ProgressState {
  const base = emptyState();
  if (!parsed || typeof parsed !== "object") return base;
  const obj = parsed as Record<string, unknown>;

  if (obj.lessons && typeof obj.lessons === "object") {
    for (const [id, value] of Object.entries(obj.lessons as Record<string, unknown>)) {
      if (!value || typeof value !== "object") continue;
      const v = value as Record<string, unknown>;
      if (v.status !== "completed" && v.status !== "in_progress") continue;
      base.lessons[id] = {
        status: v.status,
        scorePercentage: typeof v.scorePercentage === "number" ? v.scorePercentage : 0,
        correctCount: typeof v.correctCount === "number" ? v.correctCount : 0,
        incorrectCount: typeof v.incorrectCount === "number" ? v.incorrectCount : 0,
        ankiCount: typeof v.ankiCount === "number" ? v.ankiCount : 0,
        xp: typeof v.xp === "number" ? v.xp : 0,
        completedAt: typeof v.completedAt === "string" ? v.completedAt : null,
      };
    }
  }

  if (obj.failedQuestions && typeof obj.failedQuestions === "object") {
    for (const [id, lessonId] of Object.entries(obj.failedQuestions as Record<string, unknown>)) {
      if (typeof lessonId === "string") base.failedQuestions[id] = lessonId;
    }
  }
  if (obj.review && typeof obj.review === "object") {
    const r = obj.review as Record<string, unknown>;
    base.review = {
      xp: typeof r.xp === "number" ? r.xp : 0,
      totalAnswers: typeof r.totalAnswers === "number" ? r.totalAnswers : 0,
      correctAnswers: typeof r.correctAnswers === "number" ? r.correctAnswers : 0,
      ankiCards: typeof r.ankiCards === "number" ? r.ankiCards : 0,
    };
  }
  if (Array.isArray(obj.activeDays)) {
    base.activeDays = obj.activeDays.filter((d): d is string => typeof d === "string");
  }
  return base;
}

function today(): string {
  return new Date().toISOString().slice(0, 10);
}

function withTodayActive(days: string[]): string[] {
  const t = today();
  return days.includes(t) ? days : [...days, t];
}

/** Añade los fallos nuevos y retira los recuperados (devuelve un mapa nuevo). */
function applyQuestionOutcomes(
  failedQuestions: Record<string, string>,
  result: SessionResult,
): Record<string, string> {
  const next = { ...failedQuestions };
  for (const passedId of result.passedQuestionIds) delete next[passedId];
  for (const failed of result.failedQuestions) next[failed.id] = failed.lessonId;
  return next;
}

/**
 * Reductor OPTIMISTA: marca una lección como completada en memoria con las
 * métricas reales de la sesión. Devuelve un estado NUEVO (inmutable).
 */
export function applyLessonCompleted(
  state: ProgressState,
  lessonId: string,
  result: SessionResult,
): ProgressState {
  return {
    ...state,
    lessons: {
      ...state.lessons,
      [lessonId]: {
        status: "completed",
        scorePercentage: result.scorePercentage,
        correctCount: result.correctCount,
        incorrectCount: result.incorrectCount,
        ankiCount: result.ankiCount,
        xp: result.xpGained,
        completedAt: new Date().toISOString(),
      },
    },
    failedQuestions: applyQuestionOutcomes(state.failedQuestions, result),
    activeDays: withTodayActive(state.activeDays),
  };
}

/** Reductor OPTIMISTA: acumula una sesión de repaso en memoria. */
export function applyReviewSession(state: ProgressState, result: SessionResult): ProgressState {
  return {
    ...state,
    review: {
      xp: state.review.xp + result.xpGained,
      totalAnswers: state.review.totalAnswers + result.correctCount + result.incorrectCount,
      correctAnswers: state.review.correctAnswers + result.correctCount,
      ankiCards: state.review.ankiCards + result.ankiCount,
    },
    failedQuestions: applyQuestionOutcomes(state.failedQuestions, result),
    activeDays: withTodayActive(state.activeDays),
  };
}

export function getFailedQuestions(state: ProgressState): FailedQuestionRef[] {
  return Object.entries(state.failedQuestions).map(([id, lessonId]) => ({ id, lessonId }));
}

/**
 * Desbloqueo lineal (RF-35/36): la primera lección está disponible; el resto
 * se desbloquea al completar la anterior.
 */
export function computeLessonStatus(
  index: number,
  lessonIds: string[],
  lessons: Record<string, LessonProgress>,
): LessonStatus {
  const id = lessonIds[index];
  if (id && lessons[id]?.status === "completed") return "completed";
  if (index === 0) return "available";
  const prevId = lessonIds[index - 1];
  if (prevId && lessons[prevId]?.status === "completed") return "available";
  return "locked";
}

/** Racha de días consecutivos de estudio terminada hoy o ayer. */
function computeStreak(activeDays: string[]): number {
  if (activeDays.length === 0) return 0;
  const set = new Set(activeDays);
  const cursor = new Date();
  if (!set.has(cursor.toISOString().slice(0, 10))) {
    cursor.setDate(cursor.getDate() - 1);
    if (!set.has(cursor.toISOString().slice(0, 10))) return 0;
  }
  let streak = 0;
  while (set.has(cursor.toISOString().slice(0, 10))) {
    streak += 1;
    cursor.setDate(cursor.getDate() - 1);
  }
  return streak;
}

/** Agrega las métricas reales para la cabecera y la pestaña de Progresos. */
export function computeUserStats(state: ProgressState): UserStats {
  const completed = Object.values(state.lessons).filter((l) => l.status === "completed");

  const lessonXp = completed.reduce((sum, l) => sum + l.xp, 0);
  const lessonCorrect = completed.reduce((sum, l) => sum + l.correctCount, 0);
  const lessonIncorrect = completed.reduce((sum, l) => sum + l.incorrectCount, 0);
  const lessonAnki = completed.reduce((sum, l) => sum + l.ankiCount, 0);

  return {
    xp: lessonXp + state.review.xp,
    streak: computeStreak(state.activeDays),
    lessonsCompleted: completed.length,
    totalAnswers: lessonCorrect + lessonIncorrect + state.review.totalAnswers,
    correctAnswers: lessonCorrect + state.review.correctAnswers,
    ankiCardsStudied: lessonAnki + state.review.ankiCards,
  };
}
