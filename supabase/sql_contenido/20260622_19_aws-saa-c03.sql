-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 19
-- Archivo: supabase/sql_contenido/20260622_19_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOSÉPTIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Glacier Instant Retrieval" (position 17) — diapositiva 50
--       L1 (normal)  Durabilidad, disponibilidad y coste   (slide 50)
--       L2 (normal)  Recuperación y casos de uso           (slide 50)
--       L3 (normal)  Precios                               (slide 50)
--       L4 (review)  Repaso: Glacier Instant Retrieval
--       L5 (final)   Lección final: Glacier Instant Retrieval
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
-- TEMA: S3 Storage Classes - Glacier Instant Retrieval  (position 17)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Glacier Instant Retrieval',
       'Almacenamiento de archivo para datos rara vez accedidos que aún necesitan acceso inmediato (milisegundos), a un coste mucho menor que Standard-IA.',
       'S3 Glacier Instant Retrieval es una clase de almacenamiento diseñada para datos rara vez accedidos que aún necesitan acceso inmediato en casos de uso sensibles al rendimiento. Ofrece una durabilidad alta de 11 nueves (igual que S3 Standard) y una disponibilidad de 3 nueves (99,9%, igual que S3 Standard-IA). Es un almacenamiento muy rentable: cuesta un 68% menos que Standard-IA, para datos de larga vida a los que se accede una vez por trimestre. El tiempo de recuperación es de milisegundos (baja latencia). Es ideal para datos a los que se accede rara vez pero que necesitan acceso inmediato, como alojamiento de imágenes (image hosting), aplicaciones de compartición de archivos online, imágenes médicas e historiales de salud, activos de medios de comunicación, y captura de imágenes por satélite y aérea. En cuanto a precios: cobra por almacenamiento por GB y por peticiones, tiene una tarifa de recuperación (retrieval fee) y un cargo mínimo por duración de almacenamiento de 90 días. No es un servicio separado y no requiere un Vault.',
       17,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Durabilidad, disponibilidad y coste',
      '11 nueves, 99,9% y un 68% más barata que Standard-IA.', 'normal'),
  (2, 'Recuperación y casos de uso',
      'Acceso inmediato en milisegundos para datos rara vez accedidos.', 'normal'),
  (3, 'Precios',
      'Almacenamiento, peticiones, tarifa de recuperación y mínimo de 90 días.', 'normal'),
  (4, 'Repaso: Glacier Instant Retrieval',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: Glacier Instant Retrieval',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Durabilidad, disponibilidad y coste (slide 50)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es Glacier Instant Retrieval?',
      E'**S3 Glacier Instant Retrieval** es una clase de **archivo** diseñada para datos **rara vez accedidos** que **aún necesitan acceso inmediato** en casos sensibles al rendimiento.\n\nNo es un servicio separado y **no requiere un Vault**.'),
  (2, 'Garantías y coste',
      E'- **Durabilidad**: **11 nueves**, igual que S3 Standard.\n- **Disponibilidad**: **3 nueves** (99,9%), igual que Standard-IA.\n- **Coste**: **68% menos** que Standard-IA, para datos de larga vida a los que se accede **una vez por trimestre**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos "nueves" de durabilidad ofrece Glacier Instant Retrieval? (un número)',
   '11', null, null,
   'Tiene 11 nueves de durabilidad, igual que S3 Standard.'),
  ('multiple_choice',
   '¿Cuál es la disponibilidad de Glacier Instant Retrieval?',
   '3 nueves (99,9%)',
   '4 nueves (99,99%)',
   '99,5%',
   'Su disponibilidad es de 99,9%, igual que Standard-IA.'),
  ('multiple_choice',
   '¿Cuánto más barata es Glacier Instant Retrieval respecto a Standard-IA?',
   'Un 68% menos',
   'Un 20% menos',
   'Un 50% menos',
   'Cuesta un 68% menos que Standard-IA.'),
  ('multiple_choice',
   '¿Con qué frecuencia de acceso está pensada Glacier Instant Retrieval?',
   'Datos de larga vida accedidos una vez por trimestre',
   'Datos accedidos varias veces al día',
   'Datos accedidos una vez al minuto',
   'Está pensada para datos accedidos aproximadamente una vez por trimestre.'),
  ('true_false',
   'Glacier Instant Retrieval es un servicio separado que requiere un Vault.',
   'Falso', null, null,
   'No es un servicio separado ni requiere Vault: es una storage class dentro de S3.')
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
-- LECCIÓN 2 — Recuperación y casos de uso (slide 50)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Acceso inmediato',
      E'- **Tiempo de recuperación**: en **milisegundos** (baja latencia).\n\nEs lo que distingue a esta clase de las demás Glacier: archivo barato **pero** con acceso **instantáneo**.'),
  (2, 'Casos de uso',
      E'Datos a los que se accede **rara vez** pero que necesitan **acceso inmediato**:\n- **Image hosting** (alojamiento de imágenes).\n- Aplicaciones de **compartición de archivos** online.\n- **Imágenes médicas** e historiales de salud.\n- **Activos de medios** de comunicación (news media).\n- Imágenes por **satélite** y aéreas.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es el tiempo de recuperación de Glacier Instant Retrieval?',
   'Milisegundos (baja latencia)',
   'De 1 a 5 minutos',
   'Unas 12 horas',
   'Recupera en milisegundos, de ahí el "Instant" de su nombre.'),
  ('multiple_choice',
   '¿Qué distingue a Glacier Instant Retrieval del resto de clases Glacier?',
   'Es archivo barato pero con acceso inmediato',
   'Es la más cara de todas',
   'Almacena en una sola AZ',
   'Combina coste de archivo con recuperación instantánea en milisegundos.'),
  ('multiple_choice',
   '¿Cuál de estos es un caso de uso típico de Glacier Instant Retrieval?',
   'Imágenes médicas e historiales de salud accedidos rara vez',
   'Una base de datos transaccional de alta frecuencia',
   'Datos temporales que se borran cada hora',
   'Encaja con datos rara vez accedidos que requieren acceso inmediato (p. ej. imágenes médicas).'),
  ('true_false',
   'Glacier Instant Retrieval sirve para datos accedidos rara vez que necesitan acceso inmediato.',
   'Verdadero', null, null,
   'Es su definición: rarely accessed data con immediate access.'),
  ('anki_card',
   'Menciona tres casos de uso de Glacier Instant Retrieval.',
   'Image hosting, imágenes médicas/historiales de salud e imágenes por satélite o aéreas.',
   null, null,
   'Datos rara vez accedidos pero que requieren acceso inmediato.')
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
-- LECCIÓN 3 — Precios (slide 50)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Cómo factura',
      E'El **modelo de precios** de Glacier Instant Retrieval:\n- **Almacenamiento por GB** (storage per GB).\n- **Por peticiones** (per requests).\n- **Tiene tarifa de recuperación** (retrieval fee).\n- **Tiene un cargo mínimo** por duración de almacenamiento de **90 días**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos días dura el cargo mínimo de almacenamiento de Glacier Instant Retrieval? (un número)',
   '90', null, null,
   'Tiene un cargo mínimo por duración de almacenamiento de 90 días.'),
  ('true_false',
   'Glacier Instant Retrieval tiene una tarifa de recuperación (retrieval fee).',
   'Verdadero', null, null,
   'Como clase de archivo, cobra por recuperar los datos.'),
  ('multiple_choice',
   '¿Por qué dos conceptos principales factura Glacier Instant Retrieval además de las tarifas extra?',
   'Almacenamiento por GB y por peticiones',
   'Por número de buckets y de cuentas',
   'Por color del bucket y nombre del objeto',
   'Cobra por GB almacenado y por peticiones, más recuperación y mínimo de 90 días.'),
  ('multiple_choice',
   '¿En qué se diferencia su mínimo de duración respecto a las clases IA (30 días)?',
   'Glacier Instant Retrieval exige 90 días en vez de 30',
   'No tiene ningún mínimo de duración',
   'Exige 180 días',
   'Su mínimo de duración es de 90 días, frente a los 30 de las clases IA.'),
  ('anki_card',
   'Resume el modelo de precios de Glacier Instant Retrieval.',
   'Por GB, por peticiones, con tarifa de recuperación y mínimo de 90 días.',
   null, null,
   'Es el modelo típico de archivo, con mínimo de 90 días.')
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Glacier Instant Retrieval',
      'Repasamos **Glacier Instant Retrieval**: **11 nueves** de durabilidad, **99,9%** de disponibilidad, **68%** más barata que Standard-IA (acceso una vez por trimestre), recuperación en **milisegundos**, sus **casos de uso** y un modelo de **precios** con tarifa de recuperación y mínimo de **90 días**. Estas tarjetas se toman de las lecciones anteriores.')
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 17 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Glacier Instant Retrieval**: archivo barato (**68%** menos que Standard-IA) con **acceso inmediato** en **milisegundos**, **11 nueves** de durabilidad y **99,9%** de disponibilidad, ideal para datos rara vez accedidos como imágenes médicas o por satélite, con **tarifa de recuperación** y mínimo de **90 días**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_19_aws-saa-c03.sql
-- =============================================================================
