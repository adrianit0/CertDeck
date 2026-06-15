# ADR 0006 — Persistencia del progreso 100% en base de datos (sin estado local en disco)

- **Estado:** Aceptada
- **Fecha:** 2026-06-15
- **Fase:** 5 — Implementación
- **Decisores:** Propietario del proyecto
- **Relacionado:** [ADR 0002](0002-logica-desbloqueo-y-repaso.md) (enmendada), [Constitución](../01-constitution/constitution.md) §3.5/§4/§9, [Requisitos](../02-requirements/requirements.md) RF-30…RF-41, RN-04…RN-20, RSP-01/02
- **Enmienda a:** ADR 0002 (la "capa optimista local" persistida deja de existir)

## Contexto

El MVP guardaba **todo el progreso real** en `localStorage` (`certdeck:progress`, módulo `app/lib/progress/localProgress.ts`), como *capa optimista* prevista por el ADR 0002. La fuente de verdad de la BD (`certdeck_user_*` + Edge Functions) quedó **a medio cablear**:

- La Edge Function `certdeck-progress-complete-lesson` **escribía** el progreso de lección, pero **nadie leía** de la BD: la app se alimentaba siempre de `localStorage`.
- Varias cosas vivían **solo** en `localStorage` y **no tenían representación en BD ni en la documentación**:
  1. `lessons[*].xp` y `lessons[*].ankiCount` (la tabla `certdeck_user_lesson_progress` no tenía esas columnas).
  2. `review` — actividad agregada de sesiones de repaso no atadas a una lección.
  3. `activeDays` — días con actividad, base del cálculo de **racha**.
  4. `failedQuestions` — set de preguntas falladas pendientes de corrección (la tabla `certdeck_user_question_attempts` existía pero **la app no la usaba**).

Esto provoca que el progreso **no sea portable entre dispositivos**, se pierda al limpiar el navegador/reinstalar, y sea **manipulable** desde el cliente (contra Constitución §3.5).

## Decisión

**Eliminar toda persistencia local en disco del progreso del usuario.** La **base de datos es la única fuente de verdad**. El cliente mantiene un estado **optimista en memoria** (solo React, mientras dura la sesión) con **escritura write-through** a la BD vía Edge Functions.

1. **Lectura:** al arrancar (y al cambiar de sesión) la app carga el estado completo de progreso desde una Edge Function de lectura (`certdeck-progress-get`). Ese estado vive en memoria.
2. **Escritura (optimista + write-through):** al completar una lección o un repaso, la UI actualiza el estado en memoria **de inmediato** y, en paralelo, persiste en BD. La BD recalcula/valida (no se confía en el cliente, §3.5).
3. **Sin caché en disco:** no se escribe nada del progreso en `localStorage`/`IndexedDB`/ficheros. Al recargar, el estado se vuelve a leer de la BD.
4. **Manejo de red (sustituye la resiliencia offline del ADR 0002):**
   - Si una escritura falla o el dispositivo está sin conexión, se muestra un **banner superior persistente de "pérdida de conexión"**.
   - Mientras no haya conexión, **se bloquea iniciar una nueva lección/repaso**.
   - **Perder la sesión en curso** ante un fallo es aceptable (el modelo optimista garantiza que lo ya confirmado en BD es coherente).

### Qué se mantiene local (fuera del alcance de este ADR)

- **Sesión de autenticación** (JWT de Supabase, `persistSession`): es auth, no progreso; necesaria para que las llamadas viajen autenticadas.
- **Preferencia de tema** (`certdeck:theme`): preferencia **de dispositivo**, no dato de usuario; mantenerla local evita el parpadeo claro→oscuro al cargar. Si se quisiera sincronizar por usuario, sería un ADR aparte (tabla `certdeck_user_settings`).

## Modelo de datos resultante

| Bloque (antes en `localStorage`) | Persistencia en BD |
|---|---|
| `lessons[*]` (estado, score, aciertos/fallos) | `certdeck_user_lesson_progress` (ya existía) |
| `lessons[*].xp`, `lessons[*].ankiCount` | **+columnas** `xp`, `anki_count` en `certdeck_user_lesson_progress` |
| `review` (xp/answers/correct/anki de repasos) | **nueva** `certdeck_user_review_sessions` (una fila por sesión; se agrega) |
| `failedQuestions` (errores pendientes) | **nueva** `certdeck_user_failed_questions` (`unique(user_id, question_id)`) |
| `activeDays` (racha) | **derivado**: fechas distintas de `lesson_progress.completed_at` ∪ `review_sessions.created_at` |

> La racha y las métricas agregadas se calculan en la lectura (Edge Function / cliente) a partir de las filas anteriores; no se almacena un contador de racha denormalizado.

## Edge Functions (Constitución §4: archivos entregados, NO desplegados por el agente)

- `certdeck-progress-get` (**nueva**, GET): devuelve el `ProgressState` completo del usuario.
- `certdeck-progress-complete-lesson` (**modificada**): persiste también `xp`/`anki_count` y reconcilia `failed_questions` (alta de fallos, baja de recuperados).
- `certdeck-progress-record-review` (**nueva**, POST): inserta una sesión de repaso y reconcilia `failed_questions`.
- `certdeck-progress-reset` (**nueva**, POST/DELETE): borra todas las filas de progreso del usuario (sustituye `resetProgress()` local).

Todas con RLS (`auth.uid() = user_id`) como guardarraíl (§9.5, RSP-01).

## Alternativas consideradas

1. **Mantener la capa optimista en `localStorage` (statu quo, ADR 0002).** Rechazada: no es portable entre dispositivos, se pierde al limpiar datos y es manipulable.
2. **Totalmente autoritativo (sin estado optimista).** Rechazada: cada respuesta esperaría un ida y vuelta de red → latencia perceptible, contra RNF-02/06 (mobile-first inmediato).
3. **Optimista en memoria + write-through + manejo explícito de red.** **Elegida.**

## Consecuencias

**Positivas:**
- Progreso portable, no manipulable y con la BD como única verdad (§3.5).
- Se cierra el cableado pendiente del ADR 0002 (lectura real desde BD).
- Documenta y modela datos que antes solo existían en el cliente.

**Negativas / a tener en cuenta:**
- **Requiere conexión** para guardar progreso y para iniciar nuevas lecciones; no hay modo offline real (se sustituye por banner + bloqueo).
- El propietario debe **aplicar `script-004.sql`** y **desplegar** las Edge Functions nuevas/modificadas antes de que el progreso persista (§4).
- Un fallo de red puede descartar la sesión en curso (asumido).
