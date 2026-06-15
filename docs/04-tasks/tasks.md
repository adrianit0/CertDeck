# CertDeck — Tareas

> Fase 4 del Spec Driven Development. Descompone la [Hoja de ruta](../03-roadmap/roadmap.md) en tareas accionables, agrupadas por versión, con tipo, archivos afectados, requisitos cubiertos y checklist por iteración. Se rige por la [Constitución](../01-constitution/constitution.md), los [Requisitos](../02-requirements/requirements.md) y los ADR [0001](../00-decisions/0001-estructura-de-carpetas.md)/[0002](../00-decisions/0002-logica-desbloqueo-y-repaso.md).

- **Estado:** Borrador para aprobación (Fase 4)
- **Versión:** 1.1.0
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
| T-v0-001 | docs | ADR 0003: estrategia de renderizado Next.js + Capacitor (SSR vs export estático/SPA) | `docs/00-decisions/0003-render-strategy.md` | RT-01 |
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
| T-v0-011 | docs | Instrucciones de revisión/aplicación manual de `script-001.sql` | `docs/05-implementation/implementation.md` | Const. §7 |

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
| T-v1-023 | docs | Entrada de implementación v1 + instrucciones manuales (SQL + deploy Edge Function + env) | `docs/05-implementation/implementation.md` | Const. §11 |

### 3.6 Checklist v1
- ☐ Recorrido completo catálogo→lección con datos seed.
- ☐ Ejercicios ANKI/test/V-F/examen con respuestas **desordenadas**.
- ☐ "Incorrecto" reencola la tarjeta al final de la lección.
- ☐ Resultado muestra % y desbloquea la siguiente (lineal).
- ☐ Progreso persiste y **RLS** impide ver progreso ajeno (verificación del propietario).
- ☐ Práctica directa de examen disponible.
- ☐ `script-002/003.sql` y `certdeck-progress-complete-lesson` entregados con instrucciones (no aplicados por el agente).

---

## 3bis. v1 — Revisión UX / navegación / composición (rev. Requisitos 1.2.0)

> Estas tareas **sustituyen/ajustan** parte del frontend ya creado en v1 según ADR 0004/0005. Solo se documentan; la implementación va después de aprobar esta revisión.

### 3bis.1 Navegación y app shell (ADR 0004)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-024 | frontend | Barra de navegación inferior (Cursos/Repasos/Progresos/Perfil) | `app/components/nav/BottomNav.tsx`, layout | RF-01, RF-47…49b |
| T-v1-025 | frontend | Contexto de **curso/etapa activos** + persistencia (localStorage MVP) | `app/features/active/*` | RF-02/03, RN-27 |
| T-v1-026 | frontend | Pestaña Cursos: selector curso/etapa arriba + **catálogo de la etapa** (temas `[Nombre]` + lecciones) | `app/features/content/StageCatalog*` | RF-03/04/05 |
| T-v1-027 | frontend | Quitar resumen del listado de tema; pulsar tema → leer contenido | `app/features/content/*` | RF-05 |
| T-v1-028 | frontend | Pestañas Repasos y Perfil (estructura) | `app/src/app/reviews`, `app/src/app/profile` | RF-48, RF-49b |

### 3bis.2 Lección a pantalla completa (RF-50…53)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-029 | frontend | Ocultar barra inferior dentro de la lección | layout / LessonScreen | RF-50 |
| T-v1-030 | frontend | Anclar todos los botones abajo; ANKI con botones de **igual ancho** | `app/features/lesson/*`, `lesson.module.css` | RF-18/51 |
| T-v1-031 | frontend | Contenido: fuente mayor + espaciado + render de **Markdown negrita** (`**…**`) | `app/lib/markdown.ts` (+test), `LessonPlayer` | RF-52/53 |

### 3bis.3 Ronda de corrección (RF-29a…e, RN-17)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-032 | frontend | Motor de lección con **pasada principal + ronda de corrección** (pantalla motivacional; 2.º fallo no repite y se registra) | `app/features/lesson/engine/*` (+tests), `LessonPlayer` | RF-29a…e |

### 3bis.4 Base de examen
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-033 | frontend | Componentes de examen (única/múltiple) y "lecciones de preguntas" (sin datos) | `app/features/lesson/exercises/Exam*` | RF-24…29 |

### 3bis.5 Contenido
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-034 | sql | **Revisar** fragmento de contenido: quitar preguntas autoradas de L4 (review) y L5 (final) | `supabase/sql_contenido/20260515_02_aws-saa-c03.sql` | ADR 0005 |

---

## 3ter. v1 — Migración de persistencia a BD (ADR 0006)

> Elimina toda persistencia local del **progreso** (`certdeck:progress`) y la traslada a la BD como única fuente de verdad, con estado optimista **en memoria** + write-through y manejo de red (banner + bloqueo de nueva lección). El tema (`certdeck:theme`) y la sesión (JWT) **siguen siendo locales**. SQL/Edge entregados, **no** aplicados por el agente (§4).

### 3ter.1 SQL
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-035 | sql | `certdeck_user_lesson_progress`: **+columnas** `xp`, `anki_count` (CHECK `>= 0`) | `supabase/sql/script-005.sql` | ADR 0006, RF-30 |
| T-v1-036 | sql | **Nueva** `certdeck_user_review_sessions` (xp/total/correct/anki por sesión de repaso) + índices + RLS propia | `supabase/sql/script-005.sql` | ADR 0006, RN-13…17 |
| T-v1-037 | sql | **Nueva** `certdeck_user_failed_questions` (`unique(user_id, question_id)`, lesson_id) + RLS (select/insert/delete propios) | `supabase/sql/script-005.sql` | ADR 0006, RN-17 |

### 3ter.2 Backend (Edge Functions)
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-038 | backend | **Nueva** `certdeck-progress-get` (GET): ensambla y devuelve el `ProgressState` completo (lecciones + review agregado + failed + días activos) | `supabase/functions/certdeck-progress-get/` | ADR 0006 |
| T-v1-039 | backend | **Modificar** `certdeck-progress-complete-lesson`: persistir `xp`/`anki_count` y reconciliar `failed_questions` (alta fallos / baja recuperados) | `supabase/functions/certdeck-progress-complete-lesson/index.ts` | ADR 0006 |
| T-v1-040 | backend | **Nueva** `certdeck-progress-record-review` (POST): inserta sesión de repaso + reconcilia `failed_questions` | `supabase/functions/certdeck-progress-record-review/` | ADR 0006 |
| T-v1-041 | backend | **Nueva** `certdeck-progress-reset` (POST): borra todo el progreso del usuario | `supabase/functions/certdeck-progress-reset/` | ADR 0006 |

### 3ter.3 Frontend
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-042 | frontend | **Eliminar** `localProgress.ts` (persistencia en disco); mover las funciones puras (estado de desbloqueo, racha, stats) a un módulo sin `localStorage` | `app/lib/progress/*` | ADR 0006 |
| T-v1-043 | frontend | `lib/queries/progress.ts`: `getProgress`/`completeLesson`/`recordReview`/`resetProgress` contra las Edge Functions | `app/lib/queries/progress.ts` | ADR 0006 |
| T-v1-044 | frontend | `AppShell`: cargar progreso de BD al montar/cambiar sesión; estado optimista **en memoria**; write-through | `app/features/shell/AppShell.tsx` | ADR 0006, RNF-02 |
| T-v1-045 | frontend | Detección de red + **banner de "sin conexión"** y **bloqueo de iniciar lección/repaso** offline | `app/features/shell/*`, `app/hooks/useOnline.ts` | ADR 0006 |

### 3ter.4 Docs
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v1-046 | docs | ADR 0006 + instrucciones manuales de `script-005.sql` y despliegue de Edge Functions | `docs/00-decisions/0006-*.md`, `docs/05-implementation/implementation.md` | §4 |

---

## 4. v2 — Repaso espaciado + correcciones

### 4.1 SQL
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| ☑ T-v2-001 | sql | `certdeck_user_spaced_repetition` (`ease_factor`, `interval_days`, `repetitions`, `lapses`, `is_problematic`, `due_at`, `last_reviewed_at`) + RLS + CHECK (`ease_factor >= 1.3`) + índices (`user_id`, `(user_id, due_at)`) | `supabase/sql/script-006.sql` *(el 004 se reutilizó para otra cosa)* | RF-33, RN-13…RN-17, RSP-01 |

### 4.2 Lógica + Backend
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| ☑ T-v2-002 | frontend | Parámetros Q-03 centralizados y **ajustables** (`DEFAULT_SRS_PARAMS`) | `app/lib/srs.ts` | RN-16 |
| ☑ T-v2-003 | frontend | Algoritmo SM-2 simplificado como **función pura** (`reviewCard`/`initialCardState`/`isCardDue`) | `app/lib/srs.ts` | RN-13…RN-15 |
| ☑ T-v2-004 | testing | Tests exhaustivos del algoritmo (Incorrecto/Correcto/Muy fácil, límites, problemática) — 12 casos | `app/lib/__tests__/srs.test.ts` | RNF-09, RN-13…RN-16 |
| ☑ T-v2-005 | backend | `certdeck-spaced-review-update`: aplica y persiste estado de tarjeta (autoritativo) + doc | `supabase/functions/certdeck-spaced-review-update/index.ts` | RN-13…RN-17, ADR 0002 |
| ☑ T-v2-006 | backend | Composición de `review`/`final`/`error_correction` desde **tarjetas vencidas** (SM-2), **reemplazando** el modo posicional. *Integrada en `certdeck-playable-lesson`* (sin endpoint aparte, para evitar un viaje de red) | `supabase/functions/certdeck-playable-lesson/index.ts` | RF-42…45, RN-21…26 |
| ◐ T-v2-007 | frontend | **Desbloqueo avanzado** (repaso cada 3, generalista): hoy cubierto por autoría de contenido + desbloqueo lineal; resolución algorítmica dedicada pendiente | `app/lib/unlock/*` + tests | RF-37…RF-41, RN-04…RN-08 |
| ☑ T-v2-008 | frontend | Lección `review` (cableado build/update vía `getPlayableLesson` + `submitCardReviews`) | `app/features/shell/LessonPlayer.tsx`, `AppShell.tsx` | RF-42 |
| ☑ T-v2-009 | frontend | `error_correction`: oferta si score < 60% (banner que lanza repaso de errores) + composición que prioriza fallos | `app/features/shell/{AppShell,CoursesTab}.tsx` | RF-41/43, RN-07 |
| ☑ T-v2-010 | backend | Marcado de **tarjeta problemática** a 3 fallos (persistido en `is_problematic`) | `app/lib/srs.ts`, `certdeck-spaced-review-update` | RN-13/17, Q-02 |

### 4.3 Docs / Checklist v2
| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v2-011 | docs | Entrada de implementación v2 + instrucciones manuales | `docs/05-implementation/implementation.md` | Const. §11 |

- ☑ `due_at`/`interval_days`/`ease_factor` evolucionan según Q-03 (tests verdes, v2.1) y se **persisten** (v2.2).
- ☑ Repasos/finales con preguntas **vencidas/previas** (composición SM-2 en `certdeck-playable-lesson`). *(La cadencia "cada 3 lecciones" se autora en el contenido.)*
- ☑ Score < 60% ofrece corrección centrada en fallos (Q-01).
- ☑ Tarjeta problemática a los 3 fallos (persistida en `is_problematic`).
- ☑ `script-006.sql` + Edge Functions (`certdeck-spaced-review-update`, `certdeck-playable-lesson`) entregadas con instrucciones.

---

## 5. v3 — Examen avanzado + progreso enriquecido

| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v3-001 | frontend | Examen múltiple con validación de **conjunto exacto** (UI + reglas) | `app/features/lesson/types/exam/*` | RF-29, RN-11 |
| T-v3-002 | backend | Validación autoritativa de examen múltiple (opcional, anti-trampa) | `supabase/functions/certdeck-exam-grade/index.ts` | RF-29, RSP-03 |
| T-v3-003 | frontend | Práctica de examen con filtros (curso/tema/dificultad) + `extra_information` | `app/features/exam-practice/*` | RF-26 |
| T-v3-004 | frontend | Progreso enriquecido (avance por curso/tema, vencidas/pendientes, históricos) | `app/features/progress/*` | RF-34 |
| T-v3-005 | frontend | Lecciones `expansion` y `final` | `app/features/lesson/types/{expansion,final}/*` | RF-44/45 |
| T-v3-006 | docs | Revisión Q-06 (¿examen alimenta repaso?) + ADR si cambia | `docs/00-decisions/*`, `docs/05-implementation/implementation.md` | Q-06 |

---

## 6. v4+ — Pulido y futuro

| ID | Tipo | Tarea | Archivos | Cubre |
|---|---|---|---|---|
| T-v4-001 | testing | Auditoría de accesibilidad (AA) en pantallas clave | `app/**` | RA-01…RA-06 |
| T-v4-002 | infra | Build Capacitor probado en dispositivo | `app/**`, `capacitor.config.ts` | RM-03 |
| T-v4-003 | frontend | Gamificación ligera (rachas) — opcional | `app/features/streaks/*` | RP-* |
| T-v4-004 | docs | Preparación premium/multiusuario (sin pagos) | `docs/00-decisions/*` | RSP-07 |
| T-v4-005 | infra | i18n base | `app/lib/i18n/*` | RNF-16 |

---

## 7. Resumen de artefactos a entregar (no aplicados por el agente)

**Scripts SQL previstos** (numeración incremental, archivos nuevos):
- `script-001.sql` — contenido (v0)
- `script-002.sql` — preguntas + progreso + RLS (v1)
- `script-003.sql` — progreso de usuario + RLS (v1)
- `script-004.sql` — limpieza del modelo de juego + `text_input` (v1)
- `script-005.sql` — migración de persistencia a BD: `xp`/`anki_count`, `certdeck_user_review_sessions`, `certdeck_user_failed_questions` (v1, ADR 0006)

**Edge Functions nuevas previstas:**
- `certdeck-progress-complete-lesson` (v1; ampliada en ADR 0006)
- `certdeck-progress-get` · `certdeck-progress-record-review` · `certdeck-progress-reset` (v1, ADR 0006)
- `certdeck-spaced-review-update` (v2)
- `certdeck-review-build-lesson` (v2)
- `certdeck-exam-grade` (v3, opcional)

> Recordatorio: cada uno se entrega como **archivo + instrucciones manuales** en `docs/05-implementation/implementation.md`. El propietario los revisa, aplica/despliega y configura el entorno.

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
| 1.1.0 | 2026-06-15 | Añadida §3bis (revisión Requisitos 1.2.0): barra inferior + curso/etapa activos (ADR 0004), lección a pantalla completa (botones abajo, fuente mayor, Markdown negrita), ronda de corrección, base de examen, revisión de contenido; v2 alineada con composición dinámica (ADR 0005). |
| 1.2.0 | 2026-06-15 | Añadida §3ter (ADR 0006): migración de la persistencia del progreso a la BD — `script-005.sql`, Edge Functions de progreso (get/record-review/reset + complete-lesson ampliada), estado optimista en memoria y manejo offline (T-v1-035…046). |
