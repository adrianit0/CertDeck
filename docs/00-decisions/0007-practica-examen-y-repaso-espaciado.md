# ADR 0007 — La práctica de examen no alimenta el repaso espaciado (revisión de Q-06)

- **Estado:** Aceptada
- **Fecha:** 2026-06-16
- **Fase:** 5 — Implementación (v3)
- **Decisores:** Propietario del proyecto
- **Relacionado:** [Roadmap](../03-roadmap/roadmap.md) (Q-06, v3), [Requisitos](../02-requirements/requirements.md) RF-24…RF-29, RN-10/RN-11, Q-06; [ADR 0002](0002-logica-desbloqueo-y-repaso.md); [script-006.sql](../../supabase/sql/script-006.sql)
- **Confirma:** la decisión Q-06 (no la enmienda)

## Contexto

El Roadmap dejó **Q-06** marcada para revisión en v3: *¿la práctica directa de examen debe afectar al repaso espaciado (`certdeck_user_spaced_repetition`)?* En el MVP se decidió que **no**: la práctica de examen registra intentos pero no altera el estado SM-2. Al implementar la sección de práctica de examen (v3) toca confirmar o cambiar esa decisión.

Hechos relevantes:

1. El repaso espaciado (SM-2) opera sobre **tarjetas** (`certdeck_flashcard_questions`); su tabla de estado `certdeck_user_spaced_repetition` tiene una **FK a flashcards** (script-006.sql). Las preguntas de examen viven en un **catálogo aparte** (`certdeck_exam_questions`) y **no** son tarjetas.
2. El examen es una evaluación de **conjunto exacto** (RF-29), pensada como simulacro de certificación; no usa la autoevaluación de memoria (fail/correct/easy) que alimenta el SM-2.
3. Mezclar ambos exigiría: o bien una segunda tabla de SRS para examen, o relajar la FK actual y unificar identificadores de tarjeta y examen — un cambio estructural no trivial.

## Decisión

**Mantener Q-06 tal cual: la práctica de examen NO modifica `certdeck_user_spaced_repetition`.**

- La práctica de examen **registra cada intento** en `certdeck_user_question_attempts` (`question_source = 'exam'`, `exercise_type ∈ {exam_single, exam_multiple}`), vía la Edge Function autoritativa `certdeck-exam-grade`.
- Esos intentos alimentan el **histórico de examen** (intentos/aciertos) que se muestra en Progresos y en la propia pestaña de Examen, pero **no** el algoritmo de repaso.
- El repaso espaciado sigue alimentándose **solo** de las tarjetas (lecciones y repasos), vía `certdeck-spaced-review-update`.

## Alternativas consideradas

1. **Unificar examen y tarjetas en el mismo SRS.** Rechazada: requiere cambio estructural (FK/identificadores) y mezcla dos modelos de evaluación distintos (autoevaluación de memoria vs. acierto/fallo de examen), con riesgo de ensuciar los intervalos de repaso.
2. **Segunda tabla de SRS para examen.** Rechazada por ahora: complejidad sin demanda clara; las preguntas de examen son escasas y se practican bajo demanda, no en una curva de olvido.
3. **No tocar el repaso; registrar solo intentos (statu quo Q-06).** **Elegida.**

## Consecuencias

**Positivas:**
- Se evita un cambio estructural y se mantiene el SRS limpio y centrado en tarjetas.
- El examen aporta valor (histórico, práctica filtrable) sin acoplarse al repaso.
- La corrección autoritativa (RF-29/RSP-03) y el registro del intento quedan en una única función (`certdeck-exam-grade`).

**Negativas / a revisar en el futuro:**
- Fallar repetidamente una pregunta de examen **no** programa un repaso automático de ese concepto. Si se quisiera, sería un ADR futuro (p. ej. mapear el `topic_id` del examen a un refuerzo de las tarjetas del tema).
- El "acierto medio" global (Progresos) y el "acierto de examen" son métricas **separadas** a propósito.
