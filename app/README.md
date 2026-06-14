# CertDeck — App (frontend)

Aplicación **mobile-first** de estudio de certificaciones con repaso espaciado.
Stack: **React + Next.js (App Router) + Capacitor**, TypeScript estricto.

> Estrategia de renderizado: **static export (SPA)** — ver `docs/decisions/0003-render-strategy.md`.

## Requisitos

- Node 20+ (probado con Node 24).
- Variables de entorno en `app/.env` (copia `app/.env.example`).

## Puesta en marcha

```bash
npm install
npm run dev        # desarrollo en http://localhost:3000
npm run build      # genera el export estático en ./out
npm run typecheck  # comprobación de tipos
npm run lint       # ESLint
npm run test       # tests unitarios (Vitest)
```

## Capacitor (móvil)

```bash
npm run build      # genera ./out (webDir de Capacitor)
npx cap sync
```

## Restricciones por el export estático (ADR 0003)

Con `output: 'export'` **NO** se pueden usar en la app:

- Server Actions.
- Route Handlers (`app/**/route.ts`).
- `middleware.ts`.
- Data fetching en Server Components en tiempo de request.

Todo el acceso a datos es **en cliente** vía `app/lib/supabase`. La lógica de
servidor (desbloqueo/repaso autoritativos) vive en **Edge Functions de Supabase**.

## Estructura

```txt
app/
├── src/app/        # rutas (App Router): layout, page, …
├── components/ui/  # componentes UI reutilizables (BigButton, Card, …)
├── features/       # módulos por dominio (cursos, lecciones, … — desde v1)
├── hooks/          # hooks reutilizables (useSession, …)
├── lib/            # supabase, auth, utils, lógica pura
└── styles/         # design tokens + estilos globales
```
