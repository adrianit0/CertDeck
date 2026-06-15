"use client";

import { useEffect, useState } from "react";

/**
 * Estado de conectividad del dispositivo (ADR 0006).
 *
 * Como no hay persistencia local del progreso, necesitamos saber si hay red
 * para: (a) mostrar el aviso de "sin conexión" y (b) bloquear el inicio de
 * nuevas lecciones/repasos hasta recuperarla. Se basa en `navigator.onLine` y
 * en los eventos `online`/`offline`.
 */
export function useOnline(): boolean {
  // En SSR/primer render asumimos online para no parpadear el aviso.
  const [online, setOnline] = useState(true);

  useEffect(() => {
    const update = () => setOnline(navigator.onLine);
    update();
    window.addEventListener("online", update);
    window.addEventListener("offline", update);
    return () => {
      window.removeEventListener("online", update);
      window.removeEventListener("offline", update);
    };
  }, []);

  return online;
}
