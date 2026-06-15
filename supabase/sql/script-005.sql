-- =============================================================================
-- CertDeck — script-005.sql
-- Fase 5 (v1) · Migración de persistencia del PROGRESO a la BD (ADR 0006).
-- Fecha: 2026-06-15
--
-- Traslada a la BD lo que vivía SOLO en localStorage (`certdeck:progress`):
--   1. xp / anki_count por lección  -> +columnas en certdeck_user_lesson_progress
--   2. actividad de repasos          -> nueva certdeck_user_review_sessions
--   3. errores pendientes            -> nueva certdeck_user_failed_questions
--   (los días activos / racha se DERIVAN de completed_at y review.created_at;
--    no se almacena un contador denormalizado.)
--
-- RLS estricta: cada usuario solo accede a SUS filas (auth.uid() = user_id).
-- Constitución §16 / RSP-01. Prefijo `certdeck_` (§7/§12.2).
--
-- Migración hacia adelante, idempotente (RNF-10). Depende de script-003.sql.
-- NO ejecutado por el agente (Constitución §4).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. certdeck_user_lesson_progress — +xp, +anki_count.
-- -----------------------------------------------------------------------------
alter table public.certdeck_user_lesson_progress
  add column if not exists xp         integer not null default 0 check (xp >= 0);

alter table public.certdeck_user_lesson_progress
  add column if not exists anki_count integer not null default 0 check (anki_count >= 0);

-- -----------------------------------------------------------------------------
-- 2. certdeck_user_review_sessions — una fila por sesión de repaso (no atada a
--    una lección). Se AGREGAN para las métricas (xp/answers/correct/anki) y sus
--    fechas cuentan como días activos para la racha.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_user_review_sessions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  review_type     text not null
                    check (review_type in
                      ('topic-review', 'general-review', 'topic-errors', 'general-errors')),
  xp              integer not null default 0 check (xp >= 0),
  total_answers   integer not null default 0 check (total_answers >= 0),
  correct_answers integer not null default 0 check (correct_answers >= 0),
  anki_cards      integer not null default 0 check (anki_cards >= 0),
  created_at      timestamptz not null default now()
);

create index if not exists idx_certdeck_urs_user
  on public.certdeck_user_review_sessions (user_id);
create index if not exists idx_certdeck_urs_user_created
  on public.certdeck_user_review_sessions (user_id, created_at);

-- -----------------------------------------------------------------------------
-- 3. certdeck_user_failed_questions — set de preguntas falladas pendientes de
--    corrección. Una pregunta por usuario como máximo (unique); se da de alta
--    al fallar y de baja al recuperarse.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_user_failed_questions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  question_id uuid not null,
  lesson_id   uuid references public.certdeck_lessons (id) on delete set null,
  created_at  timestamptz not null default now(),
  unique (user_id, question_id)
);

create index if not exists idx_certdeck_ufq_user
  on public.certdeck_user_failed_questions (user_id);

-- =============================================================================
-- RLS — cada usuario solo ve/gestiona SUS filas.
-- =============================================================================
alter table public.certdeck_user_review_sessions  enable row level security;
alter table public.certdeck_user_failed_questions enable row level security;

-- Sesiones de repaso: select/insert/delete propios (no se actualizan).
drop policy if exists "certdeck_urs_select_own" on public.certdeck_user_review_sessions;
create policy "certdeck_urs_select_own"
  on public.certdeck_user_review_sessions for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_urs_insert_own" on public.certdeck_user_review_sessions;
create policy "certdeck_urs_insert_own"
  on public.certdeck_user_review_sessions for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "certdeck_urs_delete_own" on public.certdeck_user_review_sessions;
create policy "certdeck_urs_delete_own"
  on public.certdeck_user_review_sessions for delete
  to authenticated using (auth.uid() = user_id);

-- Errores pendientes: select/insert/delete propios.
drop policy if exists "certdeck_ufq_select_own" on public.certdeck_user_failed_questions;
create policy "certdeck_ufq_select_own"
  on public.certdeck_user_failed_questions for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_ufq_insert_own" on public.certdeck_user_failed_questions;
create policy "certdeck_ufq_insert_own"
  on public.certdeck_user_failed_questions for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "certdeck_ufq_delete_own" on public.certdeck_user_failed_questions;
create policy "certdeck_ufq_delete_own"
  on public.certdeck_user_failed_questions for delete
  to authenticated using (auth.uid() = user_id);

-- =============================================================================
-- Fin de script-005.sql
-- =============================================================================
