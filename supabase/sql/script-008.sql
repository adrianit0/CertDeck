-- =============================================================================
-- CertDeck — script-008.sql
-- Fase 5 · Versión del catálogo de un curso (caché de contenido en cliente).
-- Fecha: 2026-06-16
--
-- Crea la función certdeck_course_catalog_version(uuid): devuelve un TOKEN de
-- versión del CATÁLOGO de un curso (etapas + temas + lecciones). El cliente lo
-- guarda junto al catálogo cacheado y, al arrancar, solo vuelve a descargar el
-- contenido pesado si el token cambia (ADR 0009 · RNF-17).
--
-- El token combina:
--   * el INSTANTE de última actualización (max updated_at) del curso y de sus
--     etapas/temas/lecciones, y
--   * un RECUENTO de filas (etapas + temas + lecciones),
-- de modo que detecta tanto EDICIONES (cambia el max updated_at) como ALTAS y
-- BAJAS (cambia el recuento), aunque la baja no fuera la fila más reciente.
--
-- Se ejecuta como el USUARIO que llama (security invoker, por defecto): la RLS de
-- script-001.sql aplica y solo cuenta el contenido PUBLICADO, igual que lo que el
-- cliente cachea. NO usa security definer (evitaría la RLS y contaría borradores).
--
-- Dependencias: script-001.sql aplicado.
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- Idempotente: CREATE OR REPLACE.
-- =============================================================================

create or replace function public.certdeck_course_catalog_version(p_course_id uuid)
returns text
language sql
stable
as $$
  select
    coalesce(
      extract(epoch from greatest(
        coalesce((select max(updated_at) from public.certdeck_courses
                   where id = p_course_id), 'epoch'),
        coalesce((select max(updated_at) from public.certdeck_stages
                   where course_id = p_course_id), 'epoch'),
        coalesce((select max(t.updated_at) from public.certdeck_topics t
                   join public.certdeck_stages s on s.id = t.stage_id
                   where s.course_id = p_course_id), 'epoch'),
        coalesce((select max(l.updated_at) from public.certdeck_lessons l
                   join public.certdeck_topics t on t.id = l.topic_id
                   join public.certdeck_stages s on s.id = t.stage_id
                   where s.course_id = p_course_id), 'epoch')
      ))::bigint::text,
      '0'
    )
    || '.' ||
    (
      (select count(*) from public.certdeck_stages
        where course_id = p_course_id)
      + (select count(*) from public.certdeck_topics t
          join public.certdeck_stages s on s.id = t.stage_id
          where s.course_id = p_course_id)
      + (select count(*) from public.certdeck_lessons l
          join public.certdeck_topics t on t.id = l.topic_id
          join public.certdeck_stages s on s.id = t.stage_id
          where s.course_id = p_course_id)
    )::text;
$$;

-- El cliente la invoca con el JWT del usuario a través de la Edge Function
-- certdeck-content-version (rpc). Debe poder ejecutarla cualquier autenticado.
grant execute on function public.certdeck_course_catalog_version(uuid) to authenticated;

-- =============================================================================
-- Fin de script-008.sql
-- =============================================================================
