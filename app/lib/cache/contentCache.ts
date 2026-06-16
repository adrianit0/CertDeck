"use client";

import type { Stage, Topic, Lesson } from "@/lib/types";

/**
 * Caché LOCAL del catálogo de un curso (etapas + temas + lecciones) — ADR 0009.
 *
 * El contenido de los cursos apenas cambia una vez creado, pero es voluminoso y
 * cargarlo en cada arranque es lento (una llamada de etapas/temas + N de
 * lecciones). Por eso se guarda en `localStorage` junto a un TOKEN de versión y,
 * al arrancar, solo se vuelve a descargar si el token del servidor
 * (`certdeck-content-version`) difiere del guardado.
 *
 * Importante: aquí solo vive CONTENIDO público de solo lectura (nunca progreso
 * del usuario, que sigue siendo la BD como única fuente de verdad — ADR 0006).
 */

const KEY_PREFIX = "certdeck:catalog:";

/** Estructura del catálogo cacheado (igual que `CourseData` del shell). */
export interface CourseCatalog {
  stages: Stage[];
  topics: Topic[];
  lessons: Lesson[];
}

interface CachedCatalog {
  version: string;
  catalog: CourseCatalog;
}

function key(courseId: string): string {
  return `${KEY_PREFIX}${courseId}`;
}

/** Lee el catálogo cacheado de un curso (o `null` si no hay / es inválido). */
export function readCatalogCache(courseId: string): CachedCatalog | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(key(courseId));
    if (!raw) return null;
    const parsed = JSON.parse(raw) as CachedCatalog;
    if (!parsed || typeof parsed.version !== "string" || !parsed.catalog) return null;
    const { stages, topics, lessons } = parsed.catalog;
    if (!Array.isArray(stages) || !Array.isArray(topics) || !Array.isArray(lessons)) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/** Guarda el catálogo de un curso con su token de versión. */
export function writeCatalogCache(
  courseId: string,
  version: string,
  catalog: CourseCatalog,
): void {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(key(courseId), JSON.stringify({ version, catalog }));
  } catch {
    // Cuota llena o modo privado: se ignora; el contenido seguirá viniendo de red.
  }
}

/** Borra la caché de catálogo de un curso (p. ej. al resetear). */
export function clearCatalogCache(courseId: string): void {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.removeItem(key(courseId));
  } catch {
    // Ignorado.
  }
}
