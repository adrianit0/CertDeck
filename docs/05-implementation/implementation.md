# CertDeck — Implementación

> Fase 5 del Spec Driven Development. Bitácora de lo implementado por iteración, con archivos, artefactos, decisiones, supuestos, riesgos, **instrucciones manuales para el propietario** y checklist de validación. Se rige por la [Constitución](../01-constitution/constitution.md), [Requisitos](../02-requirements/requirements.md), [Roadmap](../03-roadmap/roadmap.md) y [Tareas](../04-tasks/tasks.md).

- **Estado:** En progreso
- **Versión:** 1.0.0
- **Fecha:** 2026-06-15
- **Fase Spec Driven Development:** 5 — Implementación

---

## Iteración v0 — Fundaciones (2026-06-15)

### 1. Resumen
Esqueleto técnico del frontend (Next.js App Router + TypeScript estricto + Capacitor) con **static export (SPA)** según [ADR 0003](../00-decisions/0003-render-strategy.md), design tokens (paleta azul/celeste/blanco), componentes UI base, cliente Supabase centralizado, consumo de sesión (solo lectura) y runner de tests. Se entrega además el primer script SQL de **contenido** (no aplicado). Verificado en local: typecheck, lint, tests y build de export en verde.

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
- Creados: `docs/00-decisions/0003-render-strategy.md`, este `docs/05-implementation/implementation.md`.
- (En iteraciones previas: ADR 0001/0002, fases 01–04.)

### 5. Decisiones técnicas
- **ADR 0003:** static export (SPA) para compatibilidad total con Capacitor; sin Server Actions/Route Handlers/middleware; datos en cliente.
- **Env perezoso y literal:** `lib/env.ts` valida con getters y accede a `process.env.NEXT_PUBLIC_*` de forma literal (requisito de Next para inyectar en el bundle); no rompe el build si falta el entorno.
- **CSS Modules + design tokens** en CSS variables (sin dependencia de framework de estilos).
- **Cliente Supabase singleton** centralizado; ningún componente accede a Supabase por su cuenta.

### 6. Scripts SQL generados
- `supabase/sql/script-001.sql` — esquema de **contenido** (`certdeck_courses`, `certdeck_stages`, `certdeck_topics`, `certdeck_lessons`, `certdeck_lesson_screens`): PK/FK, constraints (CHECK de `lesson_type`, `difficulty`, unicidad por `position`), índices, trigger `certdeck_set_updated_at` y **RLS de solo lectura del contenido publicado** para usuarios autenticados. Todas las tablas con prefijo `certdeck_` (Constitución §7/§12.2). **No ejecutado** por el agente.

**Separación de SQL (Constitución §7/§12, v1.2.0+):** el SQL estructural vive en `supabase/sql/` y el contenido de cursos en `supabase/sql_contenido/`, fragmentado con la nomenclatura `YYYYMMDD_NN_<slug>.sql` (orden alfabético = orden de ejecución, v1.3.0).

**Contenido generado:**
- `supabase/sql_contenido/20260515_01_aws-saa-c03.sql` — fragmento 01: inserta el primer curso *Amazon Solutions Architect - Associate (AWS SAA - C03)* (`slug = aws-saa-c03`, `is_published = true`), idempotente (`on conflict (slug)`). Etapas/temas/lecciones en fragmentos posteriores cuando empecemos a crear lecciones. Depende de `script-001.sql` aplicado.

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

## Iteración v1 (parcial) — Catálogo de preguntas + primer contenido (2026-06-15)

### 1. Resumen
Se habilita la **creación de lecciones con preguntas**: tablas del catálogo de preguntas y el primer contenido real del curso AWS SAA-C03 (etapa *Básico* → tema *Introduction to S3*, basado en la diapositiva 18 del Manual), con 3 lecciones normales + 1 de repaso + 1 final.

### 2. Decisión de numeración SQL
- `script-002.sql` = **catálogo de preguntas** (`certdeck_flashcard_questions`, `certdeck_exam_questions`).
- Las tablas de **progreso de usuario** (`certdeck_user_*`) se trasladan a **`script-003.sql`** (siguiente). (El antiguo "seed script-003" del roadmap queda obsoleto: el contenido vive ahora en `sql_contenido/`.)

### 3. Archivos creados
- `supabase/sql/script-002.sql` — `certdeck_flashcard_questions` (con `exercise_type`, constraints por tipo) y `certdeck_exam_questions` (type_id 1/2, answer_1..6, correct_answers_count); índices, trigger y **RLS de lectura** de preguntas activas en contenido publicado.
- `supabase/sql/script-004.sql` — **limpieza del modelo de juego**: elimina `estimated_minutes` (lecciones) y `position` + `difficulty` (flashcards); añade el tipo `text_input`; nueva clave natural `(lesson_id, question)` para idempotencia de seeds; `text_input` admitido en `certdeck_user_question_attempts`.
- `supabase/sql_contenido/20260515_02_aws-saa-c03.sql` — fragmento 02: etapa *Básico*, tema *Introduction to S3*, 5 lecciones con pantallas de contenido y preguntas variadas (ANKI / test / V-F / **respuesta escrita**). Idempotente (`on conflict` por `(lesson_id, question)`).
- `docs/06-referencias/tipos-de-ejercicio.md` — catálogo dedicado a los tipos de ejercicio (propiedades y funcionamiento).

### 4. Decisiones de diseño
- **`exercise_type` en `certdeck_flashcard_questions`:** necesario para que una misma tabla sirva a tarjeta ANKI, test de 3 respuestas, verdadero/falso y respuesta escrita (`text_input`).
- **Preguntas sin `position` ni `difficulty`:** las preguntas de una lección se extraen todas y se barajan en cliente (orden aleatorio); se prima la calidad sobre forzar un reparto por dificultad. Ver [catálogo de tipos](../06-referencias/tipos-de-ejercicio.md).
- **Jerarquía interpretada:** etapa *Básico* cubrirá S3 / AWS API / VPC; el primer **tema** es *Introduction to S3*. S3/AWS API/VPC serán temas futuros de la etapa.
- **Repaso (L4) y final (L5)** se autoría con preguntas explícitas; cuando exista `certdeck-review-build-lesson` (v2) el repaso podrá componerse dinámicamente.
- **RNF-14:** las políticas de lectura exponen la respuesta correcta al cliente (simplicidad MVP); la validación autoritativa irá en Edge Functions.

### 5. Verificación
- Sin Postgres local disponible (`psql`/`docker` ausentes): **no se ha podido ejecutar** el SQL. Revisión manual de sintaxis realizada (claves de conflicto, constraints por tipo, escape de saltos de línea con `E'...'`). **Requiere validación del propietario al aplicarlo.**

### 6. Instrucciones manuales para el propietario (orden de aplicación)
1. `supabase/sql/script-001.sql` (si aún no está aplicado).
2. `supabase/sql/script-002.sql` (catálogo de preguntas).
3. `supabase/sql_contenido/20260515_01_aws-saa-c03.sql` (curso).
4. `supabase/sql_contenido/20260515_02_aws-saa-c03.sql` (etapa + tema + lecciones).
> Todos son idempotentes y re-ejecutables. El agente no los ejecuta (Constitución §4).

### 7. Pendiente
- [ ] `script-003.sql` con tablas de progreso de usuario (`certdeck_user_*`) + RLS.
- [ ] Pantallas de la app para navegar y estudiar este contenido (v1 frontend).
- [ ] Validación del propietario aplicando los SQL.

---

## Iteración v1 — Frontend de estudio + progreso + Edge Function (2026-06-15)

### 1. Resumen
Recorrido de aprendizaje funcional de extremo a extremo: catálogo → curso → tema (resumen + lecciones con **desbloqueo lineal**) → **reproductor de lección** (pantallas de contenido + ejercicios ANKI/test/V-F con respuestas barajadas y reencolado de "Incorrecto") → **resultado** (% aciertos/fallos) → progreso. Se entregan además `script-003.sql` (progreso) y la Edge Function autoritativa.

### 2. Archivos creados — Frontend
- **Datos/lógica:** `lib/types.ts`, `lib/shuffle.ts` (+test), `lib/queries/content.ts`, `lib/queries/progress.ts`, `lib/progress/localProgress.ts`, `features/lesson/engine/options.ts` (+test), `hooks/useAsync.ts`.
- **Lección:** `features/lesson/LessonPlayer.tsx`, `LessonScreen.tsx`, `exercises/AnkiCard.tsx`, `exercises/ChoiceQuestion.tsx`, `lesson.module.css`.
- **Contenido:** `features/content/CatalogScreen.tsx`, `CourseScreen.tsx`, `TopicScreen.tsx`; `features/progress/ProgressScreen.tsx`.
- **Rutas:** `src/app/courses`, `course`, `topic`, `lesson`, `progress` (+ home actualizada). Las que leen query params van envueltas en `Suspense` (export estático).

### 3. Archivos creados — Backend / SQL
- `supabase/sql/script-003.sql` — `certdeck_user_lesson_progress`, `certdeck_user_question_attempts` + **RLS por usuario** (`auth.uid() = user_id`).
- `supabase/functions/certdeck-progress-complete-lesson/` (`index.ts` + `README.md`) — Edge Function NUEVA, autoritativa, con CORS propio (no toca login/registro). **No desplegada** por el agente.

### 4. Decisiones de diseño
- **Navegación por query params** (`/course?slug=`, `/topic?id=`, `/lesson?id=`) en vez de rutas dinámicas: compatible con `output: 'export'` (ADR 0003) sin `generateStaticParams`.
- **Progreso optimista local** (`localProgress`, ADR 0002): el desbloqueo lineal y el progreso funcionan ya en cliente (localStorage); la Edge Function + RLS son la fuente de verdad y reconcilian. La llamada a la función es best-effort (si no está desplegada, no rompe la UX).
- **Recuento de score:** cada pregunta cuenta una sola vez (primera resolución); el reencolado de tarjetas falladas no duplica el recuento (antifrustración, RN-17).

### 5. Verificación (local)
| Check | Comando | Resultado |
|---|---|---|
| Tipos | `npm run typecheck` | ✅ |
| Tests | `npm run test` | ✅ 10/10 |
| Lint | `npm run lint` | ✅ |
| Build export | `npm run build` | ✅ 7 rutas exportadas |
> El SQL/Edge Function no se han podido ejecutar (sin Postgres/Supabase local). Requieren validación del propietario.

### 6. Pendiente de v1
- [ ] Ejercicios y práctica directa de **examen** (`certdeck_exam_questions` ya existe; faltan UI y datos).
- [ ] Que el propietario aplique `script-002/003.sql` y despliegue `certdeck-progress-complete-lesson`.
- [ ] Reemplazar progreso local por lectura real desde `certdeck_user_lesson_progress`.

---

## Revisión de alcance 1.2.0 — Documentación actualizada (2026-06-15)

> Solo **documentación** (no código). Recoge la nueva visión de UX/navegación y composición de lecciones antes de seguir implementando.

### Documentos actualizados
- **Constitución v1.4.0** (§10 UX): barra inferior, curso/etapa activos, controles abajo, fuente mayor/espaciada, Markdown negrita, ronda de corrección.
- **Requisitos v1.2.0**: §3.1 (navegación + curso activo), §3.6/§3.6bis (examen base + ronda de corrección), §3.9 (composición dinámica), §3.11/§3.12 (pestañas y lección a pantalla completa), RN-21…28, HUs 15–18.
- **ADR 0004** (modelo de navegación) y **ADR 0005** (composición dinámica de lecciones).
- **Roadmap** y **Tareas v1.1.0** (§3bis con T-v1-024…034).

### Impacto sobre lo ya implementado (a refactorizar al retomar código)
- Frontend v1 (`CatalogScreen`, `CourseScreen`, `TopicScreen`, navegación por enlaces) → migrar al modelo de **barra inferior + curso/etapa activos + catálogo de etapa** (ADR 0004).
- `LessonPlayer` → añadir **ronda de corrección**, **botones abajo/igual ancho**, **fuente mayor** y **Markdown negrita** (RF-29a…e, RF-50…53).
- **Contenido `20260515_02_aws-saa-c03.sql`** → quitar preguntas autoradas de L4 (review) y L5 (final); esas lecciones se compondrán dinámicamente (ADR 0005). **Pendiente (T-v1-034).**

---

## Maquetación de UI a partir del mockup (2026-06-15)

> **Solo UI (sin lógica real).** Se adapta toda la app al **mockup de diseño** de Google AI Studio (`.localResources/src`), reproduciendo el modelo de navegación del ADR 0004. Los datos son **mock**; la conexión a Supabase (`lib/queries`) y el progreso real se conectarán a medida que avance el roadmap.

### Decisiones técnicas
- **Tailwind CSS v4** + **lucide-react** como sistema visual (el mockup está hecho con ellos). Tokens de marca en `styles/globals.css` vía `@theme` (azul/celeste/blanco); PostCSS con `@tailwindcss/postcss`.
- **SPA de una sola página con pestañas** (Cursos/Repasos/Progresos/Perfil) + reproductor de lección a pantalla completa (modo concentración, barra inferior oculta), coherente con export estático (ADR 0003).

### Archivos creados (`app/features/shell/`)
- `AppShell.tsx` (contenedor + cabecera + barra inferior + overlay de lección), `Navigation.tsx`, `CoursesTab.tsx`, `RepasosTab.tsx`, `ProgresosTab.tsx`, `PerfilTab.tsx`, `LessonPlayer.tsx` (ANKI con volteo 3D, test, V/F, respuesta escrita, ronda de corrección y resultados), `mockData.ts`.
- `src/app/page.tsx` ahora renderiza `<AppShell/>`. `styles/globals.css` reescrito para Tailwind v4. `lib/types.ts`: `LessonWithStatus`, `UserStats`, `LessonResult`.

### Archivos eliminados (UI v1 superseded por el nuevo diseño)
- Rutas `src/app/{courses,course,topic,lesson,progress}`; pantallas `features/content/*`, `features/progress/*`; `features/lesson/{LessonPlayer,LessonScreen,exercises/*,lesson.module.css}`; `components/ui/*`; `styles/tokens.css`.
- **Conservado** para la futura lógica: `lib/*` (queries, supabase, progreso, sesión), `hooks/*` y `features/lesson/engine/*` (lógica pura testeada de opciones y respuesta de texto).

### Pendiente (a conectar según roadmap)
- Reutilizar `engine/textAnswer` y `engine/options` en el nuevo `LessonPlayer` al cablear la lógica real.

### Validación local
- `typecheck`, `lint`, `test` (17) y `build` (export estático) en verde; tokens de marca y clases auxiliares (volteo 3D) presentes en el CSS exportado.

---

## Cableado del contenido y progreso reales (2026-06-15)

> Se retira por completo el `mockData` y la UI del shell pasa a consumir **datos reales de Supabase** (`lib/queries`) y el **progreso real** (capa optimista local + Edge Function `certdeck-progress-complete-lesson`, ADR 0002).

### Cambios
- **Eliminado** `app/features/shell/mockData.ts` y todos los valores hardcodeados (XP/racha/contadores "12 vencidas", nombre/email de perfil, etiquetas "(Mock)").
- `AppShell.tsx`: carga `getCourses` → `getStagesWithTopics` → `getLessonsByTopic` del curso activo; deriva el estado de cada lección con `computeLessonStatus` (desbloqueo lineal por tema) y las métricas con `computeUserStats`. Estados de carga/error/vacío. Perfil con la sesión de `useSession`.
- `LessonPlayer.tsx`: carga teoría+preguntas con `getPlayableLesson`; en repasos recibe las preguntas ya cargadas por el shell. Emite un `SessionResult` completo (aciertos, anki, XP, preguntas falladas/superadas).
- `lib/progress/localProgress.ts`: estado enriquecido (conteos, anki, XP por lección), set de preguntas falladas para los repasos de errores, actividad de repaso, racha por días activos, `computeUserStats` y `resetProgress`; migración del formato legado.
- `lib/queries/content.ts`: `getQuestionsByLessons` y `getQuestionsByIds` (repasos por tema/general/errores). `completeLesson` acepta `SessionResult`.
- `RepasosTab`/`ProgresosTab`/`PerfilTab`: métricas y textos derivados de datos reales; las sesiones de "errores" se deshabilitan sin errores pendientes.

> **Nota:** la RLS de contenido es `to authenticated`; sin sesión activa (el login es vía Edge Functions externas) los listados muestran su estado de carga/vacío. No se añade UI de login en este cambio.

### Validación local
- `typecheck`, `lint`, `test` (17) y `build` (export estático) en verde.

---

## Todas las llamadas a datos vía Edge Functions (2026-06-15)

> Regla de arquitectura: **toda llamada a datos pasa por una Edge Function**; el cliente nunca consulta las tablas directamente. **Un recurso = una función**; el método HTTP distingue la operación (se reutiliza la misma función solo para la misma llamada con distinto verbo HTTP).

### Funciones nuevas (Deno, autocontenidas, prefijo `certdeck-`)
Una por cada llamada de lectura que hacía el cliente directamente:
- `certdeck-courses` (GET) — listado de cursos.
- `certdeck-stages-with-topics` (GET `?course_id`) — etapas con sus temas.
- `certdeck-lessons-by-topic` (GET `?topic_id`) — lecciones de un tema.
- `certdeck-playable-lesson` (GET `?lesson_id`) — lección + pantallas + preguntas.
- `certdeck-questions-by-lessons` (GET `?lesson_ids`) — preguntas para repasos por tema/general.
- `certdeck-questions-by-ids` (GET `?ids`) — preguntas para repasos de errores.

Cada una: CORS propio, verificación del JWT del usuario y cliente con RLS (`auth.uid()`), respuesta `{ data }` y `{ error }` (Constitución §4, estilo de `certdeck-progress-complete-lesson`). README por función. **El agente no las despliega**; lo hace el propietario con `supabase functions deploy <nombre>`.

La escritura `completeLesson` ya pasaba por `certdeck-progress-complete-lesson` (POST), sin cambios.

### Cliente
- Nuevo `app/lib/edge/invoke.ts`: punto único de acceso. `fetch` a `/functions/v1/<fn>` con método, query params (arrays repetidos) y cabeceras `Authorization` (JWT de la sesión) + `apikey`. Desempaqueta `{ data }` y normaliza errores.
- `app/lib/queries/content.ts`: reescrito para llamar a las funciones vía `invokeEdge` (sin `getSupabaseClient().from(...)`). Eliminadas las consultas muertas `getCourseBySlug` y `getTopic`.

> **Auth**: `auth.getSession` / `onAuthStateChange` siguen en el cliente (subsistema GoTrue, no son consultas a tablas). El JWT debe vivir en el cliente para autorizar las llamadas a las funciones. Login/registro ya son Edge Functions externas.

### Validación local
- `typecheck`, `lint`, `test` (17) y `build` (export estático) en verde. Las funciones Deno no se typeckean en este repo (sin Deno local); replican la estructura de la función existente.

---

## Login con persistencia de sesión vía Edge Function (2026-06-15)

> La app exige sesión: el contenido (RLS `authenticated`) y todas las Edge Functions de datos requieren un JWT. Se añade el flujo de **login** autenticando en la Edge Function compartida `auth-login` y **persistiendo** la sesión en el cliente.

### Flujo
- `app/lib/auth/login.ts`: `login(email, password)` llama a `auth-login` (POST), y con la sesión devuelta hace `auth.setSession({ access_token, refresh_token })`. Eso persiste el JWT (`persistSession`) y dispara `SIGNED_IN`; a partir de ahí las llamadas a las funciones de datos viajan autenticadas. `logout()` usa `auth.signOut()`.
- `app/features/auth/LoginScreen.tsx`: formulario (email/contraseña) con estados de envío/error, con el estilo del shell.
- `app/features/auth/AuthGate.tsx`: con `useSession`, muestra spinner mientras resuelve, `LoginScreen` si no hay sesión y `AppShell` si la hay. `src/app/page.tsx` ahora renderiza `<AuthGate/>`.
- `PerfilTab`: botón **Cerrar sesión** (`onLogout` → `logout()`); al cerrar, `AuthGate` vuelve al login automáticamente.

> No se toca `auth-register` (es específico de otro proyecto: tablas `rol`/`profiles`). El registro queda fuera de este cambio.

### Validación local
- `typecheck`, `lint` y `build` (export estático) en verde.

---

## Modo oscuro (2026-06-15)

> Tema claro/oscuro real, conmutable desde Perfil y persistente.

### Enfoque
- Estrategia por clase `.dark` en `<html>`. Como las utilidades de Tailwind v4 referencian `var(--color-*)`, se re-tematiza **redefiniendo esas variables dentro de `.dark`** en `styles/globals.css` (sin tocar los componentes): rampa `slate` invertida (superficies claras→oscuras, texto oscuro→claro), acentos `-50/-100` oscurecidos con su texto aclarado, marca ligeramente aclarada. `slate-900` se mantiene oscuro (banner de Repasos); `bg-white` sólido se redirige a superficie oscura mientras los overlays `bg-white/NN` se conservan como destellos.
- `app/lib/theme.ts` (persistencia en localStorage + aplicar clase), `app/hooks/useTheme.ts` (estado/toggle), script anti-parpadeo en `layout.tsx` (aplica `.dark` antes del primer pintado; `suppressHydrationWarning`).
- `PerfilTab`: el toggle "Modo Oscuro" ahora usa `useTheme` (antes era un placeholder).

### Validación local
- `typecheck`, `lint` y `build` (export estático) en verde; el bloque `.dark` y las utilidades `var(--color-*)` están presentes en el CSS exportado.

---

## Migración de persistencia del progreso a la BD (2026-06-15) — ADR 0006

> Se elimina **toda persistencia local del progreso** (`certdeck:progress` en `localStorage`) y se traslada a la base de datos como única fuente de verdad. El cliente queda con estado **optimista en memoria** + write-through y manejo de red. El **tema** (`certdeck:theme`) y la **sesión** (JWT) siguen siendo locales (fuera de alcance).

### Enfoque
- **Lectura:** nueva Edge Function `certdeck-progress-get` que ensambla el `ProgressState` completo (lecciones + actividad de repasos agregada + errores pendientes + días activos). `AppShell` la carga al iniciar sesión y al **reconectar**.
- **Escritura optimista:** los reductores puros `applyLessonCompleted`/`applyReviewSession` (`lib/progress/progressState.ts`) actualizan el estado en memoria al instante; en paralelo, `completeLesson`/`recordReview` persisten en la BD (write-through). `score`/`xp` se **recalculan en el servidor**.
- **Reconciliación de errores:** `certdeck_user_failed_questions` se mantiene con alta de fallos / baja de recuperados en las funciones de lección y repaso.
- **Red:** hook `useOnline` (navigator + eventos) y bandera `connectionLost` (fallo de escritura). Con `offline = !isOnline || connectionLost` se muestra un **banner superior** y se **bloquea iniciar lección/repaso**. Perder la sesión en curso es aceptable.
- **Reset:** `certdeck-progress-reset` borra las filas del usuario en las 3 tablas.

### Archivos
- **Eliminado:** `app/lib/progress/localProgress.ts` (persistencia en disco).
- **Nuevo:** `app/lib/progress/progressState.ts` (tipos + funciones puras + reductores en memoria), `app/hooks/useOnline.ts`.
- **Reescrito:** `app/lib/queries/progress.ts` (`getProgress`/`completeLesson`/`recordReview`/`resetProgress` vía Edge Functions), `app/features/shell/AppShell.tsx` (carga BD, estado en memoria, banner, bloqueo offline).
- **SQL:** `supabase/sql/script-005.sql` (+`xp`/`anki_count`; tablas `certdeck_user_review_sessions`, `certdeck_user_failed_questions`; RLS).
- **Edge Functions:** `certdeck-progress-get` (nueva), `certdeck-progress-record-review` (nueva), `certdeck-progress-reset` (nueva), `certdeck-progress-complete-lesson` (modificada). Cada una con su `README.md`.

### Instrucciones manuales para el propietario (Constitución §4)
1. **Aplicar SQL** (orden, tras `script-001..004`):
   ```sql
   -- En el SQL Editor de Supabase, ejecutar el contenido de:
   supabase/sql/script-005.sql
   ```
   Es idempotente (`add column if not exists`, `create table if not exists`).
2. **Desplegar Edge Functions** (CLI de Supabase autenticada, desde la raíz):
   ```bash
   supabase functions deploy certdeck-progress-get
   supabase functions deploy certdeck-progress-record-review
   supabase functions deploy certdeck-progress-reset
   supabase functions deploy certdeck-progress-complete-lesson   # redeploy: payload ampliado
   ```
3. **Verificar:** iniciar sesión, completar una lección y recargar → el progreso persiste; activar modo avión → aparece el banner y se bloquea iniciar lecciones.

### Validación local
- `typecheck`, `lint` y los **17 tests** en verde. El frontend compila; el progreso real depende de que el propietario aplique el SQL y despliegue las funciones.

---

## Composición de lecciones `review`/`final` del catálogo (2026-06-16) — ADR 0005 (enmienda)

> Las lecciones de tipo `review` y `final` dejan de llevar preguntas propias y **reciclan tarjetas** de otras lecciones según una regla posicional fijada por el propietario.

### Enfoque
- Implementado en la Edge Function **`certdeck-playable-lesson`** (autoritativa, con acceso a la jerarquía y posiciones):
  - **`review`** → ~4 tarjetas al azar de las **5 lecciones anteriores** en el orden global del curso (`etapa.position → tema.position → lección.position`), pudiendo cruzar al tema anterior.
  - **`final`** → ~6 tarjetas al azar de **cualquier lección del mismo tema**.
  - **`normal`** → sin cambios (sus propias preguntas).
- El reproductor (`LessonPlayer`) no cambia: consume `data.questions` igual que antes; estas lecciones del catálogo se completan como normales (desbloquean la siguiente).
- Degradación elegante si el pool no alcanza 4/6. Cada tarjeta conserva su `lesson_id` de origen.

### Archivos
- **Modificado:** `supabase/functions/certdeck-playable-lesson/index.ts` (+`composeReview`/`composeFinal`/`pickRandom`) y su `README.md`.
- **Docs:** ADR 0005 (enmienda 2026-06-16).

### Instrucciones manuales para el propietario (Constitución §4)
1. **Quitar** las preguntas autoradas de las lecciones `review`/`final` del contenido (no deben llevar `INSERT` de `certdeck_flashcard_questions`).
2. **Redesplegar** la función: `supabase functions deploy certdeck-playable-lesson`.
3. Verificar: abrir una lección `review` (muestra ~4 tarjetas de lecciones previas) y una `final` (~6 del tema).

### Validación local
- `typecheck`, `lint` y los **17 tests** del frontend en verde (la función Deno no entra en el build del frontend; cambio aislado en `supabase/`).

---

## Contenido — Tema 2 "S3 Bucket" (2026-06-16)

> Segundo tema de la etapa "Básico", a partir de las diapositivas 19–22 del `Manual.pptx`.

### Estructura (7 lecciones)
- **L1 normal** — Visión general de los buckets (slide 19)
- **L2 normal** — Reglas de nombrado de buckets (slide 20)
- **L3 review** — Repaso: buckets y nombrado *(sin preguntas propias; recicla)*
- **L4 normal** — Ejemplos de nombres válidos e inválidos (slide 21)
- **L5 normal** — Restricciones y límites de los buckets (slide 22)
- **L6 review** — Repaso: ejemplos y límites *(sin preguntas propias; recicla)*
- **L7 final** — Lección final: S3 Bucket *(sin preguntas propias; recicla ~6 del tema)*

### Archivo
- **Nuevo:** `supabase/sql_contenido/20260616_03_aws-saa-c03.sql` (tema `position = 2` en la etapa "Básico"; pantallas + preguntas solo en las 4 lecciones `normal`; intro en review/final). Idempotente. **No aplicado por el agente (§4).**
- Conforme a la **enmienda del ADR 0005**: las lecciones `review`/`final` no llevan `INSERT` de `certdeck_flashcard_questions`.

### Instrucción manual
Aplicar el fragmento en el SQL Editor (tras los fragmentos 01/02). El orden alfabético del nombre garantiza el orden de ejecución.

---

## Iteración v2.1 — Algoritmo de repetición espaciada (2026-06-16)

> Primer paso de **v2** (Roadmap §3): el algoritmo SM-2 simplificado como función pura testeable + la tabla de estado por tarjeta. **Decisión del propietario:** el modo de composición **posicional** de `review`/`final` (regla 2026-06-16) se **reemplazará** por SM-2 (mejor para memorización espaciada) en **v2.2**.

### Enfoque
- **Lógica pura (RNF-09):** `app/lib/srs.ts` implementa `reviewCard(state, grade)` con los parámetros **Q-03 (RN-16) ajustables** (`DEFAULT_SRS_PARAMS`): ease inicial 2.5 / mín 1.3; Correcto pasos 1/3/7 y luego ×ease; Muy fácil pasos 3/7, +0.15 ease y ×ease×1.3; Incorrecto interval=0, repetitions=0, ease −0.2; **problemática a 3 fallos (Q-02)**. Helpers `initialCardState` e `isCardDue`.
- **Tests:** `app/lib/__tests__/srs.test.ts` (12 casos: progresiones correcto/fácil, reinicio y suelo de ease en fallo, problemática sticky, vencimiento, parámetros personalizados). Suite total: **29 en verde**.
- **SQL:** `supabase/sql/script-006.sql` crea `certdeck_user_spaced_repetition` (ease_factor, interval_days, repetitions, lapses, is_problematic, due_at, last_reviewed_at; `unique(user_id, question_id)`; índices por `user_id` y `(user_id, due_at)`; trigger `updated_at`; RLS select/insert/update propias). FK a `certdeck_flashcard_questions` (el examen no alimenta SRS, Q-06).

### Archivos
- **Nuevos:** `app/lib/srs.ts`, `app/lib/__tests__/srs.test.ts`, `supabase/sql/script-006.sql`.

### Instrucciones manuales para el propietario (Constitución §4)
- **Aplicar** `supabase/sql/script-006.sql` (idempotente; tras script-001…005). No hay nada que desplegar todavía: las Edge Functions de repaso llegan en v2.2.

### Pendiente (v2.2) — reemplazo del modo posicional por SM-2
- Edge Function `certdeck-spaced-review-update`: persiste el resultado de cada tarjeta ANKI aplicando `srs.ts` sobre `certdeck_user_spaced_repetition`.
- Edge Function `certdeck-review-build-lesson`: compone `review`/`final` a partir de **tarjetas vencidas** (`due_at <= now`) + jerarquía, **sustituyendo** la composición posicional de `certdeck-playable-lesson` (ADR 0005, regla 2026-06-16).
- Wiring en `LessonPlayer` para enviar el grade (fail/correct/easy) de cada tarjeta.

---

## Iteración v2.2 + v2.3 — Repaso espaciado real, composición SM-2 y corrección (2026-06-16)

> Persistencia autoritativa del SM-2, sustitución del modo **posicional** por **repetición espaciada** en la composición de `review`/`final`/`error_correction`, y activación de la corrección de errores (Q-01).

### Backend (Edge Functions, entregadas no desplegadas — §4)
- **Nueva `certdeck-spaced-review-update`** (POST): recibe un lote `{ question_id, grade }` (fail/correct/easy), lee el estado de cada tarjeta en `certdeck_user_spaced_repetition`, aplica el SM-2 (réplica de `app/lib/srs.ts`, RT-03) y hace upsert; marca `is_problematic` a 3 fallos (Q-02). Única función que **calcula** SM-2.
- **Modificada `certdeck-playable-lesson`**: la composición de `review`/`final`/`error_correction` deja de ser posicional y pasa a **priorizar tarjetas vencidas** (`due_at <= now`) leyendo `certdeck_user_spaced_repetition` (solo **lee**). Reemplaza el modo posicional (ADR 0005, decisión 2026-06-16):
  - `review` → hasta 6 cartas de las lecciones **anteriores del tema**, vencidas primero.
  - `final` → hasta 8 cartas de **todo el tema**.
  - `error_correction` → hasta 6 cartas con problemas (`lapses>0`/problemática); si no hay, degrada a repaso del tema (RF-44).
  - Sin historial (primera pasada) ordena al azar → se comporta como antes.

### Frontend
- `lib/types.ts`: `ReviewGrade` y `CardReview`; `SessionResult.cardReviews`.
- `LessonPlayer`: `buildSessionResult` deriva el grade por tarjeta (ANKI = autoevaluación; resto = acierto final → correct/fail).
- `lib/queries/progress.ts`: `submitCardReviews()` → `certdeck-spaced-review-update`.
- `AppShell`: tras cualquier sesión (lección o repaso) envía los `cardReviews` (write-through, ADR 0006). **Q-01:** si una lección puntúa **< 60%** activa la oferta de corrección.
- `CoursesTab`: **banner de corrección de errores** (Q-01) que lanza un repaso de errores del tema (reutiliza la maquinaria de "topic-errors").

### Verificación local
- `typecheck`, `lint`, **29 tests** y `build` export en verde. (Las funciones Deno no entran en el build del frontend.)

### Cobertura del hito v2
- ✅ El estado SM-2 evoluciona y persiste (algoritmo testeado en v2.1).
- ✅ `review`/`final` se componen por vencimiento; `error_correction` prioriza fallos.
- ✅ Tarjeta **problemática** a 3 fallos (server-side, Q-02).
- ✅ Activación de corrección si score < 60% (Q-01).
- ◐ **Desbloqueo avanzado** RF-37…41 (repaso cada 3 / generalista): hoy se cubre por **autoría de contenido** (las lecciones review/final ya se colocan en el temario) + desbloqueo lineal; una resolución algorítmica dedicada queda como mejora.

### Instrucciones manuales para el propietario (§4)
1. Aplicar `supabase/sql/script-006.sql` (si no se hizo en v2.1).
2. Desplegar: `supabase functions deploy certdeck-spaced-review-update` y **redesplegar** `certdeck-playable-lesson`.
3. Verificar: estudiar lecciones normales, luego abrir un `review` (prioriza vencidas) y fallar una tarjeta 3 veces (se marca problemática). Una lección con < 60% ofrece "Corregir".

---

## Iteración v3 — Examen avanzado + progreso enriquecido (2026-06-16)

> Hito **v3** completo (Roadmap §3): práctica directa de examen con validación de
> **conjunto exacto**, corrección autoritativa, progreso enriquecido (avance por
> tema, repaso vencido/pendiente, histórico de examen), lecciones `expansion`/
> `final` operativas y revisión de Q-06 (ADR 0007).

### 1. Resumen
Se añade la **práctica directa de examen** (RF-24…29) como **quinta pestaña**
(barra inferior: Cursos/Repasos/**Examen**/Progresos/Perfil). El usuario filtra
por tema, dificultad y nº de preguntas, responde un simulacro (respuesta única y
múltiple) y recibe feedback con `extra_information`. La **regla de conjunto
exacto** (RF-29/RN-11) se valida en cliente para la UX y se **reconfirma de forma
autoritativa** en la Edge Function `certdeck-exam-grade`, que además **registra el
intento** (`certdeck_user_question_attempts`) **sin** tocar el repaso espaciado
(Q-06, ADR 0007). La pestaña de Progresos se enriquece con avance por tema,
estado de repaso espaciado (vencidas/por venir) e histórico de examen.

### 2. Tareas cubiertas (Roadmap/Tareas v3)
- **T-v3-001** Examen múltiple con conjunto exacto (UI + reglas).
- **T-v3-002** Validación autoritativa de examen (`certdeck-exam-grade`).
- **T-v3-003** Práctica de examen con filtros (tema/dificultad) + `extra_information`.
- **T-v3-004** Progreso enriquecido (avance por tema, vencidas/pendientes, histórico).
- **T-v3-005** Lecciones `expansion` y `final` operativas.
- **T-v3-006** Revisión de Q-06 → **ADR 0007**.

### 3. Lógica pura testeada (RNF-09)
- `app/lib/exam.ts`: `isExactSetMatch`, `correctTexts`, `gradeExamAnswer`,
  `examExerciseType`. Comparación normalizada (tildes/mayúsculas/espacios) y regla
  de conjunto exacto válida para única y múltiple.
- `app/lib/__tests__/exam.test.ts`: **14 casos** (orden, subconjunto, selección de
  más, normalización, mapeo de tipo). Suite total: **43 en verde**.

### 4. Frontend
- **Tipos** (`lib/types.ts`): `ExamQuestion`, `ExamAnswerOption`, `ExamTypeId`,
  `ExamFilters`, `ExamAttempt`, `ExamGradeResult`, `ExamGradeSummary`.
- **Queries** (`lib/queries/exam.ts`): `getExamQuestions(filters)` y
  `gradeExam(attempts)` (vía `invokeEdge`).
- **Pantallas** (`features/exam/`): `ExamPracticeTab.tsx` (configurador de filtros
  + histórico) y `ExamPlayer.tsx` (simulacro a pantalla completa: única/múltiple,
  conjunto exacto, feedback + `extra_information`, resultados).
- **Navegación**: `Navigation.tsx` pasa a **5 pestañas** (nueva "Examen").
- **Shell** (`AppShell.tsx`): estado y handlers de examen
  (`handleStartExam`/`handleCloseExam`), overlay de `ExamPlayer`, y paso de
  `srs`/`exam` a Progresos. Tras un simulacro: `gradeExam` (autoritativo) +
  recarga de progreso para refrescar el histórico.
- **Progreso enriquecido** (`ProgresosTab.tsx`): avance por tema de la etapa,
  tarjeta de repaso espaciado (vencidas/por venir/en estudio) e histórico de
  examen. `progressState.ts`: nuevos agregados `srs` y `exam` (+ normalización).

### 5. Backend (Edge Functions, entregadas no desplegadas — §4)
- **Nueva `certdeck-exam-questions`** (GET): preguntas de examen filtrables por
  `course_id`/`topic_id`/`difficulty`/`limit`, con respuestas **ya desordenadas**
  (RF-28) y `isCorrect` por opción para feedback inmediato (RNF-14).
- **Nueva `certdeck-exam-grade`** (POST): corrección autoritativa de un lote por
  **conjunto exacto** (RN-11) y registro del intento en
  `certdeck_user_question_attempts` (Q-06: no toca SRS).
- **Modificada `certdeck-progress-get`**: añade agregados `srs` (tracked/due/
  upcoming desde `certdeck_user_spaced_repetition`) y `exam` (attempts/correct
  desde los intentos de examen).
- **Modificada `certdeck-playable-lesson`**: `expansion` se compone reciclando
  tarjetas del tema ya visto (mismo pool que `final`, RF-45b base reservada).

### 6. SQL / Contenido
- **Sin SQL estructural nuevo**: `certdeck_exam_questions` (script-002) y
  `certdeck_user_question_attempts` con `exam_*` (script-003) ya existían.
- **Nuevo contenido**: `supabase/sql_contenido/20260616_04_aws-saa-c03-exam.sql`
  — 6 preguntas de examen (única y múltiple, dif. 2–4, con `extra_information`)
  para los temas *Introduction to S3* y *S3 Bucket*. Idempotente vía `NOT EXISTS`
  sobre `(course_id, question)` (la tabla no tiene clave natural). **No aplicado** (§4).

### 7. Decisión documentada
- **ADR 0007** — revisión de Q-06: la práctica de examen **no** alimenta el repaso
  espaciado; registra intentos y nutre el histórico de examen.

### 8. Verificación (local)
| Check | Comando | Resultado |
|---|---|---|
| Tipos | `npm run typecheck` | ✅ |
| Lint | `npm run lint` | ✅ |
| Tests | `npm run test` | ✅ 43/43 |
| Build export | `npm run build` | ✅ export estático OK |
> Las funciones Deno no entran en el build del frontend. El examen real depende de
> que el propietario aplique el contenido y despliegue las funciones.

### 9. Instrucciones manuales para el propietario (§4)
> **Proyecto Supabase fijo:** todas las operaciones (SQL y despliegues) van
> SIEMPRE contra el proyecto **`wtkumfcjqqmgokgrbxxr`** (organización "Prototipos
> Personales"). Queda fijado en `supabase/config.toml` (`project_id`); si la CLI
> no estuviera enlazada: `supabase link --project-ref wtkumfcjqqmgokgrbxxr`.

1. **Aplicar contenido**: `supabase/sql_contenido/20260616_04_aws-saa-c03-exam.sql`
   (tras los fragmentos 01–03). Idempotente.
2. **Desplegar/redeployar Edge Functions** (contra `wtkumfcjqqmgokgrbxxr`):
   ```bash
   supabase functions deploy certdeck-exam-questions
   supabase functions deploy certdeck-exam-grade
   supabase functions deploy certdeck-progress-get        # agregados srs/exam
   supabase functions deploy certdeck-playable-lesson     # expansion
   ```
3. **Verificar**: pestaña *Examen* → filtrar por tema/dificultad → responder una
   múltiple seleccionando un subconjunto (debe contar como fallo) y el conjunto
   exacto (acierto); en *Progresos* aparecen el histórico de examen y, tras
   estudiar tarjetas, las vencidas/por venir.

---

## Iteración — Reporte de errores en tarjetas (asistencia técnica) (2026-06-16)

### 1. Resumen
Botón de **asistencia técnica** en todas las tarjetas de pregunta (flashcards de
lección/repaso y preguntas de examen). Al pulsarlo abre un **mini-popup** con un
combo de motivo (`Bug`, `Falta de ortografía`, `Respuesta incorrecta`, `Pregunta
confusa`, `Otro`) y un campo de detalle libre. El reporte se persiste para que el
propietario revise y corrija el contenido más adelante (RF-54…57, ADR 0008).

### 2. Tareas cubiertas
- Requisitos §3.13 (RF-54…57), RSP-08, §11; ADR 0008.

### 3. Frontend
- `app/components/ReportControl.tsx` — **componente reutilizable** (botón + popup,
  estados idle/sending/success/error). Mobile-first, paleta de marca.
- `app/lib/queries/reports.ts` — `submitQuestionReport()` (vía `invokeEdge`).
- `app/lib/types.ts` — tipos `QuestionSource`, `ReportCategory`, `QuestionReportInput`.
- Cableado en `LessonPlayer` (cabecera de la tarjeta de ejercicio; `activeCourseId`
  añadido como prop desde `AppShell`) y en `ExamPlayer` (cabecera de la pregunta).

### 4. Backend (entregado, NO aplicado/desplegado — §4)
- **SQL:** `supabase/sql/script-007.sql` — tabla `certdeck_user_question_reports`
  (sin FK a la pregunta: `question_source` + `question_id` + instantánea
  `question_text`; `category`, `details`, `status`) con índices, trigger
  `updated_at` y **RLS** (select/insert propios).
- **Edge Function:** `supabase/functions/certdeck-report-create/` (`index.ts` +
  `README.md`) — alta como usuario autenticado, validación de entrada en servidor.

### 5. Decisión documentada
- **ADR 0008** — Reporte de errores en tarjetas: por qué Edge Function (no insert
  directo), por qué `source`+`id`+instantánea (no FK polimórfica) y alcance
  (la gestión/resolución de reportes queda para más adelante).

### 6. Verificación (local)
| Check | Comando | Resultado |
|---|---|---|
| Tipos | `npx tsc --noEmit` | ✅ |
> Las funciones Deno no entran en el build del frontend. El alta real depende de que
> el propietario aplique `script-007.sql` y despliegue `certdeck-report-create`.

### 7. Instrucciones manuales para el propietario (§4)
> **Proyecto Supabase fijo:** `wtkumfcjqqmgokgrbxxr` ("Prototipos Personales").

1. **Aplicar SQL**: `supabase/sql/script-007.sql` (tras script-001…006). Idempotente.
2. **Desplegar Edge Function**:
   ```bash
   supabase functions deploy certdeck-report-create
   ```
3. **Verificar**: dentro de una lección o de la práctica de examen, pulsar
   *Reportar* en una tarjeta → elegir motivo, escribir un detalle y enviar; debe
   aparecer la confirmación y una fila nueva en `certdeck_user_question_reports`.

---

## Iteración — Caché de contenido en cliente (2026-06-16)

### 1. Resumen
El catálogo del curso (etapas + temas + lecciones) se **cachea en `localStorage`**
y, al arrancar, solo se vuelve a descargar si un endpoint ligero de **versión**
indica que cambió. Elimina la carga pesada (etapas/temas + N de lecciones) en el
caso común (contenido estable) — RNF-17, ADR 0009.

### 2. Backend (entregado, NO aplicado/desplegado — §4)
- **SQL:** `supabase/sql/script-008.sql` — función `certdeck_course_catalog_version(uuid)`
  (security invoker → RLS aplica; token = `epoch(max updated_at).recuento` sobre
  curso/etapas/temas/lecciones), con `grant execute` a `authenticated`.
- **Edge Function:** `supabase/functions/certdeck-content-version/` (`index.ts` +
  `README.md`) — GET `?course_id=`, una sola RPC.

### 3. Frontend
- `app/lib/cache/contentCache.ts` — caché `localStorage` del catálogo + token
  (lectura/escritura/limpieza tolerantes a fallos de cuota).
- `app/lib/queries/content.ts` — `getCourseContentVersion()`.
- `app/features/shell/AppShell.tsx` — el efecto de carga del curso pide el token,
  usa la caché si coincide y, si no, descarga y reescribe; degradación a caché si
  hay error/offline.

### 4. Decisión documentada
- **ADR 0009** — caché de contenido con token de versión; ámbito (catálogo, no
  preguntas), degradación y por qué no rompe el ADR 0006 (progreso sigue sin caché).

### 5. Verificación (local)
| Check | Comando | Resultado |
|---|---|---|
| Tipos | `npx tsc --noEmit` | ✅ |

### 6. Instrucciones manuales para el propietario (§4)
> **Proyecto Supabase fijo:** `wtkumfcjqqmgokgrbxxr` ("Prototipos Personales").

1. **Aplicar SQL**: `supabase/sql/script-008.sql` (tras script-001…007). Idempotente.
2. **Desplegar Edge Function**: `supabase functions deploy certdeck-content-version`.
3. **Verificar**: cargar la app dos veces; la 1ª descarga el catálogo, la 2ª debe
   resolverse con una sola llamada (`certdeck-content-version`) y carga casi
   instantánea. Tras editar/añadir una lección, el token cambia y se redescarga.

---

## Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-15 | Bitácora inicial con iteración v0 (fundaciones del frontend). |
| 1.1.0 | 2026-06-15 | Maquetación de UI a partir del mockup: Tailwind v4 + lucide-react, shell con barra inferior (ADR 0004) y reproductor de lección; UI v1 retirada. Solo diseño; datos mock pendientes de cablear. |
| 1.2.0 | 2026-06-15 | Cableado de contenido y progreso reales: se retira `mockData`; el shell consume `lib/queries` (Supabase) y el progreso real (local optimista + Edge Function). Métricas reales (XP, racha, errores). |
| 1.3.0 | 2026-06-15 | Toda llamada a datos pasa por Edge Functions: 6 funciones de lectura nuevas (`certdeck-*`), helper cliente `lib/edge/invoke.ts` y `content.ts` reescrito sin acceso directo a tablas. |
| 1.4.0 | 2026-06-15 | Login con persistencia de sesión vía Edge Function `auth-login` (`lib/auth/login`, `LoginScreen`, `AuthGate`) + cerrar sesión en Perfil. |
| 1.5.0 | 2026-06-15 | Modo oscuro conmutable y persistente (clase `.dark` + remapeo de variables de tema Tailwind v4; `lib/theme`, `useTheme`, script anti-parpadeo). |
| 1.6.0 | 2026-06-15 | Migración de la persistencia del progreso a la BD (ADR 0006): se elimina `localProgress` (localStorage), estado optimista en memoria + write-through, lectura desde `certdeck-progress-get`, banner/bloqueo offline; `script-005.sql` y 3 Edge Functions nuevas + 1 modificada (entregadas, no aplicadas). |
| 1.7.0 | 2026-06-16 | Composición dinámica de `review`/`final` del catálogo (ADR 0005 enmienda): `certdeck-playable-lesson` recicla ~4 tarjetas de las 5 lecciones anteriores (review) o ~6 del mismo tema (final). Redepliegue manual pendiente. |
| 1.8.0 | 2026-06-16 | Contenido: tema 2 "S3 Bucket" (slides 19–22), 7 lecciones (4 normales con preguntas + 2 review + 1 final que reciclan). Fragmento `20260616_03_aws-saa-c03.sql` entregado (no aplicado). |
| 1.9.0 | 2026-06-16 | v2.1: algoritmo SM-2 simplificado puro `app/lib/srs.ts` (Q-03 ajustable) + 12 tests, y `script-006.sql` (`certdeck_user_spaced_repetition` + RLS). El modo posicional se reemplazará por SM-2 en v2.2. |
| 2.0.0 | 2026-06-16 | v2.2+v2.3: `certdeck-spaced-review-update` (persiste SM-2) + `certdeck-playable-lesson` compone por **vencimiento** (review/final/error_correction), reemplazando el modo posicional; wiring de `cardReviews` en LessonPlayer/AppShell; tarjeta problemática (Q-02) y oferta de corrección < 60% (Q-01). |
| 3.0.0 | 2026-06-16 | **v3 completo**: práctica directa de examen (5ª pestaña) con conjunto exacto (RF-29), `certdeck-exam-questions`/`certdeck-exam-grade` (autoritativa, registra intento sin tocar SRS — Q-06/ADR 0007), `lib/exam.ts` puro + 14 tests; progreso enriquecido (avance por tema, repaso vencido/pendiente, histórico de examen) con agregados `srs`/`exam` en `certdeck-progress-get`; `expansion` reciclada en `certdeck-playable-lesson`; contenido de examen `20260616_04`. |
| 3.1.0 | 2026-06-16 | **Reporte de errores en tarjetas** (asistencia técnica, ADR 0008 · RF-54…57): `ReportControl` (botón + popup con combo de motivo y detalle) en LessonPlayer y ExamPlayer, `lib/queries/reports.ts`; `script-007.sql` (`certdeck_user_question_reports` + RLS) y Edge Function `certdeck-report-create` (entregados, no aplicados). Además: fix de saltos de línea en pantallas de teoría, truncado del título de curso en la cabecera de lección e intercepción del botón atrás de hardware (confirmar salida de sesión, `@capacitor/app`). |
| 3.2.0 | 2026-06-16 | **Caché de contenido en cliente** (RNF-17, ADR 0009): catálogo del curso en `localStorage` + token de versión; `AppShell` solo redescarga si cambia. `lib/cache/contentCache.ts`, `getCourseContentVersion`, `script-008.sql` (`certdeck_course_catalog_version`) y Edge Function `certdeck-content-version` (entregados, no aplicados). |
