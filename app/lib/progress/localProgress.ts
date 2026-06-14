"use client";

import type { LessonStatus } from "@/lib/types";

/**
 * Progreso OPTIMISTA en el cliente (capa no autoritativa del ADR 0002).
 *
 * Persistimos en localStorage para que el MVP sea usable de inmediato: refleja
 * al instante lecciones completadas y desbloqueo lineal. La fuente de verdad
 * será la Edge Function `certdeck-progress-complete-lesson` + las tablas
 * `certdeck_user_*` con RLS (script-003.sql), que reconciliarán este estado.
 */

const STORAGE_KEY = "certdeck:progress";

export interface LessonProgress {
  status: Extract<LessonStatus, "in_progress" | "completed">;
  scorePercentage: number;
  completedAt: string | null;
}

type ProgressMap = Record<string, LessonProgress>;

function read(): ProgressMap {
  if (typeof window === "undefined") return {};
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as ProgressMap) : {};
  } catch {
    return {};
  }
}

function write(map: ProgressMap): void {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(map));
}

export function getProgressMap(): ProgressMap {
  return read();
}

export function markLessonCompleted(lessonId: string, scorePercentage: number): void {
  const map = read();
  map[lessonId] = {
    status: "completed",
    scorePercentage,
    completedAt: new Date().toISOString(),
  };
  write(map);
}

/**
 * Desbloqueo lineal (RF-35/36): la primera lección está disponible; el resto
 * se desbloquea al completar la anterior.
 */
export function computeLessonStatus(
  index: number,
  lessonIds: string[],
  progress: ProgressMap,
): LessonStatus {
  const id = lessonIds[index];
  if (id && progress[id]?.status === "completed") return "completed";
  if (index === 0) return "available";
  const prevId = lessonIds[index - 1];
  if (prevId && progress[prevId]?.status === "completed") return "available";
  return "locked";
}
