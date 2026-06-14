/**
 * Une nombres de clase ignorando valores vacíos/falsy.
 * Ej: cn("btn", isActive && "btn--active") => "btn btn--active"
 */
export function cn(...classes: Array<string | false | null | undefined>): string {
  return classes.filter(Boolean).join(" ");
}

/** Limita un número al rango [min, max]. */
export function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
