-- =============================================================================
-- CertDeck — CONTENIDO · Curso: AWS Solutions Architect Associate (SAA-C03)
-- Archivo: supabase/sql_contenido/20260515_01_aws-saa-c03.sql
-- Fecha: 2026-06-15
--
-- Este archivo contiene SOLO DATOS de contenido (no toca el esquema).
-- Carpeta `sql_contenido/`: el contenido de cada curso se divide en
-- FRAGMENTOS. Nomenclatura: `YYYYMMDD_NN_<slug>.sql` (fecha invertida +
-- contador de 2 dígitos + slug del curso), de modo que el ORDEN ALFABÉTICO
-- coincide con el ORDEN DE EJECUCIÓN en serie (Constitución §7/§12).
-- Idempotente: re-ejecutable sin duplicar.
--
-- Dependencia: requiere que `supabase/sql/script-001.sql` esté aplicado
-- (tabla certdeck_courses y relacionadas).
--
-- Estado actual (fragmento 01): se inserta el CURSO. Las etapas, temas y
-- lecciones llegarán en FRAGMENTOS POSTERIORES (20260515_02_..., etc.)
-- cuando empecemos a crear lecciones.
--
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- =============================================================================

insert into public.certdeck_courses (title, slug, description, icon, color, difficulty, is_published)
values (
  'Amazon Solutions Architect - Associate (AWS SAA - C03)',
  'aws-saa-c03',
  'Preparación para la certificación AWS Certified Solutions Architect – Associate (SAA-C03): diseño de arquitecturas seguras, resilientes, de alto rendimiento y optimizadas en costes sobre AWS.',
  '☁️',
  '#FF9900',
  3,
  true
)
on conflict (slug) do update set
  title       = excluded.title,
  description = excluded.description,
  icon        = excluded.icon,
  color       = excluded.color,
  difficulty  = excluded.difficulty,
  is_published = excluded.is_published,
  updated_at  = now();

-- -----------------------------------------------------------------------------
-- PENDIENTE (se completará al empezar a crear lecciones):
--   - Etapas      -> certdeck_stages      (course_id = curso 'aws-saa-c03')
--   - Temas       -> certdeck_topics
--   - Lecciones   -> certdeck_lessons
--   - Pantallas   -> certdeck_lesson_screens
--   - Preguntas   -> certdeck_flashcard_questions / certdeck_exam_questions (tras v1)
-- Patrón recomendado para enlazar por slug sin hardcodear UUIDs:
--   insert into public.certdeck_stages (course_id, title, position, is_published)
--   select id, 'Nombre etapa', 1, true
--   from public.certdeck_courses where slug = 'aws-saa-c03';
-- -----------------------------------------------------------------------------
