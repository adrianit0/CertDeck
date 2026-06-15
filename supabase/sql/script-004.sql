-- =============================================================================
-- CertDeck — script-004.sql
-- Fase 5 · Limpieza del modelo de juego y nuevo tipo de ejercicio.
-- Fecha: 2026-06-15
--
-- Cambios (migración hacia adelante, no se sobrescriben scripts previos · RNF-10):
--   1. certdeck_lessons: se elimina `estimated_minutes` (ya no se usa).
--   2. certdeck_flashcard_questions:
--        - se elimina `position` (las preguntas se extraen todas y se muestran
--          en orden ALEATORIO; el orden ya no se almacena);
--        - se elimina `difficulty` (se prima la calidad y la adaptación al
--          temario sobre forzar un reparto fácil/media/difícil);
--        - se añade el tipo de ejercicio `text_input` (respuesta escrita);
--        - nueva clave natural de idempotencia para los seeds: (lesson_id, question).
--   3. certdeck_user_question_attempts: `text_input` admitido en exercise_type.
--
-- Dependencias: script-001.sql, script-002.sql y script-003.sql aplicados.
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- Idempotente: usa IF EXISTS / DROP CONSTRAINT IF EXISTS.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. certdeck_lessons — quitar estimated_minutes.
--    (Su CHECK asociado se elimina junto con la columna.)
-- -----------------------------------------------------------------------------
alter table public.certdeck_lessons
  drop column if exists estimated_minutes;

-- -----------------------------------------------------------------------------
-- 2. certdeck_flashcard_questions — quitar position y difficulty,
--    añadir el tipo text_input y una clave natural por (lesson_id, question).
-- -----------------------------------------------------------------------------
-- Al eliminar `position` se elimina también su constraint UNIQUE (lesson_id, position).
alter table public.certdeck_flashcard_questions
  drop column if exists position;

alter table public.certdeck_flashcard_questions
  drop column if exists difficulty;

-- Nueva clave natural para que los seeds sean idempotentes sin `position`.
alter table public.certdeck_flashcard_questions
  drop constraint if exists certdeck_flashcard_questions_lesson_question_key;
alter table public.certdeck_flashcard_questions
  add constraint certdeck_flashcard_questions_lesson_question_key
  unique (lesson_id, question);

-- Ampliar el catálogo de tipos: + text_input.
--   * text_input -> question + correct_answer (1 palabra/número). No usa
--     respuestas incorrectas; la validación es tolerante en el cliente/Edge.
alter table public.certdeck_flashcard_questions
  drop constraint if exists certdeck_flashcard_questions_exercise_type_check;
alter table public.certdeck_flashcard_questions
  add constraint certdeck_flashcard_questions_exercise_type_check
  check (exercise_type in ('anki_card', 'multiple_choice', 'true_false', 'text_input'));

-- -----------------------------------------------------------------------------
-- 3. certdeck_user_question_attempts — admitir text_input.
-- -----------------------------------------------------------------------------
alter table public.certdeck_user_question_attempts
  drop constraint if exists certdeck_user_question_attempts_exercise_type_check;
alter table public.certdeck_user_question_attempts
  add constraint certdeck_user_question_attempts_exercise_type_check
  check (exercise_type in
    ('anki_card', 'multiple_choice', 'true_false', 'text_input', 'exam_single', 'exam_multiple'));

-- =============================================================================
-- Fin de script-004.sql
-- =============================================================================
