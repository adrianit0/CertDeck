-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 16
-- Archivo: supabase/sql_contenido/20260622_16_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOCUARTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Express One Zone" (position 14) — diapositiva 47
--       L1 (normal)  Rendimiento y latencia            (slide 47)
--       L2 (normal)  Coste y peticiones                (slide 47)
--       L3 (normal)  Single AZ y Directory bucket      (slide 47)
--       L4 (review)  Repaso: Express One Zone
--       L5 (final)   Lección final: S3 Storage Classes - Express One Zone
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
-- TEMA: S3 Storage Classes - Express One Zone  (etapa "Básico" = position 1; tema position 14)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Express One Zone',
       'S3 Express One Zone: la clase de menor latencia, hasta 10x más rápida que Standard, en una sola AZ y un nuevo tipo de bucket (Directory bucket).',
       'Amazon S3 Express One Zone ofrece un acceso a datos con latencia consistente de milisegundos de un solo dígito para tus datos de acceso más frecuente y aplicaciones sensibles a la latencia. Es la clase de almacenamiento de objetos en la nube de menor latencia disponible, con velocidades de acceso a datos hasta 10 veces más rápidas que S3 Standard y costes de petición un 50% más bajos que S3 Standard. Express One Zone aplica un cargo plano por petición para tamaños de petición de hasta 512 KB. Los datos se almacenan en una única zona de disponibilidad (AZ) seleccionada por el usuario y en un nuevo tipo de bucket: el Amazon S3 Directory bucket. El S3 Directory bucket soporta una estructura simple de carpetas reales y, por defecto, solo se permiten 10 Directory buckets por cuenta.',
       14,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Rendimiento y latencia',
      'Milisegundos de un solo dígito y hasta 10x más rápida que Standard.', 'normal'),
  (2, 'Coste y peticiones',
      'Costes un 50% menores y el cargo plano por petición hasta 512 KB.', 'normal'),
  (3, 'Single AZ y Directory bucket',
      'Una sola AZ elegida por el usuario y el nuevo tipo de bucket.', 'normal'),
  (4, 'Repaso: Express One Zone',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Storage Classes - Express One Zone',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Rendimiento y latencia (slide 47)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'La clase de menor latencia',
      E'**Amazon S3 Express One Zone** ofrece acceso a datos con latencia **consistente** de **milisegundos de un solo dígito** (single-digit millisecond).\n\nEstá pensada para tus datos de **acceso más frecuente** y **aplicaciones sensibles a la latencia**.'),
  (2, 'Hasta 10x más rápida',
      E'- Es la clase de almacenamiento de objetos en la nube de **menor latencia** disponible.\n- Velocidades de acceso a datos **hasta 10 veces más rápidas** que S3 Standard.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué latencia de acceso ofrece S3 Express One Zone?',
   'Milisegundos de un solo dígito (single-digit millisecond)',
   'De minutos a horas',
   'Unas 12 horas',
   'Express One Zone da acceso con latencia de milisegundos de un solo dígito.'),
  ('multiple_choice',
   '¿Cuánto más rápida es Express One Zone que S3 Standard?',
   'Hasta 10 veces más rápida',
   'Hasta 2 veces más rápida',
   'Exactamente igual de rápida',
   'Sus velocidades de acceso llegan a ser hasta 10x las de Standard.'),
  ('true_false',
   'Express One Zone es la clase de almacenamiento de objetos en la nube de menor latencia disponible.',
   'Verdadero', null, null,
   'Es la clase de menor latencia que ofrece S3.'),
  ('multiple_choice',
   '¿Para qué tipo de aplicaciones está pensada Express One Zone?',
   'Datos de acceso muy frecuente y aplicaciones sensibles a la latencia',
   'Archivado en frío a largo plazo',
   'Copias de seguridad a las que casi nunca se accede',
   'Su baja latencia encaja con acceso frecuente y apps sensibles a la latencia.'),
  ('text_input',
   'Express One Zone es hasta ___ veces más rápida que S3 Standard. (un número)',
   '10', null, null,
   'Hasta 10 veces más rápida que S3 Standard.')
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
-- LECCIÓN 2 — Coste y peticiones (slide 47)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Costes de petición más bajos',
      E'- Los **costes de petición** son un **50% más bajos** que en S3 Standard.\n- Aplica un **cargo plano por petición** (flat per request charge) para tamaños de petición de **hasta 512 KB**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuánto más bajos son los costes de petición de Express One Zone frente a Standard?',
   'Un 50% más bajos',
   'Un 20% más bajos',
   'Un 90% más bajos',
   'Los costes de petición son un 50% menores que en S3 Standard.'),
  ('text_input',
   '¿Hasta qué tamaño de petición (en KB) aplica Express One Zone el cargo plano por petición? (un número)',
   '512', null, null,
   'El cargo plano por petición aplica a tamaños de hasta 512 KB.'),
  ('true_false',
   'Express One Zone aplica un cargo plano por petición para tamaños de hasta 512 KB.',
   'Verdadero', null, null,
   'Hay un flat per request charge para peticiones de hasta 512 KB.'),
  ('multiple_choice',
   '¿Qué tipo de cargo aplica Express One Zone a las peticiones?',
   'Un cargo plano (flat) por petición hasta 512 KB',
   'Una tarifa de recuperación de 12 horas',
   'Un cargo mínimo de 30 días de almacenamiento',
   'Es un cargo plano por petición, no una retrieval fee ni un mínimo de duración.'),
  ('anki_card',
   'Resume el coste de peticiones de Express One Zone.',
   '50% más bajo que Standard, con un cargo plano por petición hasta 512 KB.',
   null, null,
   'Combina menor coste de petición con un cargo plano por debajo de 512 KB.')
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
-- LECCIÓN 3 — Single AZ y Directory bucket (slide 47)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Una sola AZ elegida por el usuario',
      E'Los datos se almacenan en una **única zona de disponibilidad (AZ)** **seleccionada por el usuario**.\n\nEsto es lo que reduce la latencia y el coste, a cambio de vivir en una sola AZ.'),
  (2, 'El nuevo Directory bucket',
      E'Los datos se guardan en un **nuevo tipo de bucket**: el **Amazon S3 Directory bucket**.\n- Soporta una **estructura simple de carpetas reales** (real-folder structure).\n- Por defecto, solo se permiten **10 Directory buckets por cuenta**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Dónde se almacenan los datos en Express One Zone?',
   'En una única AZ seleccionada por el usuario',
   'En 3 o más AZs',
   'En todas las regiones a la vez',
   'Express One Zone usa una sola AZ elegida por el usuario.'),
  ('multiple_choice',
   '¿En qué nuevo tipo de bucket guarda los datos Express One Zone?',
   'Amazon S3 Directory bucket',
   'Amazon S3 General Purpose bucket',
   'Amazon S3 Glacier vault',
   'Express One Zone introduce el Directory bucket.'),
  ('text_input',
   '¿Cuántos Directory buckets por cuenta se permiten por defecto? (un número)',
   '10', null, null,
   'Por defecto se permiten 10 Directory buckets por cuenta.'),
  ('true_false',
   'El S3 Directory bucket soporta una estructura simple de carpetas reales.',
   'Verdadero', null, null,
   'El Directory bucket admite una real-folder structure simple.'),
  ('multiple_choice',
   '¿Qué compromiso asume Express One Zone al usar una sola AZ?',
   'Gana latencia y coste, pero los datos viven en una única AZ',
   'Gana durabilidad multi-región',
   'Elimina cualquier cargo por petición',
   'La única AZ es lo que reduce latencia y coste, con el riesgo de una sola zona.')
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
-- LECCIÓN 4 — Repaso: Express One Zone (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Express One Zone',
      'Repasamos **Express One Zone**: la clase de **menor latencia** (milisegundos de un solo dígito, **10x** más rápida que Standard), con **costes de petición un 50% menores** y **cargo plano** hasta **512 KB**, almacenamiento en **una sola AZ** y el nuevo **Directory bucket** (máx. **10** por cuenta). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: S3 Storage Classes - Express One Zone (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 14 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Express One Zone**: la clase de **menor latencia** (milisegundos de un solo dígito, hasta **10x** más rápida que Standard), con **costes de petición un 50% más bajos** y un **cargo plano** por petición hasta **512 KB**, datos en **una única AZ** elegida por el usuario y el nuevo **Amazon S3 Directory bucket** (carpetas reales, **10** por cuenta por defecto). Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_16_aws-saa-c03.sql
-- =============================================================================
