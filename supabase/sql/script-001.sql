-- =============================================================================
-- CertDeck — script-001.sql
-- Fase 5 (v0 Fundaciones) · Esquema de CONTENIDO educativo.
-- Fecha: 2026-06-15
--
-- Crea: certdeck_courses, certdeck_stages, certdeck_topics, certdeck_lessons,
--       certdeck_lesson_screens.
-- Incluye: PK/FK, constraints, índices, trigger de updated_at y RLS de
--          SOLO LECTURA del contenido publicado.
--
-- Convención: TODAS las tablas llevan el prefijo `certdeck_` (Constitución
--             §7/§12.2), porque la base de datos Supabase se comparte con
--             otras aplicaciones.
--
-- Dependencias: ninguna (primer script).
-- NO ejecutado por el agente (Constitución §4/§7). El propietario lo revisa
-- y lo aplica manualmente en Supabase (SQL Editor o su flujo habitual).
--
-- Idempotente: usa IF NOT EXISTS / CREATE OR REPLACE / DROP POLICY IF EXISTS.
-- =============================================================================

-- Extensión para UUIDs (suele estar disponible en Supabase).
create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- Trigger genérico para mantener updated_at.
-- Prefijado para no colisionar con funciones de otras apps en el mismo esquema.
-- -----------------------------------------------------------------------------
create or replace function public.certdeck_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- certdeck_courses — Cursos disponibles.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_courses (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  slug        text not null unique,
  description text,
  icon        text,
  color       text,
  difficulty  smallint not null default 1 check (difficulty between 1 and 5),
  is_published boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_certdeck_courses_published
  on public.certdeck_courses (is_published);

drop trigger if exists trg_certdeck_courses_updated_at on public.certdeck_courses;
create trigger trg_certdeck_courses_updated_at
  before update on public.certdeck_courses
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_stages — Etapas de un curso.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_stages (
  id          uuid primary key default gen_random_uuid(),
  course_id   uuid not null references public.certdeck_courses (id) on delete cascade,
  title       text not null,
  description text,
  position    integer not null default 0,
  is_published boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (course_id, position)
);

create index if not exists idx_certdeck_stages_course
  on public.certdeck_stages (course_id);
create index if not exists idx_certdeck_stages_published
  on public.certdeck_stages (is_published);

drop trigger if exists trg_certdeck_stages_updated_at on public.certdeck_stages;
create trigger trg_certdeck_stages_updated_at
  before update on public.certdeck_stages
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_topics — Temas dentro de una etapa.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_topics (
  id          uuid primary key default gen_random_uuid(),
  stage_id    uuid not null references public.certdeck_stages (id) on delete cascade,
  title       text not null,
  description text,
  summary     text,
  position    integer not null default 0,
  is_published boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (stage_id, position)
);

create index if not exists idx_certdeck_topics_stage
  on public.certdeck_topics (stage_id);
create index if not exists idx_certdeck_topics_published
  on public.certdeck_topics (is_published);

drop trigger if exists trg_certdeck_topics_updated_at on public.certdeck_topics;
create trigger trg_certdeck_topics_updated_at
  before update on public.certdeck_topics
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_lessons — Lecciones dentro de un tema.
-- lesson_type: normal | review | error_correction | expansion | final
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_lessons (
  id                uuid primary key default gen_random_uuid(),
  topic_id          uuid not null references public.certdeck_topics (id) on delete cascade,
  title             text not null,
  description       text,
  lesson_type       text not null default 'normal'
                      check (lesson_type in
                        ('normal', 'review', 'error_correction', 'expansion', 'final')),
  position          integer not null default 0,
  estimated_minutes smallint check (estimated_minutes is null or estimated_minutes >= 0),
  is_published      boolean not null default false,
  unlock_rule       jsonb,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (topic_id, position)
);

create index if not exists idx_certdeck_lessons_topic
  on public.certdeck_lessons (topic_id);
create index if not exists idx_certdeck_lessons_type
  on public.certdeck_lessons (lesson_type);
create index if not exists idx_certdeck_lessons_published
  on public.certdeck_lessons (is_published);

drop trigger if exists trg_certdeck_lessons_updated_at on public.certdeck_lessons;
create trigger trg_certdeck_lessons_updated_at
  before update on public.certdeck_lessons
  for each row execute function public.certdeck_set_updated_at();

-- -----------------------------------------------------------------------------
-- certdeck_lesson_screens — Pantallas de contenido de una lección.
-- -----------------------------------------------------------------------------
create table if not exists public.certdeck_lesson_screens (
  id         uuid primary key default gen_random_uuid(),
  lesson_id  uuid not null references public.certdeck_lessons (id) on delete cascade,
  title      text,
  body       text not null,
  position   integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (lesson_id, position)
);

create index if not exists idx_certdeck_lesson_screens_lesson
  on public.certdeck_lesson_screens (lesson_id);

drop trigger if exists trg_certdeck_lesson_screens_updated_at on public.certdeck_lesson_screens;
create trigger trg_certdeck_lesson_screens_updated_at
  before update on public.certdeck_lesson_screens
  for each row execute function public.certdeck_set_updated_at();

-- =============================================================================
-- RLS — Contenido: SOLO LECTURA de lo PUBLICADO para usuarios autenticados.
-- La escritura (insert/update/delete) queda denegada por defecto (sin policy);
-- la carga de contenido la hace el propietario (service_role omite RLS).
-- Una pantalla de lección es visible si su lección/tema/etapa/curso lo están.
-- =============================================================================
alter table public.certdeck_courses        enable row level security;
alter table public.certdeck_stages         enable row level security;
alter table public.certdeck_topics         enable row level security;
alter table public.certdeck_lessons        enable row level security;
alter table public.certdeck_lesson_screens enable row level security;

drop policy if exists "certdeck_courses_read_published" on public.certdeck_courses;
create policy "certdeck_courses_read_published"
  on public.certdeck_courses for select
  to authenticated
  using (is_published = true);

drop policy if exists "certdeck_stages_read_published" on public.certdeck_stages;
create policy "certdeck_stages_read_published"
  on public.certdeck_stages for select
  to authenticated
  using (
    is_published = true
    and exists (
      select 1 from public.certdeck_courses c
      where c.id = certdeck_stages.course_id and c.is_published = true
    )
  );

drop policy if exists "certdeck_topics_read_published" on public.certdeck_topics;
create policy "certdeck_topics_read_published"
  on public.certdeck_topics for select
  to authenticated
  using (
    is_published = true
    and exists (
      select 1 from public.certdeck_stages s
      where s.id = certdeck_topics.stage_id and s.is_published = true
    )
  );

drop policy if exists "certdeck_lessons_read_published" on public.certdeck_lessons;
create policy "certdeck_lessons_read_published"
  on public.certdeck_lessons for select
  to authenticated
  using (
    is_published = true
    and exists (
      select 1 from public.certdeck_topics t
      where t.id = certdeck_lessons.topic_id and t.is_published = true
    )
  );

drop policy if exists "certdeck_lesson_screens_read_published" on public.certdeck_lesson_screens;
create policy "certdeck_lesson_screens_read_published"
  on public.certdeck_lesson_screens for select
  to authenticated
  using (
    exists (
      select 1 from public.certdeck_lessons l
      where l.id = certdeck_lesson_screens.lesson_id and l.is_published = true
    )
  );

-- =============================================================================
-- Fin de script-001.sql
-- =============================================================================
