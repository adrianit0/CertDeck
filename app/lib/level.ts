/**
 * Curva de niveles del usuario, derivada de la XP total acumulada.
 *
 * Regla de producto (2026-06-22):
 *   - Máximo 99 niveles.
 *   - Llegar al nivel 99 requiere ~1.000.000 XP acumulada.
 *   - Se empieza pidiendo POCA XP y cada nivel exige más (curva creciente).
 *
 * Modelo: la XP acumulada necesaria para alcanzar el nivel `n` es
 *   xpForLevel(n) = MAX_XP * ((n - 1) / (MAX_LEVEL - 1)) ^ EXPONENT
 * con EXPONENT > 1, de modo que los primeros niveles cuestan muy poco y el coste
 * crece de forma acelerada hasta el millón de XP en el nivel 99.
 *
 * Es una función PURA de presentación: el nivel se deriva de la XP (que sí está
 * blindada en servidor), por lo que no necesita validación adicional.
 */

export const MAX_LEVEL = 99;
export const MAX_XP = 1_000_000;
const EXPONENT = 2.2;

/** XP ACUMULADA necesaria para alcanzar el nivel dado (1 → 0, 99 → 1.000.000). */
export function xpForLevel(level: number): number {
  if (level <= 1) return 0;
  if (level >= MAX_LEVEL) return MAX_XP;
  return Math.round(MAX_XP * Math.pow((level - 1) / (MAX_LEVEL - 1), EXPONENT));
}

/** Nivel (1–99) correspondiente a una XP total acumulada. */
export function levelForXp(xp: number): number {
  if (xp <= 0) return 1;
  if (xp >= MAX_XP) return MAX_LEVEL;
  // Inversa de la curva + corrección por redondeo para evitar off-by-one.
  const approx = Math.floor((MAX_LEVEL - 1) * Math.pow(xp / MAX_XP, 1 / EXPONENT)) + 1;
  let level = Math.min(MAX_LEVEL, Math.max(1, approx));
  while (level < MAX_LEVEL && xpForLevel(level + 1) <= xp) level += 1;
  while (level > 1 && xpForLevel(level) > xp) level -= 1;
  return level;
}

export interface LevelProgress {
  /** Nivel actual (1–99). */
  level: number;
  /** XP avanzada DENTRO del nivel actual. */
  xpIntoLevel: number;
  /** XP que abarca el tramo del nivel actual al siguiente (0 si ya es máx). */
  xpSpan: number;
  /** % de avance hacia el siguiente nivel (0–100; 100 si ya es máx). */
  percent: number;
  /** ¿Ha alcanzado el nivel máximo? */
  isMax: boolean;
}

/** Desglose de progreso de nivel para la UI (cabecera / Progresos / Perfil). */
export function levelProgress(xp: number): LevelProgress {
  const total = Math.max(0, Math.floor(xp));
  const level = levelForXp(total);
  if (level >= MAX_LEVEL) {
    return { level: MAX_LEVEL, xpIntoLevel: 0, xpSpan: 0, percent: 100, isMax: true };
  }
  const floorXp = xpForLevel(level);
  const nextXp = xpForLevel(level + 1);
  const span = Math.max(1, nextXp - floorXp);
  const into = Math.max(0, total - floorXp);
  return {
    level,
    xpIntoLevel: into,
    xpSpan: nextXp - floorXp,
    percent: Math.min(100, Math.round((into / span) * 100)),
    isMax: false,
  };
}
