-- =============================================================================
-- CertDeck — script-006.sql
-- Fase 5 (v2.1) · Estado de REPETICIÓN ESPACIADA por tarjeta y usuario.
-- Fecha: 2026-06-16
--
-- Crea: certdeck_user_spaced_repetition (RF-33, RN-13…17, ADR 0002).
-- Es la fuente de verdad del algoritmo SM-2 simplificado (ver app/lib/srs.ts y,
-- en v2.2, la Edge Function certdeck-spaced-review-update). Solo aplica a
-- tarjetas (flashcards); el examen NO alimenta el repaso en el MVP (Q-06).
--
-- RLS estricta: cada usuario solo accede a SUS filas (auth.uid() = user_id).
-- Constitución §16 / RSP-01. Prefijo `certdeck_` (§7/§12.2).
--
-- Migración hacia adelante, idempotente (RNF-10). Depende de script-001/002.sql
-- (certdeck_flashcard_questions) y reutiliza el trigger certdeck_set_updated_at.
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- =============================================================================

create table if not exists public.certdeck_user_spaced_repetition (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users (id) on delete cascade,
  question_id      uuid not null references public.certdeck_flashcard_questions (id) on delete cascade,
  -- Estado del algoritmo (valores por defecto = tarjeta nueva, Q-03).
  ease_factor      numeric(4,2) not null default 2.5 check (ease_factor >= 1.3),
  interval_days    integer not null default 0 check (interval_days >= 0),
  repetitions      integer not null default 0 check (repetitions >= 0),
  lapses           integer not null default 0 check (lapses >= 0),
  is_problematic   boolean not null default false,
  due_at           timestamptz not null default now(),
  last_reviewed_at timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (user_id, question_id)
);

-- Índices para la selección de tarjetas vencidas del usuario (due_at <= now).
create index if not exists idx_certdeck_usr_user
  on public.certdeck_user_spaced_repetition (user_id);
create index if not exists idx_certdeck_usr_user_due
  on public.certdeck_user_spaced_repetition (user_id, due_at);

drop trigger if exists trg_certdeck_usr_updated_at on public.certdeck_user_spaced_repetition;
create trigger trg_certdeck_usr_updated_at
  before update on public.certdeck_user_spaced_repetition
  for each row execute function public.certdeck_set_updated_at();

-- =============================================================================
-- RLS — cada usuario solo ve/gestiona SUS filas.
-- =============================================================================
alter table public.certdeck_user_spaced_repetition enable row level security;

drop policy if exists "certdeck_usr_select_own" on public.certdeck_user_spaced_repetition;
create policy "certdeck_usr_select_own"
  on public.certdeck_user_spaced_repetition for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_usr_insert_own" on public.certdeck_user_spaced_repetition;
create policy "certdeck_usr_insert_own"
  on public.certdeck_user_spaced_repetition for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "certdeck_usr_update_own" on public.certdeck_user_spaced_repetition;
create policy "certdeck_usr_update_own"
  on public.certdeck_user_spaced_repetition for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- =============================================================================
-- Fin de script-006.sql
-- =============================================================================
