# CertDeck — Implementación

> Fase 5 del Spec Driven Development. Bitácora de lo implementado por iteración, con archivos, artefactos, decisiones, supuestos, riesgos, **instrucciones manuales para el propietario** y checklist de validación. Se rige por la [Constitución](01-constitution.md), [Requisitos](02-requirements.md), [Roadmap](03-roadmap.md) y [Tareas](04-tasks.md).

- **Estado:** En progreso
- **Versión:** 1.0.0
- **Fecha:** 2026-06-15
- **Fase Spec Driven Development:** 5 — Implementación

---

## Iteración v0 — Fundaciones (2026-06-15)

### 1. Resumen
Esqueleto técnico del frontend (Next.js App Router + TypeScript estricto + Capacitor) con **static export (SPA)** según [ADR 0003](decisions/0003-render-strategy.md), design tokens (paleta azul/celeste/blanco), componentes UI base, cliente Supabase centralizado, consumo de sesión (solo lectura) y runner de tests. Se entrega además el primer script SQL de **contenido** (no aplicado). Verificado en local: typecheck, lint, tests y build de export en verde.

### 2. Fase / tareas cubiertas
Roadmap **v0**; tareas T-v0-001 … T-v0-011 (T-v0-010 SQL incluida; ver §6).

### 3. Archivos creados — Frontend (`app/`)
- **Config:** `package.json`, `tsconfig.json`, `next.config.ts` (`output: 'export'`), `capacitor.config.ts` (`webDir: 'out'`), `.eslintrc.json`, `.prettierrc.json`, `vitest.config.ts`, `.gitignore`, `README.md`.
- **Entorno:** `app/.env` (no versionado), `app/.env.example` (plantilla con variantes `VITE_` y `NEXT_PUBLIC_`).
- **App Router:** `src/app/layout.tsx`, `src/app/page.tsx` (Inicio, esqueleto).
- **Estilos:** `styles/tokens.css`, `styles/globals.css`.
- **UI base:** `components/ui/BigButton.tsx`, `Card.tsx`, `MobileLayout.tsx`, `ScreenHeader.tsx`, `States.tsx` (+ `.module.css`) y `index.ts`.
- **Datos/sesión:** `lib/env.ts`, `lib/supabase/client.ts`, `lib/auth/session.ts`, `hooks/useSession.ts`.
- **Utilidades + tests:** `lib/utils.ts`, `lib/__tests__/utils.test.ts`.

### 4. Archivos de documentación creados/actualizados
- Creados: `docs/decisions/0003-render-strategy.md`, este `docs/05-implementation.md`.
- (En iteraciones previas: ADR 0001/0002, fases 01–04.)

### 5. Decisiones técnicas
- **ADR 0003:** static export (SPA) para compatibilidad total con Capacitor; sin Server Actions/Route Handlers/middleware; datos en cliente.
- **Env perezoso y literal:** `lib/env.ts` valida con getters y accede a `process.env.NEXT_PUBLIC_*` de forma literal (requisito de Next para inyectar en el bundle); no rompe el build si falta el entorno.
- **CSS Modules + design tokens** en CSS variables (sin dependencia de framework de estilos).
- **Cliente Supabase singleton** centralizado; ningún componente accede a Supabase por su cuenta.

### 6. Scripts SQL generados
- `supabase/sql/script-001.sql` — esquema de **contenido** (`certdeck_courses`, `certdeck_stages`, `certdeck_topics`, `certdeck_lessons`, `certdeck_lesson_screens`): PK/FK, constraints (CHECK de `lesson_type`, `difficulty`, unicidad por `position`), índices, trigger `certdeck_set_updated_at` y **RLS de solo lectura del contenido publicado** para usuarios autenticados. Todas las tablas con prefijo `certdeck_` (Constitución §7/§12.2). **No ejecutado** por el agente.

### 7. Edge Functions generadas
- Ninguna en v0. (Las Edge Functions de login/registro presentes en `supabase/functions/` son **preexistentes y compartidas**; no se han creado ni modificado — Constitución §4.)

### 8. Verificación realizada (local)
| Comprobación | Comando | Resultado |
|---|---|---|
| Tipos | `npm run typecheck` | ✅ sin errores |
| Lint | `npm run lint` | ✅ sin warnings/errores |
| Tests | `npm run test` | ✅ 3/3 |
| Build export | `npm run build` | ✅ genera `out/` (index.html, _next/…) |

### 9. Instrucciones manuales para el propietario
1. **Entorno:** confirma `app/.env` con `NEXT_PUBLIC_SUPABASE_URL` y `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (ya configuradas).
2. **Arranque local:**
   ```bash
   cd app
   npm install
   npm run dev
   ```
3. **SQL `script-001.sql`** (cuando se entregue): **revísalo** y aplícalo tú en Supabase (SQL Editor o tu flujo habitual). El agente **no** lo ejecuta.
4. **Capacitor (opcional, más adelante):** `npm run build` → `npx cap sync`.

### 10. Advertencias / riesgos
- **RT-03 (futuro):** la lógica de repaso/desbloqueo se duplicará conceptualmente cliente/servidor (ADR 0002); mantener sincronizada con tests compartidos.
- `npm audit` reporta vulnerabilidades transitivas del toolchain de build (no afectan a producción del bundle); revisar antes de releases.
- Las Edge Functions de login/registro son intocables (Constitución §4).

### 11. Pasos pendientes (cierre de v0 → v1)
- [x] Entregar `supabase/sql/script-001.sql` (esquema de contenido) — tarea T-v0-010.
- [ ] Que el propietario revise y aplique `script-001.sql` en Supabase.
- [ ] Pantallas de navegación con datos de prueba (catálogo → tema) — inicio de v1.

### 12. Checklist de validación v0
- [x] `app/` arranca y compila.
- [x] Variables `NEXT_PUBLIC_*` leídas.
- [x] Componentes UI base renderizan (build de export OK).
- [x] Runner de tests operativo.
- [x] `script-001.sql` entregado (comentado, con FKs/índices/constraints/RLS).
- [ ] `script-001.sql` revisado y aplicado por el propietario.

---

## Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-15 | Bitácora inicial con iteración v0 (fundaciones del frontend). |
