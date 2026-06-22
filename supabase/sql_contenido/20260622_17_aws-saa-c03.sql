-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 17
-- Archivo: supabase/sql_contenido/20260622_17_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOQUINTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - One-Zone-IA" (position 15) — diapositiva 48
--       L1 (normal)  Durabilidad, disponibilidad y redundancia  (slide 48)
--       L2 (normal)  Coste y precios                            (slide 48)
--       L3 (normal)  Recuperación y casos de uso                (slide 48)
--       L4 (review)  Repaso: One-Zone-IA
--       L5 (final)   Lección final: S3 Storage Classes - One-Zone-IA
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
-- TEMA: S3 Storage Classes - One-Zone-IA  (etapa "Básico" = position 1; tema position 15)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - One-Zone-IA',
       'S3 One-Zone-IA (Infrequent Access): datos de acceso poco frecuente con ahorro adicional a costa de almacenarse en una sola AZ y reducir la disponibilidad.',
       'La clase S3 One-Zone-IA (Infrequent Access) está diseñada para datos a los que se accede con poca frecuencia y que admiten un ahorro adicional a cambio de una disponibilidad reducida. Ofrece una durabilidad alta de 11 nueves, igual que S3 Standard y S3 Standard-IA. Su disponibilidad es menor, del 99,5%: al estar en una sola AZ, tiene una disponibilidad incluso más baja que Standard-IA. Es un almacenamiento rentable: cuesta un 20% menos que Standard-IA. Los datos se almacenan en una única zona de disponibilidad (AZ), por lo que existe riesgo de pérdida de datos en caso de desastre de esa AZ. El tiempo de recuperación es de milisegundos (baja latencia). Es ideal para copias de seguridad secundarias de datos on-premises, o para almacenar datos que se pueden recrear en caso de fallo de una AZ; también es adecuada para datos de acceso poco frecuente que no son críticos. En cuanto a precios: cobra por almacenamiento por GB y por peticiones, tiene una tarifa de recuperación (retrieval fee) y un cargo mínimo por duración de almacenamiento de 30 días.',
       15,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Durabilidad, disponibilidad y redundancia',
      'Las garantías de One-Zone-IA y el riesgo de la única AZ.', 'normal'),
  (2, 'Coste y precios',
      'Un 20% menos que Standard-IA y su modelo de precios.', 'normal'),
  (3, 'Recuperación y casos de uso',
      'Latencia en milisegundos y para qué se usa One-Zone-IA.', 'normal'),
  (4, 'Repaso: One-Zone-IA',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Storage Classes - One-Zone-IA',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Durabilidad, disponibilidad y redundancia (slide 48)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es One-Zone-IA?',
      E'**S3 One-Zone-IA** (Infrequent Access) está diseñada para datos de **acceso poco frecuente** que admiten un **ahorro adicional** a cambio de una **disponibilidad reducida**.'),
  (2, 'Durabilidad, disponibilidad y la única AZ',
      E'- **Durabilidad alta**: **11 nueves**, igual que Standard y Standard-IA.\n- **Disponibilidad menor**: **99,5%**. Al estar en una **sola AZ**, su disponibilidad es **aún más baja** que la de Standard-IA.\n- **Redundancia**: datos en **una única AZ** → **riesgo de pérdida de datos** si esa AZ sufre un desastre.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos "nueves" de durabilidad ofrece One-Zone-IA? (un número)',
   '11', null, null,
   'One-Zone-IA tiene 11 nueves de durabilidad, igual que Standard y Standard-IA.'),
  ('multiple_choice',
   '¿Cuál es la disponibilidad de One-Zone-IA?',
   '99,5%',
   '99,99%',
   '99,999999999%',
   'Su disponibilidad es del 99,5%, más baja que la de Standard-IA por estar en una sola AZ.'),
  ('multiple_choice',
   '¿Por qué One-Zone-IA tiene menor disponibilidad que Standard-IA?',
   'Porque almacena los datos en una única AZ',
   'Porque tiene menos durabilidad',
   'Porque no admite recuperación rápida',
   'Vivir en una sola AZ reduce la disponibilidad frente a Standard-IA (3+ AZs).'),
  ('true_false',
   'En One-Zone-IA existe riesgo de pérdida de datos si la AZ sufre un desastre.',
   'Verdadero', null, null,
   'Al estar en una sola AZ, un desastre de esa zona puede provocar pérdida de datos.'),
  ('multiple_choice',
   '¿En cuántas AZs almacena los datos One-Zone-IA?',
   'En una única AZ',
   'En 3 o más AZs',
   'En exactamente 2 AZs',
   'One-Zone-IA usa una sola AZ, de ahí su nombre.')
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
-- LECCIÓN 2 — Coste y precios (slide 48)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '20% más barata que Standard-IA',
      E'**Almacenamiento rentable**: One-Zone-IA cuesta un **20% menos** que **Standard-IA**.\n\nEse ahorro adicional viene de almacenar en **una sola AZ** (con menor disponibilidad y riesgo de pérdida).'),
  (2, 'Modelo de precios',
      E'- **Almacenamiento por GB** (storage per GB).\n- **Por peticiones** (per requests).\n- **Tiene tarifa de recuperación** (retrieval fee).\n- **Tiene un cargo mínimo** por duración de almacenamiento de **30 días**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuánto más barata es One-Zone-IA respecto a Standard-IA?',
   'Un 20% menos',
   'Un 50% menos',
   'Un 5% menos',
   'One-Zone-IA cuesta un 20% menos que Standard-IA.'),
  ('multiple_choice',
   '¿De dónde proviene el ahorro adicional de One-Zone-IA?',
   'De almacenar los datos en una sola AZ (menor disponibilidad)',
   'De eliminar la tarifa de recuperación',
   'De aumentar la durabilidad a 12 nueves',
   'El ahorro viene de usar una única AZ, sacrificando disponibilidad.'),
  ('text_input',
   '¿Cuántos días dura el cargo mínimo de almacenamiento de One-Zone-IA? (un número)',
   '30', null, null,
   'One-Zone-IA tiene un cargo mínimo por duración de almacenamiento de 30 días.'),
  ('true_false',
   'One-Zone-IA tiene una tarifa de recuperación (retrieval fee).',
   'Verdadero', null, null,
   'Como las demás clases IA, cobra por recuperar los datos.'),
  ('anki_card',
   '¿Por qué conceptos factura One-Zone-IA?',
   'Almacenamiento por GB, por peticiones, tarifa de recuperación y mínimo de 30 días.',
   null, null,
   'Su modelo de precios es el típico de las clases IA.')
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
-- LECCIÓN 3 — Recuperación y casos de uso (slide 48)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Recuperación rápida',
      E'- **Tiempo de recuperación**: en **milisegundos** (baja latencia), como las demás clases IA.'),
  (2, '¿Cuándo usar One-Zone-IA?',
      E'Ideal para datos cuya pérdida es **asumible** porque se pueden recrear:\n- **Copias de seguridad secundarias** de datos **on-premises**.\n- Datos que se pueden **recrear** en caso de fallo de una AZ.\n- Datos de **acceso poco frecuente** que **no son críticos** (non mission-critical).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es el tiempo de recuperación de One-Zone-IA?',
   'Milisegundos (baja latencia)',
   'De minutos a horas',
   'Unas 12 horas',
   'One-Zone-IA recupera en milisegundos, como las demás clases IA.'),
  ('multiple_choice',
   '¿Cuál es un caso de uso ideal de One-Zone-IA?',
   'Copias de seguridad secundarias de datos on-premises',
   'La copia primaria de datos críticos imposibles de recrear',
   'Servir contenido de un sitio web de altísimo tráfico',
   'Encaja con backups secundarios o datos recreables, no con datos críticos únicos.'),
  ('true_false',
   'One-Zone-IA es adecuada para datos que se pueden recrear si falla una AZ.',
   'Verdadero', null, null,
   'Al haber riesgo de pérdida, conviene para datos recreables o copias secundarias.'),
  ('multiple_choice',
   '¿Por qué NO conviene guardar en One-Zone-IA la única copia de un dato crítico?',
   'Porque está en una sola AZ y podría perderse en un desastre',
   'Porque su recuperación tarda 12 horas',
   'Porque no admite acceso por milisegundos',
   'Una sola AZ implica riesgo de pérdida; un dato crítico necesita más redundancia.'),
  ('anki_card',
   'Menciona dos casos de uso de One-Zone-IA.',
   'Copias de seguridad secundarias de datos on-premises y datos recreables tras un fallo de AZ.',
   null, null,
   'Son datos de acceso poco frecuente y no críticos, asumibles de perder.')
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
-- LECCIÓN 4 — Repaso: One-Zone-IA (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: One-Zone-IA',
      'Repasamos **One-Zone-IA**: **11 nueves** de durabilidad, **99,5%** de disponibilidad, datos en **una sola AZ** (riesgo de pérdida), un **20% más barata** que Standard-IA, recuperación en **milisegundos**, su modelo de **precios** y sus **casos de uso** (backups secundarios, datos recreables). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: S3 Storage Classes - One-Zone-IA (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 15 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 One-Zone-IA**: la clase de **acceso poco frecuente** con **11 nueves** de durabilidad pero solo **99,5%** de disponibilidad por vivir en **una sola AZ** (con **riesgo de pérdida**), un **20% más barata** que Standard-IA, recuperación en **milisegundos**, un modelo de precios con **tarifa de recuperación** y **mínimo de 30 días**, e ideal para **backups secundarios** y datos **recreables**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_17_aws-saa-c03.sql
-- =============================================================================
