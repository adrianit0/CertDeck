import type { NextConfig } from "next";

/**
 * CertDeck — configuración de Next.js.
 *
 * Estrategia de renderizado: STATIC EXPORT (SPA) — ver ADR 0003.
 * El bundle estático (carpeta `out/`) sirve tanto para web como para Capacitor.
 *
 * Restricciones derivadas de `output: 'export'` (NO usar en la app):
 *  - Server Actions, Route Handlers (`route.ts`), `middleware.ts`.
 *  - Data fetching en Server Components en tiempo de request.
 * Todo acceso a datos se hace en cliente vía `app/lib/supabase`.
 */
const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: {
    // El optimizador de imágenes requiere servidor; en export estático debe desactivarse.
    unoptimized: true,
  },
  // Carpeta de salida del export (la usa Capacitor como webDir).
  distDir: ".next",
};

export default nextConfig;
