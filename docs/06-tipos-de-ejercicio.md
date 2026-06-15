# CertDeck — Catálogo de tipos de ejercicio

> Documento de referencia **dedicado exclusivamente** a los tipos de ejercicio (`exercise_type`). Describe sus **propiedades** y su **funcionamiento**. Es la fuente de verdad cuando se cargan preguntas y cuando se implementa el reproductor de lecciones. Se irán **añadiendo nuevos tipos** a medida que avance el proyecto, siempre que aporten al sistema sin entorpecerlo.

- **Estado:** Vivo (se amplía con cada tipo nuevo)
- **Fecha:** 2026-06-15
- **Relacionado:** [Requisitos §3.3–§3.6, §10.1](02-requirements.md) · `supabase/sql/script-002.sql` · `supabase/sql/script-004.sql`

---

## 1. Modelo de datos común

Las preguntas de tipo flashcard viven en **`certdeck_flashcard_questions`** y comparten estas columnas:

| Columna | Tipo | Uso |
|---|---|---|
| `id` | uuid | Identificador. |
| `lesson_id` | uuid | Lección de origen (las preguntas propias solo existen en lecciones `normal`). |
| `exercise_type` | text | Tipo de ejercicio (ver catálogo). |
| `question` | text | Enunciado. **Clave natural** junto a `lesson_id` (idempotencia de seeds). |
| `correct_answer` | text | Respuesta correcta (o reverso, en ANKI). |
| `incorrect_answer_1` / `incorrect_answer_2` | text\|null | Distractores (solo algunos tipos). |
| `explanation` | text\|null | Explicación mostrada tras responder. |
| `is_active` | boolean | Si la pregunta está disponible. |

Notas transversales:

- **Sin `position`:** al empezar una lección se **extraen todas** sus preguntas y se muestran en **orden aleatorio** (barajado en cliente). El orden no se almacena.
- **Sin `difficulty`:** no se fuerza un reparto fácil/media/difícil; se prima la **calidad** y la adaptación al temario.
- **Orden de respuestas:** test, V/F (y examen) **siempre** muestran las opciones en orden aleatorio (RN-09). Nunca se expone el orden interno.

---

## 2. Catálogo de tipos

### 2.1 `anki_card` — Tarjeta tipo ANKI
- **Propiedades:** `question` (frontal), `correct_answer` (reverso). `incorrect_*` no se usan.
- **Funcionamiento:** se muestra el frontal; el usuario intenta recordar y revela el reverso; se autoevalúa con **Incorrecto / Correcto / Muy fácil**. Alimenta la repetición espaciada.
- **RF:** RF-13…RF-18.

### 2.2 `multiple_choice` — Test de 3 respuestas
- **Propiedades:** `correct_answer` + `incorrect_answer_1` + `incorrect_answer_2` (las dos incorrectas son **obligatorias**, lo garantiza un CHECK).
- **Funcionamiento:** 3 opciones barajadas, 1 correcta; tras responder, feedback + `explanation`.
- **RF:** RF-19…RF-21.

### 2.3 `true_false` — Verdadero / Falso
- **Propiedades:** `correct_answer ∈ {'Verdadero','Falso'}` (CHECK). `incorrect_*` no se usan.
- **Funcionamiento:** afirmación con dos opciones; feedback + `explanation` tras responder.
- **RF:** RF-22…RF-23.

### 2.4 `text_input` — Respuesta escrita
> Pensado **casi exclusivamente** para respuestas de **1 palabra** o **1 número**.

- **Propiedades:** `question` + `correct_answer` (una palabra/número). `incorrect_*` no se usan.
- **Funcionamiento:**
  1. Se muestra el enunciado y, debajo, **un hueco por cada letra** de la respuesta, de modo que el usuario ve **cuántas letras** tiene (p. ej. *¿Qué campo guarda información adicional adjunta al objeto?* → `_ _ _ _ _ _ _ _`).
  2. El usuario escribe su respuesta en un input de texto.
  3. **Comparación tolerante** (ver §3): ignora mayúsculas/minúsculas, espacios sobrantes y tildes/diacríticos.
  4. Si **falla a la primera**, en la corrección se revela **una letra** como pista (p. ej. `_ E _ _ _ _ _ _`) y puede **reintentar una vez**.
  5. Acierto a la primera → cuenta como **correcto**. Si necesitó la pista, la pregunta se cierra como **incorrecta** (queda registrada para repasos/errores), mostrando la respuesta correcta y la `explanation`.
- **Validación (regla):** se normalizan **tanto la respuesta correcta como la del usuario** antes de comparar. Ejemplo: si la correcta es `España`, el usuario que escriba ` éspanA` **acierta** (alguien sin "ñ" puede usar "n").
- **Implementación:** `app/features/lesson/engine/textAnswer.ts` (lógica pura, testeada) + `app/features/lesson/exercises/TextInputQuestion.tsx`.

---

## 3. Normalización de respuestas (`text_input`)

`normalizeAnswer()` aplica, en orden:

1. `NFD` (descomposición Unicode) + eliminación de **marcas diacríticas combinantes** → quita tildes, diéresis, la tilde de la **ñ** (→ n), la cedilla, etc.
2. Paso a **minúsculas**.
3. **Colapso de espacios** internos repetidos y **recorte** de extremos.

Dos respuestas se consideran iguales si su forma normalizada coincide.

| Respuesta correcta | El usuario escribe | ¿Acierta? |
|---|---|---|
| `España` | ` éspanA ` | ✅ |
| `Metadata` | `metadata` | ✅ |
| `Niño` | `nino` | ✅ |
| `5` | ` 5 ` | ✅ |
| `Metadata` | `Key` | ❌ |

---

## 4. Tipos de examen (catálogo aparte)

Las preguntas de examen viven en **`certdeck_exam_questions`** (no en flashcards) y se mapean a estos `exercise_type` solo a efectos de registro de intentos:

- **`exam_single`** — respuesta única (`type_id = 1`).
- **`exam_multiple`** — respuesta múltiple (`type_id = 2`); acierto solo con el conjunto exacto.

Base preparada; **sin datos por SQL en el MVP** (RF-25, RN-26).

---

## 5. Cómo añadir un tipo nuevo

1. Definir aquí sus **propiedades** y **funcionamiento**.
2. Ampliar el CHECK de `exercise_type` con un **script SQL nuevo numerado** (RNF-10) en `certdeck_flashcard_questions` y, si registra intentos, en `certdeck_user_question_attempts`.
3. Añadir el valor a `ExerciseType` en `app/lib/types.ts`.
4. Implementar su componente en `app/features/lesson/exercises/` y enlazarlo en `LessonPlayer`.
5. Aislar la lógica evaluable en `engine/` como **función pura testeada** (RNF-09).

---

## 6. Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-15 | Catálogo inicial: `anki_card`, `multiple_choice`, `true_false`, **`text_input`** (nuevo); examen como catálogo aparte. Eliminados `position` y `difficulty` de las flashcards. |
