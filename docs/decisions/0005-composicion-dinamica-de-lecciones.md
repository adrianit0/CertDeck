# ADR 0005 — Composición dinámica de lecciones de repaso, errores y finales

- **Estado:** Aceptada
- **Fecha:** 2026-06-15
- **Fase:** Revisión de Requisitos 1.2.0
- **Relacionado:** [Requisitos](../02-requirements.md) §3.9, §3.6bis, RN-21…26, RN-17; [ADR 0002](0002-logica-desbloqueo-y-repaso.md)

## Contexto

Autoría inicial: cada lección (incluidas repaso/errores/final) llevaba **preguntas propias** escritas a mano en SQL. Esto duplica contenido, es laborioso y desaprovecha el historial real del usuario. El propietario pide simplificar: que repasos, errores y finales **reciclen** preguntas ya existentes.

## Decisión

1. **Solo las lecciones `normal`** (y, aparte, las "lecciones de preguntas"/examen sobre `certdeck_exam_questions`) **tienen preguntas propias**. `review`, `error_correction` y `final` **no almacenan preguntas**: se **componen en tiempo de ejecución**.
2. **Pool de reciclaje** = preguntas que el usuario **ya ha visto** (con intento registrado en `certdeck_user_question_attempts`), recuperables por la jerarquía `Pregunta → Lección → Tema → Etapa → Curso`.
3. **Reglas de composición:**
   - **Repaso de tema:** preguntas ya vistas del tema.
   - **Repaso general:** 50% del tema actual + 50% de temas anteriores.
   - **Errores de tema:** preguntas del tema con último intento incorrecto; si no hay → repaso de tema.
   - **Errores generales:** 50% falladas del tema + 50% falladas de otros temas; si no hay → repaso general.
   - **Final:** selección al azar de preguntas del tema ya hechas.
4. **Recuperación de errores:** una pregunta deja de ser "error" cuando se acierta (transición vía algoritmo ANKI, RN-14).
5. **Ronda de corrección intra-lección** (RF-29a…e, RN-17): pasada principal + repaso de falladas; segundo fallo se registra como incorrecto para alimentar repasos/errores futuros.
6. **Dónde se compone:** coherente con ADR 0002 (híbrido). El cliente puede componer de forma optimista; la versión autoritativa será una Edge Function (`certdeck-review-build-lesson`) que selecciona el conjunto según estas reglas. La selección final puede vivir en cliente en el MVP y moverse a Edge Function en v2.

## Alternativas consideradas

1. **Preguntas propias autoradas en cada lección.** Rechazada: duplicación y mantenimiento alto.
2. **Vistas/relaciones explícitas pregunta↔lección-de-repaso.** Rechazada: rigidez; el reciclaje depende del historial del usuario, que es dinámico.
3. **Composición dinámica desde el historial + jerarquía.** **Elegida.**

## Consecuencias

**Positivas:** creación de contenido mucho más simple (solo lecciones normales); repasos/errores personalizados al usuario real; sin duplicar preguntas.
**A tener en cuenta:**
- Requiere historial de intentos fiable (`certdeck_user_question_attempts`) y, para ANKI, `certdeck_user_spaced_repetition` (v2).
- Las lecciones `review`/`error_correction`/`final` del contenido **no deben** llevar `INSERT` de preguntas. **El fragmento `sql_contenido/20260515_02_aws-saa-c03.sql` debe revisarse** para eliminar las preguntas autoradas en sus lecciones L4 (review) y L5 (final).
- La composición sin datos suficientes degrada con elegancia (errores→repaso; general→según disponibilidad).

## Notas de implementación
- `normal` → `certdeck_flashcard_questions` propias (como hasta ahora).
- `review`/`error_correction`/`final` → sin filas en `certdeck_flashcard_questions`; se resuelven al abrir la lección.
- Distinción tema vs general: el **scope** ("tema"/"general") lo aporta el contexto de la sesión (catálogo de tema vs pestaña Repasos), no necesariamente un nuevo `lesson_type`.
