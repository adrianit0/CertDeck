# ADR 0003 — Estrategia de renderizado: Next.js static export (SPA) para Capacitor

- **Estado:** Aceptada
- **Fecha:** 2026-06-15
- **Fase:** 5 — Implementación (v0, tarea T-v0-001)
- **Decisores:** Propietario del proyecto (vía aprobación de v0)
- **Relacionado:** [Constitución](../01-constitution.md) §8; [Roadmap](../03-roadmap.md) RT-01; RM-03, RNF-01/03

## Contexto

CertDeck debe ejecutarse como **app móvil híbrida con Capacitor** (RM-03) y también como web (RNF-03), sobre **React + Next.js** (Constitución §8). Next.js ofrece varios modos de renderizado:

- **SSR / Server Components con servidor Node** (App Router por defecto).
- **ISR / rutas dinámicas en el servidor**.
- **Static export** (`output: 'export'`): genera HTML/CSS/JS estáticos sin servidor Node.

Capacitor empaqueta un conjunto de **assets web estáticos** dentro de la app nativa y los sirve desde un WebView local: **no hay un servidor Node en el dispositivo**. Por tanto, cualquier funcionalidad que dependa de SSR en tiempo de petición, route handlers de Next, middleware o Server Actions **no está disponible** en el empaquetado móvil.

Además, la autenticación (login/registro) y los datos viven en **Supabase**, accesibles directamente desde el cliente mediante el SDK y RLS. El backend propio se limita a **Edge Functions** desplegadas en Supabase (no en Next).

## Decisión

CertDeck se construye como **Single Page Application estática** usando **Next.js App Router con `output: 'export'`**:

1. `next.config` con `output: 'export'` e `images.unoptimized: true` (el optimizador de imágenes requiere servidor).
2. **Toda obtención de datos es en cliente** (`"use client"` + SDK de Supabase desde `app/lib/supabase`), no Server Components con fetch en servidor, ni Route Handlers, ni Server Actions, ni middleware.
3. **Sin rutas dinámicas dependientes de servidor**: los detalles (curso/tema/lección) se resuelven en cliente leyendo el `id`/`slug` desde la URL (query/segmento estático) y consultando Supabase. Si se usan segmentos dinámicos, se acompañan de `generateStaticParams` o se sustituyen por navegación con estado/query.
4. El mismo bundle estático sirve para **web** (hosting estático) y para **Capacitor** (`webDir` apuntando al `out/` exportado).
5. La lógica autoritativa (desbloqueo/repaso, ADR 0002) vive en **Edge Functions de Supabase**, coherente con que no hay backend Node propio.

## Alternativas consideradas

1. **SSR con servidor Node.** Rechazada: incompatible con el empaquetado Capacitor (no hay Node en el dispositivo); obligaría a un backend separado solo para SSR, sin beneficio para esta app de sesión autenticada.
2. **Next.js híbrido (algunas rutas SSR, otras estáticas).** Rechazada: complejidad y divergencia entre el build web y el build móvil; riesgo de usar features no exportables por error.
3. **Cambiar a Vite + React SPA puro.** Considerada (encaja con las variables `VITE_` ya presentes), pero rechazada para respetar el stack Next.js de la Constitución. Las variables `VITE_` se mantienen por compatibilidad; el frontend usa `NEXT_PUBLIC_*`.
4. **Next.js static export (SPA).** **Elegida**: cumple el stack, es 100% compatible con Capacitor y con hosting estático, y centraliza la lógica de servidor en Edge Functions.

## Consecuencias

**Positivas:**
- Un único artefacto estático para web y móvil.
- Sin servidor propio que mantener; backend = Supabase + Edge Functions.
- Despliegue web trivial (cualquier hosting estático/CDN).

**Negativas / restricciones a respetar:**
- **Prohibido** en el código de la app: Server Actions, Route Handlers (`app/**/route.ts`), `middleware.ts`, y data fetching en Server Components en tiempo de request. Se documenta como guardarraíl en `app/` (lint/convención).
- Las imágenes no pasan por el optimizador de Next (`unoptimized`).
- El SEO por SSR no aplica (irrelevante: app autenticada tras login).
- Las rutas dinámicas requieren `generateStaticParams` o resolución en cliente.

## Notas de implementación (v0)

- `app/next.config.ts`: `output: 'export'`, `images.unoptimized: true`, `trailingSlash: true` (mejor compatibilidad con WebView/hosting estático).
- `app/capacitor.config.ts`: `webDir: 'out'`.
- Estructura de datos en cliente vía `app/lib/supabase/client.ts` y hooks en `app/hooks/`.
- Añadir nota en el README de `app/` recordando las restricciones de export estático.
