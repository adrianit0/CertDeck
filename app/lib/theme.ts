"use client";

/**
 * Tema claro/oscuro. La preferencia se persiste en localStorage y se aplica
 * como clase `.dark` en <html> (estrategia por clase de Tailwind v4; ver
 * styles/globals.css). El script anti-parpadeo de `layout.tsx` aplica la clase
 * antes del primer render.
 */

export type Theme = "light" | "dark";

const STORAGE_KEY = "certdeck:theme";

export function getStoredTheme(): Theme {
  if (typeof window === "undefined") return "light";
  try {
    return window.localStorage.getItem(STORAGE_KEY) === "dark" ? "dark" : "light";
  } catch {
    return "light";
  }
}

export function applyTheme(theme: Theme): void {
  if (typeof document === "undefined") return;
  document.documentElement.classList.toggle("dark", theme === "dark");
}

export function setTheme(theme: Theme): void {
  try {
    window.localStorage.setItem(STORAGE_KEY, theme);
  } catch {
    // Sin persistencia (modo privado, etc.): aplicamos solo en memoria.
  }
  applyTheme(theme);
}
