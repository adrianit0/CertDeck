"use client";

import { useEffect, useState } from "react";
import { getStoredTheme, setTheme as persistTheme, type Theme } from "@/lib/theme";

/**
 * Lee y controla el tema. El estado inicial se sincroniza tras el montaje con
 * la preferencia guardada (la clase `.dark` ya la fija el script de layout, así
 * que no hay parpadeo de tema, solo del control del toggle).
 */
export function useTheme() {
  const [theme, setThemeState] = useState<Theme>("light");

  useEffect(() => {
    setThemeState(getStoredTheme());
  }, []);

  const setTheme = (next: Theme) => {
    persistTheme(next);
    setThemeState(next);
  };

  const toggle = () => setTheme(theme === "dark" ? "light" : "dark");

  return { theme, isDark: theme === "dark", setTheme, toggle };
}
