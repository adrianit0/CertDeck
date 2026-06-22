-- =============================================================================
-- CertDeck — script-009.sql
-- Fase 5 · Sesiones de examen (XP + "cuenta como una lección más").
-- Fecha: 2026-06-22
--
-- Hasta ahora la práctica de examen solo registraba intentos por PREGUNTA en
-- certdeck_user_question_attempts (histórico de aciertos, Q-06). Con la nueva
-- regla de producto, cada SESIÓN de examen:
--   1. otorga XP (base 50 + 1 por cada 2% de acierto, máx 100), y
--   2. cuenta como "una lección más" en el total de lecciones completadas.
--
-- Para ello se registra una fila por sesión, igual que certdeck_user_review_sessions.
-- La XP es AUTORITATIVA: la calcula certdeck-exam-grade en servidor.
--
-- RLS estricta (auth.uid() = user_id). Idempotente (RNF-10). Depende de
-- script-003.sql (auth.users). NO ejecutado por el agente (Constitución §4).
-- =============================================================================

create table if not exists public.certdeck_user_exam_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users (id) on delete cascade,
  xp               integer not null default 0 check (xp >= 0),
  score_percentage integer not null default 0 check (score_percentage between 0 and 100),
  total_questions  integer not null default 0 check (total_questions >= 0),
  correct_count    integer not null default 0 check (correct_count >= 0),
  created_at       timestamptz not null default now()
);

create index if not exists idx_certdeck_ues_user
  on public.certdeck_user_exam_sessions (user_id);
create index if not exists idx_certdeck_ues_user_created
  on public.certdeck_user_exam_sessions (user_id, created_at);

-- =============================================================================
-- RLS — cada usuario solo ve/gestiona SUS filas (no se actualizan).
-- =============================================================================
alter table public.certdeck_user_exam_sessions enable row level security;

drop policy if exists "certdeck_ues_select_own" on public.certdeck_user_exam_sessions;
create policy "certdeck_ues_select_own"
  on public.certdeck_user_exam_sessions for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_ues_insert_own" on public.certdeck_user_exam_sessions;
create policy "certdeck_ues_insert_own"
  on public.certdeck_user_exam_sessions for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "certdeck_ues_delete_own" on public.certdeck_user_exam_sessions;
create policy "certdeck_ues_delete_own"
  on public.certdeck_user_exam_sessions for delete
  to authenticated using (auth.uid() = user_id);

-- =============================================================================
-- Fin de script-009.sql
-- =============================================================================
