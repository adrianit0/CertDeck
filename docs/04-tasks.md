# CertDeck — Tareas

> Fase 4 del Spec Driven Development. Descompone la [Hoja de ruta](03-roadmap.md) en tareas accionables, agrupadas por versión, con tipo, archivos afectados, requisitos cubiertos y checklist por iteración. Se rige por la [Constitución](01-constitution.md), los [Requisitos](02-requirements.md) y los ADR [0001](decisions/0001-estructura-de-carpetas.md)/[0002](decisions/0002-logica-desbloqueo-y-repaso.md).

- **Estado:** Borrador para aprobación (Fase 4)
- **Versión:** 1.0.0
- **Fecha:** 2026-06-15
- **Fase Spec Driven Development:** 4 — Tareas
- **Depende de:** Fases 1–3 (aprobadas)

---

## 1. Convenciones

- **ID de tarea:** `T-<vNN>-<NNN>` (p. ej. `T-v0-001`).
- **Tipo:** `frontend` · `backend` (Edge Function) · `sql` · `testing` · `docs` · `infra` (config) · `chore`.
- **Estado:** ☐ pendiente · ◐ en progreso · ☑ hecho.
- **Recordatorio crítico (Constitución §4):** el agente **no** ejecuta SQL, **no** despliega Edge Functions, **no** usa la CLI de Supabase ni toca login/registro. Toda tarea `sql`/`backend` termina en un **archivo entregado** + **instrucciones manuales** para el propietario.
- Cada tarea referencia los requisitos que cubre (`RF-`, `RN-`, etc.).
- **Nomenclatura (Constitución §7/§12.2):** todas las tablas SQL llevan prefijo **`certdeck_`** (p. ej. `certdeck_flashcard_questions`, `certdeck_user_lesson_progress`) y las Edge Functions nuevas el prefijo **`certdeck-`**. Aquí algunos nombres de tabla se citan sin prefijo por brevedad; en SQL siempre lo llevan.

---

## 2. v0 — Fundaciones

### 2.1 Frontend / Infra
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v0-001 | docs | ADR 0003: estrategia de renderizado Next.js + Capacitor (SSR vs export estático/SPA) | `docs/decisions/0003-render-strategy.md` | RT-01 |
| T-v0-002 | infra | Scaffold Next.js + TypeScript estricto, estructura por features | `app/package.json`, `app/tsconfig.json`, `app/next.config.*`, `app/src/`, `app/components/`, `app/features/`, `app/lib/`, `app/hooks/`, `app/styles/` | Const. §8 |
| T-v0-003 | infra | Configuración base de Capacitor | `app/capacitor.config.ts` | RM-03 |
| T-v0-004 | infra | Lint + formato + scripts (`dev`, `build`, `test`, `lint`) | `app/.eslintrc*`, `app/.prettierrc*`, `app/package.json` | RNF-08 |
| T-v0-005 | frontend | Design tokens (paleta azul/celeste/blanco) y tema | `app/styles/tokens.*`, `app/styles/globals.*` | RM-01, RA-01, UX §10 |
| T-v0-006 | frontend | Componentes UI base: `BigButton`, `Card`, `MobileLayout`, `ScreenHeader`, estados de carga/error | `app/components/ui/*` | RA-02, RNF-02 |
| T-v0-007 | frontend | Cliente Supabase centralizado (lee `NEXT_PUBLIC_*`) | `app/lib/supabase/client.ts` | RNF-13, RSP-05 |
| T-v0-008 | frontend | Hook de sesión que consume el login existente (solo lectura de sesión) | `app/lib/auth/session.ts`, `app/hooks/useSession.ts` | RSP-06 |
| T-v0-009 | testing | Configurar runner de tests (unitarios) | `app/vitest.config.*` o equivalente | RNF-09 |

### 2.2 SQL
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v0-010 | sql | Esquema de **contenido**: `courses`, `stages`, `topics`, `lessons`, `lesson_screens` (PK, FK, `position`, `is_published`, `created_at`/`updated_at`, índices, CHECK de `lesson_type`) | `supabase/sql/script-001.sql` | RF-01…RF-12, RN-01…RN-03 |
| T-v0-011 | docs | Instrucciones de revisión/aplicación manual de `script-001.sql` | `docs/05-implementation.md` | Const. §7 |

### 2.3 Checklist v0
- ☐ ADR 0003 decidido antes de construir pantallas.
- ☐ `app/` arranca en local (`dev`) y compila (`build`).
- ☐ Variables `NEXT_PUBLIC_*` leídas correctamente.
- ☐ Componentes UI base renderizan en viewport móvil.
- ☐ `script-001.sql` entregado, comentado y con instrucciones (no ejecutado por el agente).

---

## 3. v1 — MVP (recorrido de aprendizaje)

### 3.1 SQL
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-001 | sql | Tablas de preguntas: `flashcard_questions`, `exam_questions` (constraints: `type_id ∈ {1,2}`, `correct_answers_count`, índices por FK) | `supabase/sql/script-002.sql` | RF-19…RF-29, RN-09…RN-12 |
| T-v1-002 | sql | Tablas de progreso `user_lesson_progress`, `user_question_attempts` + **RLS** (`auth.uid() = user_id`) + CHECK de enums (`status`, `exercise_type`, `question_source`) | `supabase/sql/script-002.sql` (mismo script o `script-002b`) | RF-31/32, RN-18…RN-20, RSP-01/02 |
| T-v1-003 | sql | **Seed** de ejemplo: 1 curso, 1 etapa, 1–2 temas, lecciones y preguntas variadas | `supabase/sql/script-003.sql` | D-02 |

### 3.2 Backend (Edge Functions nuevas)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-004 | backend | `certdeck-progress-complete-lesson`: valida fin de lección, calcula score, persiste progreso, desbloqueo lineal (autoritativo, ADR 0002) + doc (env, payload, respuesta, errores, despliegue) | `supabase/functions/certdeck-progress-complete-lesson/index.ts` | RF-30/31, RF-35/36, RN-18/19 |

### 3.3 Frontend — datos y lógica
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-005 | frontend | Servicios de contenido (cursos/etapas/temas/lecciones/pantallas) | `app/features/content/*`, `app/lib/queries/*` | RF-01…RF-08 |
| T-v1-006 | frontend | Utilidad de **barajado** de respuestas (Fisher–Yates) reutilizable | `app/lib/shuffle.ts` | RN-09/10 |
| T-v1-007 | frontend | Motor de cola de ejercicios de lección (orden + reencolado "Incorrecto") | `app/features/lesson/engine/*` | RF-09, RF-15, RN-17 |
| T-v1-008 | testing | Tests del barajado y del motor de cola | `app/lib/__tests__/*`, `app/features/lesson/engine/__tests__/*` | RNF-09 |

### 3.4 Frontend — pantallas (RF §12 de Requisitos)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-009 | frontend | Inicio | `app/src/app/page.tsx` | UX |
| T-v1-010 | frontend | Catálogo de cursos | `app/features/content/screens/Catalog*` | RF-01 |
| T-v1-011 | frontend | Detalle de curso + Etapas | `.../CourseDetail*`, `.../Stages*` | RF-02 |
| T-v1-012 | frontend | Temas de etapa + Resumen de tema (pantallas) | `.../Topics*`, `.../TopicSummary*` | RF-03/04/05 |
| T-v1-013 | frontend | Lecciones del tema (con estado) | `.../Lessons*` | RF-04, RF-35/36 |
| T-v1-014 | frontend | Pantalla de contenido de lección | `app/features/lesson/screens/Content*` | RF-08 |
| T-v1-015 | frontend | Ejercicio ANKI (frontal/reverso + 3 botones) | `.../exercises/AnkiCard*` | RF-13…RF-18 |
| T-v1-016 | frontend | Ejercicio test (3 respuestas) | `.../exercises/MultipleChoice*` | RF-19…RF-21 |
| T-v1-017 | frontend | Ejercicio verdadero/falso | `.../exercises/TrueFalse*` | RF-22/23 |
| T-v1-018 | frontend | Ejercicio examen (única/múltiple) | `.../exercises/Exam*` | RF-24…RF-29 |
| T-v1-019 | frontend | Resultado de lección (% aciertos/fallos, felicitación, siguiente) | `.../screens/Result*` | RF-30 |
| T-v1-020 | frontend | Práctica directa de examen | `app/features/exam-practice/*` | RF-26, Q-06 |
| T-v1-021 | frontend | Progreso del usuario (básico) | `app/features/progress/*` | RF-34 |
| T-v1-022 | frontend | Integración con `certdeck-progress-complete-lesson` + estado optimista/reconciliación | `app/features/lesson/*`, `app/lib/queries/progress.ts` | ADR 0002 |

### 3.5 Docs v1
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-023 | docs | Entrada de implementación v1 + instrucciones manuales (SQL + deploy Edge Function + env) | `docs/05-implementation.md` | Const. §11 |

### 3.6 Checklist v1
- ☐ Recorrido completo catálogo→lección con datos seed.
- ☐ Ejercicios ANKI/test/V-F/examen con respuestas **desordenadas**.
- ☐ "Incorrecto" reencola la tarjeta al final de la lección.
- ☐ Resultado muestra % y desbloquea la siguiente (lineal).
- ☐ Progreso persiste y **RLS** impide ver progreso ajeno (verificación del propietario).
- ☐ Práctica directa de examen disponible.
- ☐ `script-002/003.sql` y `certdeck-progress-complete-lesson` entregados con instrucciones (no aplicados por el agente).

---

## 4. v2 — Repaso espaciado + correcciones

### 4.1 SQL
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v2-001 | sql | `user_spaced_repetition` (`ease_factor`, `interval_days`, `repetitions`, `lapses`, `due_at`, `last_reviewed_at`) + RLS + CHECK (`ease_factor >= 1.3`) + índices (`user_id`, `due_at`) | `supabase/sql/script-004.sql` | RF-33, RN-13…RN-17, RSP-01 |

### 4.2 Lógica + Backend
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v2-002 | frontend | Módulo de configuración del algoritmo (parámetros Q-03 centralizados) | `app/lib/spaced-repetition/config.ts` | RN-16 |
| T-v2-003 | frontend | Algoritmo SM-2 simplificado como **función pura** | `app/lib/spaced-repetition/sm2.ts` | RN-13…RN-15 |
| T-v2-004 | testing | Tests exhaustivos del algoritmo (Incorrecto/Correcto/Muy fácil, límites) | `app/lib/spaced-repetition/__tests__/*` | RNF-09, RN-13…RN-16 |
| T-v2-005 | backend | `certdeck-spaced-review-update`: aplica y persiste estado de tarjeta (autoritativo) + doc | `supabase/functions/certdeck-spaced-review-update/index.ts` | RN-13…RN-17, ADR 0002 |
| T-v2-006 | backend | `certdeck-review-build-lesson`: compone repaso desde tarjetas vencidas + jerarquía + generalista por tema | `supabase/functions/certdeck-review-build-lesson/index.ts` | RF-42, RN-06 |
| T-v2-007 | frontend | Resolución de **desbloqueo avanzado** (repaso cada 3, generalista, prerequisitos) | `app/lib/unlock/*` + tests | RF-37…RF-41, RN-04…RN-08 |
| T-v2-008 | frontend | Lección `review` (UI + integración build/update) | `app/features/lesson/types/review/*` | RF-42 |
| T-v2-009 | frontend | Lección `error_correction` (activación si score < 60%, prioriza fallos) | `app/features/lesson/types/error-correction/*` | RF-41/43, RN-07 |
| T-v2-010 | frontend | Marcado de **tarjeta problemática** a 3 fallos | `app/lib/spaced-repetition/*` | RN-13/17, Q-02 |

### 4.3 Docs / Checklist v2
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v2-011 | docs | Entrada de implementación v2 + instrucciones manuales | `docs/05-implementation.md` | Const. §11 |

- ☐ `due_at`/`interval_days`/`ease_factor` evolucionan según Q-03 (tests verdes).
- ☐ Repasos cada 3 lecciones + generalista por tema con preguntas vencidas/previas.
- ☐ Score < 60% activa/ofrece corrección centrada en fallos.
- ☐ Tarjeta problemática a los 3 fallos.
- ☐ `script-004.sql` + Edge Functions entregadas con instrucciones.

---

## 5. v3 — Examen avanzado + progreso enriquecido

| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v3-001 | frontend | Examen múltiple con validación de **conjunto exacto** (UI + reglas) | `app/features/lesson/types/exam/*` | RF-29, RN-11 |
| T-v3-002 | backend | Validación autoritativa de examen múltiple (opcional, anti-trampa) | `supabase/functions/certdeck-exam-grade/index.ts` | RF-29, RSP-03 |
| T-v3-003 | frontend | Práctica de examen con filtros (curso/tema/dificultad) + `extra_information` | `app/features/exam-practice/*` | RF-26 |
| T-v3-004 | frontend | Progreso enriquecido (avance por curso/tema, vencidas/pendientes, históricos) | `app/features/progress/*` | RF-34 |
| T-v3-005 | frontend | Lecciones `expansion` y `final` | `app/features/lesson/types/{expansion,final}/*` | RF-44/45 |
| T-v3-006 | docs | Revisión Q-06 (¿examen alimenta repaso?) + ADR si cambia | `docs/decisions/*`, `docs/05-implementation.md` | Q-06 |

---

## 6. v4+ — Pulido y futuro

| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v4-001 | testing | Auditoría de accesibilidad (AA) en pantallas clave | `app/**` | RA-01…RA-06 |
| T-v4-002 | infra | Build Capacitor probado en dispositivo | `app/**`, `capacitor.config.ts` | RM-03 |
| T-v4-003 | frontend | Gamificación ligera (rachas) — opcional | `app/features/streaks/*` | RP-* |
| T-v4-004 | docs | Preparación premium/multiusuario (sin pagos) | `docs/decisions/*` | RSP-07 |
| T-v4-005 | infra | i18n base | `app/lib/i18n/*` | RNF-16 |

---

## 7. Resumen de artefactos a entregar (no aplicados por el agente)

**Scripts SQL previstos** (numeración incremental, archivos nuevos):
- `script-001.sql` — contenido (v0)
- `script-002.sql` — preguntas + progreso + RLS (v1)
- `script-003.sql` — seed de ejemplo (v1)
- `script-004.sql` — repetición espaciada (v2)

**Edge Functions nuevas previstas:**
- `certdeck-progress-complete-lesson` (v1)
- `certdeck-spaced-review-update` (v2)
- `certdeck-review-build-lesson` (v2)
- `certdeck-exam-grade` (v3, opcional)

> Recordatorio: cada uno se entrega como **archivo + instrucciones manuales** en `docs/05-implementation.md`. El propietario los revisa, aplica/despliega y configura el entorno.

---

## 8. Criterios de aceptación de las Tareas (Fase 4)

Aprobada cuando el propietario confirma:
1. La descomposición cubre los requisitos y la hoja de ruta.
2. La asignación de archivos y tipos es razonable.
3. Los checklists por versión son válidos como Definición de terminado operativa.
4. La lista de artefactos SQL/Edge Functions a entregar es correcta.

> Tras la aprobación se pasa a **Fase 5 — Implementación**, empezando por **v0** (T-v0-001: ADR 0003 de estrategia de renderizado).

---

## 9. Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-15 | Versión inicial de Tareas (Fase 4). Pendiente de aprobación. |
