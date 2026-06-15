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

## Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-15 | Bitácora inicial con iteración v0 (fundaciones del frontend). |
| 1.1.0 | 2026-06-15 | Maquetación de UI a partir del mockup: Tailwind v4 + lucide-react, shell con barra inferior (ADR 0004) y reproductor de lección; UI v1 retirada. Solo diseño; datos mock pendientes de cablear. |
| 1.2.0 | 2026-06-15 | Cableado de contenido y progreso reales: se retira `mockData`; el shell consume `lib/queries` (Supabase) y el progreso real (local optimista + Edge Function). Métricas reales (XP, racha, errores). |
| 1.3.0 | 2026-06-15 | Toda llamada a datos pasa por Edge Functions: 6 funciones de lectura nuevas (`certdeck-*`), helper cliente `lib/edge/invoke.ts` y `content.ts` reescrito sin acceso directo a tablas. |
| 1.4.0 | 2026-06-15 | Login con persistencia de sesión vía Edge Function `auth-login` (`lib/auth/login`, `LoginScreen`, `AuthGate`) + cerrar sesión en Perfil. |
| 1.5.0 | 2026-06-15 | Modo oscuro conmutable y persistente (clase `.dark` + remapeo de variables de tema Tailwind v4; `lib/theme`, `useTheme`, script anti-parpadeo). |
