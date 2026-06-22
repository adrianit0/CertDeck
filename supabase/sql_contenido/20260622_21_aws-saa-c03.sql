-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 21
-- Archivo: supabase/sql_contenido/20260622_21_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMONOVENO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Glacier Deep Archive" (position 19) — diapositiva 52
--       L1 (normal)  ¿Qué es Glacier Deep Archive?     (slide 52)
--       L2 (normal)  Los 2 tiers de recuperación       (slide 52)
--       L3 (normal)  Overhead de 40 KB por objeto      (slide 52)
--       L4 (review)  Repaso: Deep Archive
--       L5 (final)   Lección final: Glacier Deep Archive
--   Volumen: POCO -> normal·normal·normal·review·final (5).
--
-- COMPOSICIÓN DINÁMICA (ADR 0005, enmienda 2026-06-16): las lecciones `review`
-- y `final` NO almacenan preguntas propias; sus tarjetas se reciclan en runtime
-- (`certdeck-playable-lesson`): review -> ~4 de las 5 lecciones anteriores;
-- final -> ~6 del mismo tema. Aquí solo llevan una pantalla de introducción.
--
-- Dependencias: script-001.sql + script-002.sql + script-004.sql aplicados y
--               20260515_01/02 aplicados (curso + etapa "Básico").
-- Idempotente: ON CONFLICT sobre claves naturales (position para
-- temas/lecciones/pantallas; (lesson_id, question) para las preguntas).
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TEMA: S3 Storage Classes - Glacier Deep Archive  (position 19)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Glacier Deep Archive',
       'La clase de archivo de menor coste: más barata que Flexible Retrieval pero con mayor coste y tiempo de recuperación, y sin tier Expedited.',
       'S3 Glacier Deep Archive combina S3 y Glacier en un único conjunto de APIs. No es un servicio separado y no requiere un Vault. Es más rentable (más barata) que S3 Glacier Flexible Retrieval, pero tiene un mayor coste de recuperación. Ofrece 2 niveles (tiers) de recuperación: el Standard Tier restaura en un plazo de 12 horas, sin límite de tamaño de archivo, y es la opción por defecto; el Bulk Tier restaura en un plazo de 48 horas, sin límite de tamaño (incluso petabytes). No hay tier Expedited para Glacier Deep Archive. Al igual que Flexible Retrieval, los objetos archivados tienen 40 KB adicionales de datos: 32 KB para el índice y los metadatos, y 8 KB para el nombre del objeto.',
       19,
       true
from public.certdeck_stages s
join public.certdeck_courses c on c.id = s.course_id
where c.slug = 'aws-saa-c03' and s.position = 1
on conflict (stage_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  summary = excluded.summary,
  is_published = excluded.is_published,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- LECCIONES (5) — volumen POCO
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es Glacier Deep Archive?',
      'La clase de archivo más barata, con mayor coste de recuperación.', 'normal'),
  (2, 'Los 2 tiers de recuperación',
      'Standard (12 horas) y Bulk (48 horas); sin Expedited.', 'normal'),
  (3, 'Overhead de 40 KB por objeto',
      'Los mismos 40 KB extra de índice, metadatos y nombre.', 'normal'),
  (4, 'Repaso: Deep Archive',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: Glacier Deep Archive',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es Glacier Deep Archive? (slide 52)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'La clase más barata',
      E'**S3 Glacier Deep Archive** combina **S3 y Glacier** en un **único conjunto de APIs**.\n- **No** es un servicio separado y **no requiere Vault**.\n- Es **más rentable** (más barata) que **Glacier Flexible Retrieval**...\n- ...pero tiene un **mayor coste de recuperación**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cómo es Glacier Deep Archive respecto a Flexible Retrieval?',
   'Más barata de almacenar, pero con mayor coste de recuperación',
   'Más cara de almacenar y de recuperar',
   'Idéntica en coste y velocidad',
   'Deep Archive abarata el almacenamiento a cambio de recuperación más cara.'),
  ('true_false',
   'Glacier Deep Archive combina S3 y Glacier en un único conjunto de APIs.',
   'Verdadero', null, null,
   'Como Flexible Retrieval, unifica S3 y Glacier en una sola API.'),
  ('true_false',
   'Glacier Deep Archive requiere crear y gestionar un Vault.',
   'Falso', null, null,
   'No es un servicio separado ni requiere Vault.'),
  ('multiple_choice',
   '¿Qué posición ocupa Deep Archive en cuanto a coste de almacenamiento?',
   'Es de las clases más baratas de almacenar',
   'Es la más cara de almacenar',
   'Cuesta lo mismo que Standard',
   'Deep Archive es la opción de archivo de menor coste de almacenamiento.'),
  ('anki_card',
   '¿Cuál es el compromiso de Glacier Deep Archive?',
   'Almacenamiento muy barato a cambio de recuperación más cara y lenta.',
   null, null,
   'Es la clase ideal para datos que casi nunca se recuperan.')
) as v(exercise_type, question, correct_answer,
       incorrect_answer_1, incorrect_answer_2, explanation)
on conflict (lesson_id, question) do update set
  exercise_type = excluded.exercise_type,
  correct_answer = excluded.correct_answer,
  incorrect_answer_1 = excluded.incorrect_answer_1,
  incorrect_answer_2 = excluded.incorrect_answer_2,
  explanation = excluded.explanation,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 2 — Los 2 tiers de recuperación (slide 52)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Solo dos tiers',
      E'Hay **2 tiers** de recuperación:\n- **Standard Tier**: restaura en un plazo de **12 horas**. **Sin límite** de tamaño. Es la opción **por defecto**.\n- **Bulk Tier**: restaura en un plazo de **48 horas**. Sin límite de tamaño (incluso **petabytes**).\n\n**No hay tier Expedited** para Glacier Deep Archive.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿En cuántas horas restaura el Standard Tier de Glacier Deep Archive? (un número)',
   '12', null, null,
   'El Standard Tier de Deep Archive restaura en un plazo de 12 horas.'),
  ('multiple_choice',
   '¿En cuánto tiempo restaura el Bulk Tier de Deep Archive?',
   'En un plazo de 48 horas',
   'En un plazo de 12 horas',
   'En 5-12 horas',
   'El Bulk Tier de Deep Archive restaura en hasta 48 horas.'),
  ('true_false',
   'Glacier Deep Archive NO tiene tier Expedited.',
   'Verdadero', null, null,
   'Deep Archive solo ofrece Standard (12 h) y Bulk (48 h); no hay Expedited.'),
  ('multiple_choice',
   '¿Cuál es el tier de recuperación por defecto en Deep Archive?',
   'Standard Tier (12 horas)',
   'Bulk Tier (48 horas)',
   'Expedited Tier (minutos)',
   'El Standard Tier (12 horas) es la opción por defecto.'),
  ('anki_card',
   '¿Qué dos tiers de recuperación ofrece Glacier Deep Archive y en cuánto tiempo?',
   'Standard (12 horas, por defecto) y Bulk (48 horas).',
   null, null,
   'No existe Expedited en Deep Archive.')
) as v(exercise_type, question, correct_answer,
       incorrect_answer_1, incorrect_answer_2, explanation)
on conflict (lesson_id, question) do update set
  exercise_type = excluded.exercise_type,
  correct_answer = excluded.correct_answer,
  incorrect_answer_1 = excluded.incorrect_answer_1,
  incorrect_answer_2 = excluded.incorrect_answer_2,
  explanation = excluded.explanation,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 3 — Overhead de 40 KB por objeto (slide 52)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '40 KB extra por objeto',
      E'Igual que Flexible Retrieval, los objetos archivados tienen **40 KB adicionales** de datos:\n- **32 KB** para el **índice** y los **metadatos**.\n- **8 KB** para el **nombre** del objeto.\n\nConviene **pocos archivos grandes** en vez de muchos pequeños.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos KB adicionales tiene cada objeto archivado en Deep Archive? (un número)',
   '40', null, null,
   'Cada objeto archivado lleva 40 KB extra (32 KB + 8 KB), igual que Flexible Retrieval.'),
  ('multiple_choice',
   '¿Cómo se reparten los 40 KB de overhead por objeto?',
   '32 KB para índice y metadatos, y 8 KB para el nombre',
   '20 KB para índice y 20 KB para el nombre',
   '8 KB para índice y 32 KB para el nombre',
   'Son 32 KB de índice/metadatos y 8 KB del nombre del objeto.'),
  ('true_false',
   'El overhead de 40 KB de Deep Archive es igual al de Glacier Flexible Retrieval.',
   'Verdadero', null, null,
   'Ambas clases añaden los mismos 40 KB por objeto archivado.'),
  ('multiple_choice',
   '¿Qué conviene hacer por el overhead de 40 KB?',
   'Almacenar pocos archivos grandes en vez de muchos pequeños',
   'Almacenar muchos archivos pequeños',
   'Eliminar los metadatos de los objetos',
   'Los 40 KB se acumulan, así que mejor menos archivos y más grandes.'),
  ('anki_card',
   '¿Para qué se reservan los 32 KB y los 8 KB del overhead?',
   '32 KB para índice y metadatos; 8 KB para el nombre del objeto.',
   null, null,
   'Juntos forman los 40 KB extra de cada objeto archivado.')
) as v(exercise_type, question, correct_answer,
       incorrect_answer_1, incorrect_answer_2, explanation)
on conflict (lesson_id, question) do update set
  exercise_type = excluded.exercise_type,
  correct_answer = excluded.correct_answer,
  incorrect_answer_1 = excluded.incorrect_answer_1,
  incorrect_answer_2 = excluded.incorrect_answer_2,
  explanation = excluded.explanation,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Repaso (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Deep Archive',
      'Repasamos **Glacier Deep Archive**: la clase de archivo **más barata** (recuperación más cara que Flexible), sus **2 tiers** (**Standard** 12 h por defecto, **Bulk** 48 h, **sin Expedited**) y el **overhead de 40 KB** por objeto (**32 KB** + **8 KB**). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 19 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Glacier Deep Archive**: la clase de archivo de **menor coste** de almacenamiento (a cambio de recuperación más cara y lenta), con **2 tiers** (**Standard** 12 h por defecto y **Bulk** 48 h, **sin Expedited**) y el mismo **overhead de 40 KB** por objeto que Flexible Retrieval. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_21_aws-saa-c03.sql
-- =============================================================================
