"use client";

import type {
  FailedQuestionRef,
  LessonStatus,
  SessionResult,
  UserStats,
} from "@/lib/types";

/**
 * Progreso OPTIMISTA en el cliente (capa no autoritativa del ADR 0002).
 *
 * Persistimos en localStorage para que el MVP sea usable de inmediato: refleja
 * al instante lecciones completadas, desbloqueo lineal y métricas reales de
 * estudio. La fuente de verdad será la Edge Function
 * `certdeck-progress-complete-lesson` + las tablas `certdeck_user_*` con RLS
 * (script-003.sql), que reconciliarán este estado.
 */

const STORAGE_KEY = "certdeck:progress";

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

function emptyState(): ProgressState {
  return {
    lessons: {},
    failedQuestions: {},
    review: { xp: 0, totalAnswers: 0, correctAnswers: 0, ankiCards: 0 },
    activeDays: [],
  };
}

/** Normaliza cualquier formato almacenado (incluido el legado) al actual. */
function normalize(parsed: unknown): ProgressState {
  const base = emptyState();
  if (!parsed || typeof parsed !== "object") return base;
  const obj = parsed as Record<string, unknown>;

  // Formato legado: el objeto raíz ERA el mapa de lecciones (sin claves nuevas).
  const lessonsSource =
    obj.lessons && typeof obj.lessons === "object" ? (obj.lessons as Record<string, unknown>) : obj;

  for (const [id, value] of Object.entries(lessonsSource)) {
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

  if (obj.failedQuestions && typeof obj.failedQuestions === "object") {
    base.failedQuestions = obj.failedQuestions as Record<string, string>;
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

function read(): ProgressState {
  if (typeof window === "undefined") return emptyState();
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? normalize(JSON.parse(raw)) : emptyState();
  } catch {
    return emptyState();
  }
}

function write(state: ProgressState): void {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function today(): string {
  return new Date().toISOString().slice(0, 10);
}

function withTodayActive(days: string[]): string[] {
  const t = today();
  return days.includes(t) ? days : [...days, t];
}

export function getProgressState(): ProgressState {
  return read();
}

export function resetProgress(): void {
  write(emptyState());
}

/** Marca una lección como completada con sus métricas reales de la sesión. */
export function markLessonCompleted(lessonId: string, result: SessionResult): void {
  const state = read();
  state.lessons[lessonId] = {
    status: "completed",
    scorePercentage: result.scorePercentage,
    correctCount: result.correctCount,
    incorrectCount: result.incorrectCount,
    ankiCount: result.ankiCount,
    xp: result.xpGained,
    completedAt: new Date().toISOString(),
  };
  state.activeDays = withTodayActive(state.activeDays);
  applyQuestionOutcomes(state, result);
  write(state);
}

/** Acumula la actividad de una sesión de repaso (no completa una lección). */
export function recordReviewSession(result: SessionResult): void {
  const state = read();
  state.review.xp += result.xpGained;
  state.review.totalAnswers += result.correctCount + result.incorrectCount;
  state.review.correctAnswers += result.correctCount;
  state.review.ankiCards += result.ankiCount;
  state.activeDays = withTodayActive(state.activeDays);
  applyQuestionOutcomes(state, result);
  write(state);
}

/** Añade los fallos nuevos y retira los que se recuperaron en la sesión. */
function applyQuestionOutcomes(state: ProgressState, result: SessionResult): void {
  for (const passedId of result.passedQuestionIds) {
    delete state.failedQuestions[passedId];
  }
  for (const failed of result.failedQuestions) {
    state.failedQuestions[failed.id] = failed.lessonId;
  }
}

export function getFailedQuestions(): FailedQuestionRef[] {
  const state = read();
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
  // Si no hubo actividad hoy, la racha solo cuenta si la hubo ayer.
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
