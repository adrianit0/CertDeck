-- =============================================================================
-- CertDeck — script-007.sql
-- Fase 5 · Reporte de errores en tarjetas (asistencia técnica).
-- Fecha: 2026-06-16
--
-- Crea: certdeck_user_question_reports — reportes de error que el usuario envía
-- desde una tarjeta (pregunta de flashcard o de examen) mediante el botón de
-- "asistencia técnica". Sirve para que el propietario revise y corrija errores
-- de contenido (bugs, faltas de ortografía, respuestas incorrectas, etc.).
--
-- Relacionado: ADR 0008. RF-30 (Requisitos).
--
-- RLS estricta: cada usuario solo accede a SUS reportes (auth.uid() = user_id).
-- La GESTIÓN/RESOLUCIÓN de reportes la hará el propietario con service_role (que
-- omite RLS) o un panel de administración futuro; por eso `status` no se expone
-- a escritura del usuario más allá del alta.
--
-- Convención: prefijo obligatorio `certdeck_` (Constitución §7/§12.2). No se
-- referencia con FK la pregunta porque puede vivir en dos catálogos distintos
-- (flashcards vs examen); se guarda `question_source` + `question_id` y, además,
-- una INSTANTÁNEA del enunciado (`question_text`) para que el reporte siga
-- siendo legible aunque la pregunta cambie o se elimine.
--
-- Dependencias: script-001.sql, script-002.sql y script-003.sql aplicados.
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- Idempotente: IF NOT EXISTS / DROP POLICY IF EXISTS.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- certdeck_user_question_reports — un reporte de error por fila.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_user_question_reports (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  -- Pregunta reportada. Sin FK (vive en flashcards O en examen); se desambigua
  -- con question_source, igual que en certdeck_user_question_attempts.
  question_id     uuid not null,
  question_source text not null check (question_source in ('flashcard', 'exam')),
  -- Contexto opcional para localizar la pregunta al revisarla.
  lesson_id       uuid references public.certdeck_lessons (id) on delete set null,
  course_id       uuid references public.certdeck_courses (id) on delete set null,
  -- Instantánea del enunciado al momento del reporte (legibilidad futura).
  question_text   text,
  -- Motivo (combo) + detalle libre escrito por el usuario.
  category        text not null
                    check (category in
                      ('bug', 'spelling', 'wrong_answer', 'confusing', 'other')),
  details         text check (details is null or char_length(details) <= 2000),
  -- Ciclo de vida del reporte (lo gestiona el propietario más adelante).
  status          text not null default 'open'
                    check (status in ('open', 'reviewing', 'resolved', 'dismissed')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_certdeck_uqr_user
  on public.certdeck_user_question_reports (user_id);
create index if not exists idx_certdeck_uqr_question
  on public.certdeck_user_question_reports (question_id);
create index if not exists idx_certdeck_uqr_status
  on public.certdeck_user_question_reports (status);

drop trigger if exists trg_certdeck_uqr_updated_at on public.certdeck_user_question_reports;
create trigger trg_certdeck_uqr_updated_at
  before update on public.certdeck_user_question_reports
  for each row execute function public.certdeck_set_updated_at();

-- =============================================================================
-- RLS — cada usuario solo ve/crea SUS reportes. No puede editarlos ni borrarlos
-- (la gestión es responsabilidad del propietario vía service_role).
-- =============================================================================
alter table public.certdeck_user_question_reports enable row level security;

drop policy if exists "certdeck_uqr_select_own" on public.certdeck_user_question_reports;
create policy "certdeck_uqr_select_own"
  on public.certdeck_user_question_reports for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "certdeck_uqr_insert_own" on public.certdeck_user_question_reports;
create policy "certdeck_uqr_insert_own"
  on public.certdeck_user_question_reports for insert
  to authenticated with check (auth.uid() = user_id);

-- =============================================================================
-- Fin de script-007.sql
-- =============================================================================
