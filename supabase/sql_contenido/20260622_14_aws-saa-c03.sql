-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 14
-- Archivo: supabase/sql_contenido/20260622_14_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DUODÉCIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - RRS" (position 12) — diapositiva 45
--       L1 (normal)  ¿Qué es RRS?                 (slide 45)
--       L2 (normal)  Historia y coste de RRS      (slide 45)
--       L3 (normal)  Estado actual de RRS         (slide 45)
--       L4 (review)  Repaso: RRS
--       L5 (final)   Lección final: S3 Storage Classes - RRS
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
-- TEMA: S3 Storage Classes - RRS  (etapa "Básico" = position 1; tema position 12)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - RRS',
       'S3 Reduced Redundancy Storage (RRS): una clase de almacenamiento heredada (legacy) que ya no es rentable ni recomendada.',
       'S3 Reduced Redundancy Storage (RRS) es una clase de almacenamiento heredada (legacy) pensada para almacenar datos no críticos y reproducibles con niveles de redundancia menores que el almacenamiento Standard de S3. RRS se introdujo en 2010 y, en aquel momento, era más barata que S3 Standard. En 2018, la infraestructura de S3 Standard cambió y el coste del almacenamiento Standard cayó muy por debajo del de RRS. Actualmente RRS no aporta ningún beneficio de coste a los clientes a cambio de su redundancia reducida y no tiene cabida en los casos de uso de almacenamiento modernos. RRS ya no es rentable y no se recomienda su uso. Puede aparecer todavía en la AWS Console como una opción debido a clientes heredados.',
       12,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es RRS?',
      'Una clase heredada para datos no críticos y reproducibles con menor redundancia.', 'normal'),
  (2, 'Historia y coste de RRS',
      'De 2010 (más barata) a 2018, cuando Standard cayó por debajo de RRS.', 'normal'),
  (3, 'Estado actual de RRS',
      'Por qué ya no es rentable ni recomendada, y por qué sigue apareciendo.', 'normal'),
  (4, 'Repaso: RRS',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Storage Classes - RRS',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es RRS? (slide 45)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Reduced Redundancy Storage',
      E'**S3 Reduced Redundancy Storage (RRS)** es una clase de almacenamiento **heredada (legacy)**.\n\nSe pensó para almacenar **datos no críticos y reproducibles** con **niveles de redundancia menores** que el almacenamiento **Standard** de S3.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué significan las siglas RRS en S3?',
   'Reduced Redundancy Storage',
   'Rapid Retrieval Storage',
   'Regional Replication Service',
   'RRS = Reduced Redundancy Storage, almacenamiento de redundancia reducida.'),
  ('true_false',
   'S3 RRS es una clase de almacenamiento heredada (legacy).',
   'Verdadero', null, null,
   'RRS es una clase legacy que ya no se recomienda.'),
  ('multiple_choice',
   '¿Para qué tipo de datos se diseñó RRS?',
   'Datos no críticos y reproducibles',
   'Datos críticos que no se pueden recrear',
   'Datos de acceso en tiempo real con baja latencia',
   'RRS era para datos no críticos y reproducibles, con menor redundancia.'),
  ('multiple_choice',
   '¿Qué nivel de redundancia ofrece RRS frente a S3 Standard?',
   'Menor redundancia que Standard',
   'Mayor redundancia que Standard',
   'La misma redundancia que Standard',
   'RRS reduce la redundancia respecto a Standard, de ahí su nombre.'),
  ('anki_card',
   '¿Qué es S3 RRS en una frase?',
   'Una clase heredada para datos no críticos y reproducibles con menor redundancia que Standard.',
   null, null,
   'Es la definición esencial de Reduced Redundancy Storage.')
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
-- LECCIÓN 2 — Historia y coste de RRS (slide 45)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'De 2010 a 2018',
      E'- **2010**: se introduce RRS y, en aquel momento, era **más barata** que el almacenamiento **Standard**.\n- **2018**: la **infraestructura** de S3 Standard **cambia** y el coste de Standard **cae muy por debajo** del de RRS.\n\nDesde entonces, la ventaja de coste de RRS **desapareció**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿En qué año se introdujo RRS? (un número)',
   '2010', null, null,
   'RRS se introdujo en 2010, cuando era más barata que Standard.'),
  ('multiple_choice',
   '¿Qué pasó en 2018 con S3 Standard?',
   'Su infraestructura cambió y su coste cayó por debajo del de RRS',
   'Se eliminó por completo el almacenamiento Standard',
   'Standard pasó a ser más caro que RRS',
   'En 2018 Standard cambió y abarató su coste por debajo de RRS.'),
  ('true_false',
   'Cuando se introdujo en 2010, RRS era más barata que S3 Standard.',
   'Verdadero', null, null,
   'En 2010 RRS sí ofrecía un ahorro frente a Standard.'),
  ('multiple_choice',
   '¿Por qué RRS perdió su ventaja de coste?',
   'Porque el coste de S3 Standard cayó por debajo del de RRS en 2018',
   'Porque AWS subió mucho el precio de RRS',
   'Porque RRS dejó de almacenar datos reproducibles',
   'El abaratamiento de Standard en 2018 dejó a RRS sin ventaja.'),
  ('anki_card',
   '¿Qué dos años son clave en la historia de RRS y por qué?',
   '2010 (se introdujo, más barata que Standard) y 2018 (Standard cayó por debajo de RRS).',
   null, null,
   'Marcan el auge y la pérdida de ventaja de coste de RRS.')
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
-- LECCIÓN 3 — Estado actual de RRS (slide 45)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Ya no es rentable',
      E'- RRS **no aporta ningún beneficio de coste** a cambio de su redundancia reducida.\n- **No tiene cabida** en los casos de uso de almacenamiento **modernos**.\n- **No es rentable** y **no se recomienda** su uso.\n- Puede **aparecer todavía** en la **AWS Console** como opción, por **clientes heredados** (legacy).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'AWS recomienda usar RRS para nuevos casos de uso de almacenamiento.',
   'Falso', null, null,
   'RRS ya no es rentable ni recomendada; no tiene cabida en usos modernos.'),
  ('multiple_choice',
   '¿Por qué RRS puede seguir apareciendo en la AWS Console?',
   'Por clientes heredados (legacy)',
   'Porque es la clase recomendada por defecto',
   'Porque ofrece la mayor durabilidad',
   'Sigue visible por compatibilidad con clientes legacy.'),
  ('multiple_choice',
   '¿Qué beneficio de coste aporta hoy RRS por su redundancia reducida?',
   'Ninguno',
   'Un 50% de ahorro frente a Standard',
   'Un 20% de ahorro frente a Standard-IA',
   'Actualmente RRS no aporta ningún beneficio de coste.'),
  ('true_false',
   'RRS tiene cabida en los casos de uso de almacenamiento modernos.',
   'Falso', null, null,
   'RRS no tiene cabida en los usos modernos de almacenamiento.'),
  ('anki_card',
   '¿Cuál es la recomendación actual sobre RRS?',
   'No usarla: ya no es rentable y solo sigue por clientes heredados.',
   null, null,
   'RRS es legacy; se desaconseja para cualquier caso nuevo.')
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
-- LECCIÓN 4 — Repaso: RRS (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: RRS',
      'Repasamos qué es **RRS** (clase **heredada** para datos no críticos y reproducibles con **menor redundancia**), su **historia** (2010 → 2018) y por qué **ya no es rentable ni recomendada**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: S3 Storage Classes - RRS (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 12 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 RRS**: una clase **heredada** para datos **no críticos y reproducibles** con **menor redundancia**, que fue **más barata** en 2010 pero perdió su ventaja en **2018**, y que hoy **no es rentable ni recomendada** (solo persiste por clientes legacy). Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_14_aws-saa-c03.sql
-- =============================================================================
