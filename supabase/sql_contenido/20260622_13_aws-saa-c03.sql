-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 13
-- Archivo: supabase/sql_contenido/20260622_13_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el UNDÉCIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Standard" (position 11) — diapositivas 43-44
--       L1 (normal)  Visión general de S3 Standard            (slide 44)
--       L2 (normal)  Rendimiento, escalabilidad y casos de uso (slide 44)
--       L3 (review)  Repaso: S3 Standard
--       L4 (normal)  Dimensiones de precios de S3             (slide 43)
--       L5 (normal)  Precios de S3 Standard                   (slide 44)
--       L6 (review)  Repaso: precios
--       L7 (final)   Lección final: S3 Storage Classes - Standard
--   Volumen: MEDIO -> normal·normal·review·normal·normal·review·final (7).
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
-- TEMA: S3 Storage Classes - Standard  (etapa "Básico" = position 1; tema position 11)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Standard',
       'La clase de almacenamiento por defecto de S3: cómo está diseñada para datos de acceso frecuente, su durabilidad, disponibilidad, rendimiento y modelo de precios.',
       'S3 Standard es la clase de almacenamiento por defecto cuando subes un objeto a S3. Está diseñada para almacenamiento de propósito general de datos de acceso frecuente. Ofrece una durabilidad de 11 nueves (99,999999999%) y una disponibilidad de 4 nueves (99,99%). Los datos se almacenan de forma redundante en 3 o más zonas de disponibilidad (AZs). El tiempo de recuperación es de milisegundos (baja latencia) y está optimizada para alto rendimiento (high throughput) con datos accedidos con frecuencia o que requieren acceso en tiempo real. Escala con facilidad tanto en tamaño como en número de peticiones. Es ideal para casos de uso como distribución de contenido, big data analytics y aplicaciones móviles y de gaming, donde se requiere acceso frecuente. En cuanto a precios, S3 Standard cobra por almacenamiento por GB y por peticiones (per requests), no tiene tarifa de recuperación (no retrieval fee) y no impone un cargo mínimo por duración de almacenamiento. A nivel general, los precios de S3 dependen de varias dimensiones: la transferencia de datos de entrada (Data Transfer In) suele ser gratuita, la transferencia de datos de salida (Data Transfer Out) se cobra, el almacenamiento por GB y las tarifas de recuperación (Retrieval Fees).',
       11,
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
-- LECCIONES (7) — volumen MEDIO
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Visión general de S3 Standard',
      'La clase por defecto: acceso frecuente, durabilidad, disponibilidad y redundancia.', 'normal'),
  (2, 'Rendimiento, escalabilidad y casos de uso',
      'Tiempo de recuperación, throughput, escalabilidad y para qué se usa.', 'normal'),
  (3, 'Repaso: S3 Standard',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Dimensiones de precios de S3',
      'Data Transfer In/Out, almacenamiento por GB y tarifas de recuperación.', 'normal'),
  (5, 'Precios de S3 Standard',
      'Cómo factura S3 Standard: almacenamiento, peticiones y sin tarifas extra.', 'normal'),
  (6, 'Repaso: precios',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: S3 Storage Classes - Standard',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Visión general de S3 Standard (slide 44)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'La clase por defecto',
      E'**S3 Standard** es la clase de almacenamiento **por defecto** cuando subes un objeto a S3.\n\nEstá diseñada para **almacenamiento de propósito general** de datos de **acceso frecuente** (frequently accessed data).'),
  (2, 'Durabilidad, disponibilidad y redundancia',
      E'- **Durabilidad alta**: **11 nueves** (99,999999999%).\n- **Disponibilidad alta**: **4 nueves** (99,99%).\n- **Redundancia de datos**: los datos se almacenan en **3 o más zonas de disponibilidad (AZs)**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es la clase de almacenamiento por defecto al subir un objeto a S3?',
   'S3 Standard',
   'S3 Glacier Deep Archive',
   'S3 One-Zone-IA',
   'S3 Standard es la clase que se aplica por defecto cuando subes a S3.'),
  ('multiple_choice',
   '¿Para qué tipo de datos está diseñada S3 Standard?',
   'Datos de propósito general de acceso frecuente',
   'Datos de archivo a los que casi nunca se accede',
   'Datos temporales que se borran cada hora',
   'Standard es para almacenamiento de propósito general de datos accedidos con frecuencia.'),
  ('text_input',
   '¿Cuántos "nueves" de durabilidad ofrece S3 Standard? (un número)',
   '11', null, null,
   'S3 Standard ofrece 11 nueves de durabilidad (99,999999999%).'),
  ('multiple_choice',
   '¿Cuál es la disponibilidad de S3 Standard?',
   '4 nueves (99,99%)',
   '11 nueves (99,999999999%)',
   '2 nueves (99%)',
   'La disponibilidad de Standard es de 4 nueves (99,99%); la durabilidad es de 11 nueves.'),
  ('true_false',
   'En S3 Standard los datos se almacenan en 3 o más zonas de disponibilidad (AZs).',
   'Verdadero', null, null,
   'Standard replica los datos en 3 o más AZs para mayor durabilidad.'),
  ('anki_card',
   'Resume durabilidad, disponibilidad y redundancia de S3 Standard.',
   'Durabilidad 11 nueves (99,999999999%), disponibilidad 4 nueves (99,99%) y datos en 3 o más AZs.',
   null, null,
   'Son las tres garantías clave de la clase Standard.')
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
-- LECCIÓN 2 — Rendimiento, escalabilidad y casos de uso (slide 44)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Rendimiento y escalabilidad',
      E'- **Tiempo de recuperación**: en **milisegundos** (baja latencia).\n- **Alto rendimiento (high throughput)**: optimizada para datos de **acceso frecuente** o que requieren **acceso en tiempo real**.\n- **Escalabilidad**: escala con facilidad tanto en **tamaño de almacenamiento** como en **número de peticiones**.'),
  (2, 'Casos de uso',
      E'S3 Standard es **ideal** para una amplia gama de casos de uso donde se requiere **acceso frecuente**:\n- **Distribución de contenido** (content distribution).\n- **Big data analytics**.\n- Aplicaciones **móviles** y de **gaming**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es el tiempo de recuperación típico de S3 Standard?',
   'Milisegundos (baja latencia)',
   'De minutos a horas',
   'Unas 12 horas',
   'Standard recupera los datos en milisegundos, con baja latencia.'),
  ('true_false',
   'S3 Standard está optimizada para datos de acceso frecuente o en tiempo real.',
   'Verdadero', null, null,
   'Su alto rendimiento (high throughput) la hace ideal para acceso frecuente o en tiempo real.'),
  ('multiple_choice',
   '¿En qué dos dimensiones escala con facilidad S3 Standard?',
   'En tamaño de almacenamiento y en número de peticiones',
   'En número de regiones y de cuentas',
   'En color del bucket y nombre del objeto',
   'Standard escala tanto en capacidad como en número de peticiones.'),
  ('multiple_choice',
   '¿Cuál de estos es un caso de uso típico de S3 Standard?',
   'Distribución de contenido y big data analytics',
   'Archivado en frío a 12 horas de recuperación',
   'Almacenar datos que casi nunca se leen para ahorrar al máximo',
   'Standard sirve para acceso frecuente: content distribution, big data, móviles y gaming.'),
  ('anki_card',
   '¿Qué significa que S3 Standard ofrece "high throughput"?',
   'Está optimizada para datos accedidos con frecuencia o que requieren acceso en tiempo real.',
   null, null,
   'El alto rendimiento permite servir datos frecuentes con baja latencia.')
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
-- LECCIÓN 3 — Repaso: S3 Standard (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: S3 Standard',
      'Vamos a repasar qué es **S3 Standard**: la clase **por defecto** para datos de **acceso frecuente**, su **durabilidad** (11 nueves), **disponibilidad** (4 nueves), **redundancia** (3+ AZs), su **rendimiento** y sus **casos de uso**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Dimensiones de precios de S3 (slide 43)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Por qué cosas cobra S3?',
      E'El **precio** de S3 depende de varias **dimensiones**:\n- **Data Transfer In** (transferencia de **entrada**): subir datos a S3 suele ser **gratis**.\n- **Data Transfer Out** (transferencia de **salida**): sacar datos de S3 **se cobra**.\n- **Almacenamiento por GB** (storage per GB): pagas por los datos guardados.\n- **Tarifas de recuperación** (retrieval fees): según la clase, pagas por **recuperar** los datos.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'En S3, ¿qué transferencia de datos suele ser gratuita?',
   'Data Transfer In (entrada / subir datos a S3)',
   'Data Transfer Out (salida / sacar datos de S3)',
   'Las tarifas de recuperación',
   'Subir datos a S3 (Data Transfer In) suele ser gratis; sacarlos (Out) se cobra.'),
  ('true_false',
   'En S3 se cobra por la transferencia de datos de salida (Data Transfer Out).',
   'Verdadero', null, null,
   'El Data Transfer Out (sacar datos de S3) tiene coste.'),
  ('multiple_choice',
   '¿Cuál de estas NO es una dimensión típica de precios de S3?',
   'El número de carpetas dentro del bucket',
   'El almacenamiento por GB',
   'Las tarifas de recuperación',
   'S3 factura por almacenamiento, transferencia y recuperación, no por "carpetas".'),
  ('anki_card',
   'Enumera las dimensiones de precios de S3.',
   'Data Transfer In, Data Transfer Out, almacenamiento por GB y tarifas de recuperación.',
   null, null,
   'Son los factores que determinan cuánto pagas por usar S3.'),
  ('multiple_choice',
   '¿Qué concepto cubre la "tarifa de recuperación" (retrieval fee)?',
   'El coste de recuperar los datos almacenados, según la clase',
   'El coste de subir datos a S3',
   'El coste de crear un bucket',
   'Algunas clases cobran por recuperar (leer) los datos guardados.')
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
-- LECCIÓN 5 — Precios de S3 Standard (slide 44)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Cómo factura S3 Standard',
      E'El **modelo de precios** de S3 Standard:\n- **Almacenamiento por GB** (storage per GB).\n- **Por peticiones** (per requests).\n- **Sin tarifa de recuperación** (no retrieval fee).\n- **Sin cargo mínimo** por duración de almacenamiento (no minimum storage duration charge).'),
  (2, 'Lo que distingue a Standard',
      E'A diferencia de las clases más baratas (como las IA o Glacier), S3 Standard **no penaliza el acceso**:\n- **No** tiene **tarifa de recuperación**.\n- **No** exige una **duración mínima** de almacenamiento.\n\nPor eso encaja con datos de **acceso frecuente**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'S3 Standard NO cobra tarifa de recuperación (no retrieval fee).',
   'Verdadero', null, null,
   'Standard no penaliza la recuperación de datos, a diferencia de las clases IA o Glacier.'),
  ('true_false',
   'S3 Standard impone un cargo mínimo por duración de almacenamiento.',
   'Falso', null, null,
   'Standard NO exige duración mínima; otras clases más baratas sí.'),
  ('multiple_choice',
   '¿Por qué dos conceptos principales factura S3 Standard?',
   'Almacenamiento por GB y por peticiones (per requests)',
   'Por número de buckets y por región',
   'Por tarifa de recuperación y duración mínima',
   'Standard cobra por GB almacenado y por peticiones, sin tarifas de recuperación.'),
  ('multiple_choice',
   '¿Qué característica de precios hace a S3 Standard adecuada para acceso frecuente?',
   'No tiene tarifa de recuperación ni duración mínima',
   'Cobra por recuperar cada objeto',
   'Exige guardar los datos un mínimo de 90 días',
   'Al no penalizar el acceso, encaja con datos que se leen a menudo.'),
  ('anki_card',
   '¿Qué dos "ausencias" de coste caracterizan a S3 Standard?',
   'No tiene tarifa de recuperación ni cargo mínimo por duración de almacenamiento.',
   null, null,
   'Standard no penaliza ni recuperar ni almacenar poco tiempo.')
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
-- LECCIÓN 6 — Repaso: precios (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: precios',
      'Repasamos las **dimensiones de precios** de S3 (Data Transfer In/Out, almacenamiento por GB y tarifas de recuperación) y el **modelo de precios de S3 Standard** (por GB, por peticiones, sin tarifa de recuperación ni duración mínima). Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final: S3 Storage Classes - Standard (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 11 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Standard**: la clase **por defecto** para datos de **acceso frecuente**, con **11 nueves** de durabilidad, **4 nueves** de disponibilidad y datos en **3+ AZs**, su **rendimiento** en milisegundos y sus **casos de uso**, además de las **dimensiones de precios** de S3 y el **modelo de precios** propio de Standard. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_13_aws-saa-c03.sql
-- =============================================================================
