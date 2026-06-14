-- =============================================================================
-- CertDeck — script-002.sql
-- Fase 5 (v1) · Catálogo de PREGUNTAS (estructura, no datos).
-- Fecha: 2026-06-15
--
-- Crea: certdeck_flashcard_questions, certdeck_exam_questions.
-- Incluye: PK/FK, constraints (incl. por tipo de ejercicio), índices,
--          trigger de updated_at y RLS de SOLO LECTURA de lo publicado.
--
-- Convención: todas las tablas con prefijo `certdeck_` (Constitución §7/§12.2).
--
-- Dependencia: requiere `supabase/sql/script-001.sql` aplicado.
--
-- Nota de numeración: el catálogo de preguntas es `script-002`. Las tablas de
-- PROGRESO de usuario (certdeck_user_*) irán en `script-003` (siguiente).
--
-- Nota RNF-14: por simplicidad del MVP, las políticas de lectura exponen al
-- cliente la respuesta correcta. La validación autoritativa de resultados se
-- hará en Edge Functions (ADR 0002); más adelante podrá usarse una vista que
-- oculte la respuesta hasta responder.
--
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- Idempotente.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- certdeck_flashcard_questions
-- Preguntas reutilizables para: tarjeta ANKI, test (3 respuestas) y V/F.
-- exercise_type distingue cómo se renderiza la pregunta.
--   * anki_card       -> question = frontal, correct_answer = reverso
--   * multiple_choice -> correct_answer + incorrect_answer_1/2 (obligatorias)
--   * true_false      -> correct_answer in ('Verdadero','Falso')
-- Las preguntas se ordenan dentro de la lección por `position`.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_flashcard_questions (
  id                 uuid primary key default gen_random_uuid(),
  lesson_id          uuid not null references public.certdeck_lessons (id) on delete cascade,
  exercise_type      text not null
                       check (exercise_type in ('anki_card', 'multiple_choice', 'true_false')),
  position           integer not null default 0,
  question           text not null,
  correct_answer     text not null,
  incorrect_answer_1 text,
  incorrect_answer_2 text,
  explanation        text,
  difficulty         smallint not null default 1 check (difficulty between 1 and 5),
  is_active          boolean not null default true,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (lesson_id, position),
  -- El test de 3 respuestas necesita las dos incorrectas.
  constraint chk_flashcard_mc_has_incorrect check (
    exercise_type <> 'multiple_choice'
    or (incorrect_answer_1 is not null and incorrect_answer_2 is not null)
  ),
  -- Verdadero/Falso: la respuesta correcta solo puede ser 'Verdadero' o 'Falso'.
  constraint chk_flashcard_tf_value check (
    exercise_type <> 'true_false'
    or correct_answer in ('Verdadero', 'Falso')
  )
);

create index if not exists idx_certdeck_flashcard_lesson
  on public.certdeck_flashcard_questions (lesson_id);
create index if not exists idx_certdeck_flashcard_active
  on public.certdeck_flashcard_questions (is_active);

drop trigger if exists trg_certdeck_flashcard_updated_at on public.certdeck_flashcard_questions;
create trigger trg_certdeck_flashcard_updated_at
  before update on public.certdeck_flashcard_questions
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_exam_questions
-- Catálogo especial de preguntas de examen (más difíciles).
--   type_id = 1 -> respuesta única   (correcta = answer_1)
--   type_id = 2 -> respuesta múltiple (correctas = primeras `correct_answers_count`)
-- El frontend SIEMPRE desordena las respuestas y nunca expone el orden interno.
-- lesson_id es opcional (la pregunta puede vivir a nivel de curso/tema).
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_exam_questions (
  id                    uuid primary key default gen_random_uuid(),
  course_id             uuid not null references public.certdeck_courses (id) on delete cascade,
  topic_id              uuid references public.certdeck_topics (id) on delete set null,
  lesson_id             uuid references public.certdeck_lessons (id) on delete set null,
  question              text not null,
  type_id               smallint not null check (type_id in (1, 2)),
  answer_1              text not null,
  answer_2              text,
  answer_3              text,
  answer_4              text,
  answer_5              text,
  answer_6              text,
  correct_answers_count smallint not null default 1 check (correct_answers_count between 1 and 6),
  extra_information     text,
  difficulty            smallint not null default 3 check (difficulty between 1 and 5),
  is_active             boolean not null default true,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- Respuesta única: exactamente 1 correcta.
  constraint chk_exam_single_count check (type_id <> 1 or correct_answers_count = 1)
);

create index if not exists idx_certdeck_exam_course on public.certdeck_exam_questions (course_id);
create index if not exists idx_certdeck_exam_topic on public.certdeck_exam_questions (topic_id);
create index if not exists idx_certdeck_exam_lesson on public.certdeck_exam_questions (lesson_id);
create index if not exists idx_certdeck_exam_active on public.certdeck_exam_questions (is_active);

drop trigger if exists trg_certdeck_exam_updated_at on public.certdeck_exam_questions;
create trigger trg_certdeck_exam_updated_at
  before update on public.certdeck_exam_questions
  for each row execute function public.certdeck_set_updated_at();

-- =============================================================================
-- RLS — lectura de preguntas activas pertenecientes a contenido publicado.
-- Escritura denegada por defecto (la carga la hace el propietario / service_role).
-- =============================================================================
alter table public.certdeck_flashcard_questions enable row level security;
alter table public.certdeck_exam_questions      enable row level security;

drop policy if exists "certdeck_flashcard_read_published" on public.certdeck_flashcard_questions;
create policy "certdeck_flashcard_read_published"
  on public.certdeck_flashcard_questions for select
  to authenticated
  using (
    is_active = true
    and exists (
      select 1
      from public.certdeck_lessons l
      join public.certdeck_topics t on t.id = l.topic_id
      join public.certdeck_stages s on s.id = t.stage_id
      join public.certdeck_courses c on c.id = s.course_id
      where l.id = certdeck_flashcard_questions.lesson_id
        and l.is_published and t.is_published and s.is_published and c.is_published
    )
  );

drop policy if exists "certdeck_exam_read_published" on public.certdeck_exam_questions;
create policy "certdeck_exam_read_published"
  on public.certdeck_exam_questions for select
  to authenticated
  using (
    is_active = true
    and exists (
      select 1 from public.certdeck_courses c
      where c.id = certdeck_exam_questions.course_id and c.is_published = true
    )
  );

-- =============================================================================
-- Fin de script-002.sql
-- =============================================================================
