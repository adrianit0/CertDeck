-- =============================================================================
-- CertDeck — script-003.sql
-- Fase 5 (v1) · Tablas de PROGRESO de usuario + RLS.
-- Fecha: 2026-06-15
--
-- Crea: certdeck_user_lesson_progress, certdeck_user_question_attempts.
-- (La repetición espaciada `certdeck_user_spaced_repetition` llegará en v2.)
--
-- RLS estricta: cada usuario solo accede a SUS filas (auth.uid() = user_id).
-- Constitución §16 / RSP-01. Prefijo `certdeck_` (§7/§12.2).
--
-- Dependencias: script-001.sql y script-002.sql aplicados.
-- NO ejecutado por el agente (Constitución §4). Idempotente.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- certdeck_user_lesson_progress — progreso por lección y usuario.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_user_lesson_progress (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users (id) on delete cascade,
  lesson_id        uuid not null references public.certdeck_lessons (id) on delete cascade,
  status           text not null default 'in_progress'
                     check (status in ('locked', 'available', 'in_progress', 'completed')),
  score_percentage smallint check (score_percentage between 0 and 100),
  correct_count    integer not null default 0 check (correct_count >= 0),
  incorrect_count  integer not null default 0 check (incorrect_count >= 0),
  completed_at     timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (user_id, lesson_id)
);

create index if not exists idx_certdeck_ulp_user on public.certdeck_user_lesson_progress (user_id);
create index if not exists idx_certdeck_ulp_lesson on public.certdeck_user_lesson_progress (lesson_id);

drop trigger if exists trg_certdeck_ulp_updated_at on public.certdeck_user_lesson_progress;
create trigger trg_certdeck_ulp_updated_at
  before update on public.certdeck_user_lesson_progress
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_user_question_attempts — un registro por intento de pregunta.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_user_question_attempts (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  question_id     uuid not null,
  question_source text not null check (question_source in ('flashcard', 'exam')),
  lesson_id       uuid references public.certdeck_lessons (id) on delete set null,
  exercise_type   text not null
                    check (exercise_type in
                      ('anki_card', 'multiple_choice', 'true_false', 'exam_single', 'exam_multiple')),
  was_correct     boolean not null,
  selected_answer text,
  attempt_number  integer not null default 1 check (attempt_number >= 1),
  created_at      timestamptz not null default now()
);

create index if not exists idx_certdeck_uqa_user on public.certdeck_user_question_attempts (user_id);
create index if not exists idx_certdeck_uqa_question on public.certdeck_user_question_attempts (question_id);
create index if not exists idx_certdeck_uqa_lesson on public.certdeck_user_question_attempts (lesson_id);

-- =============================================================================
-- RLS — cada usuario solo ve/gestiona SUS filas.
-- =============================================================================
alter table public.certdeck_user_lesson_progress  enable row level security;
alter table public.certdeck_user_question_attempts enable row level security;

-- Progreso de lección: select/insert/update propios.
drop policy if exists "certdeck_ulp_select_own" on public.certdeck_user_lesson_progress;
create policy "certdeck_ulp_select_own"
  on public.certdeck_user_lesson_progress for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_ulp_insert_own" on public.certdeck_user_lesson_progress;
create policy "certdeck_ulp_insert_own"
  on public.certdeck_user_lesson_progress for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "certdeck_ulp_update_own" on public.certdeck_user_lesson_progress;
create policy "certdeck_ulp_update_own"
  on public.certdeck_user_lesson_progress for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Intentos de pregunta: select/insert propios (no se actualizan).
drop policy if exists "certdeck_uqa_select_own" on public.certdeck_user_question_attempts;
create policy "certdeck_uqa_select_own"
  on public.certdeck_user_question_attempts for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_uqa_insert_own" on public.certdeck_user_question_attempts;
create policy "certdeck_uqa_insert_own"
  on public.certdeck_user_question_attempts for insert
  to authenticated with check (auth.uid() = user_id);

-- =============================================================================
-- Fin de script-003.sql
-- =============================================================================
