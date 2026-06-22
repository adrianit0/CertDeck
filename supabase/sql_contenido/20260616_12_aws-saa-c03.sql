-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 12
-- Archivo: supabase/sql_contenido/20260616_12_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el DÉCIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes" (position 10) — diapositiva 42 del Manual
--       L1 (normal)  Visión general · Standard · RRS    (slide 42)
--       L2 (normal)  Intelligent-Tiering · Express One Zone (slide 42)
--       L3 (normal)  Infrequent Access (Standard-IA · One-Zone-IA) (slide 42)
--       L4 (review)  Repaso: visión general y clases IA
--       L5 (normal)  Clases Glacier                     (slide 42)
--       L6 (normal)  Outposts y compensaciones          (slide 42)
--       L7 (review)  Repaso: Glacier y compensaciones
--       L8 (final)   Lección final: S3 Storage Classes
--   Volumen: MUCHO -> normal·normal·normal·review·normal·normal·review·final (8).
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
-- TEMA: S3 Storage Classes  (etapa "Básico" = position 1; tema position 10)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes',
       'Las clases de almacenamiento de S3: Standard, IA, Intelligent-Tiering, Express One Zone, Glacier y Outposts, y cómo intercambian tiempo de recuperación, accesibilidad y durabilidad por menor coste.',
       'AWS ofrece una gama de clases de almacenamiento de S3 que intercambian tiempo de recuperación, accesibilidad y durabilidad por un almacenamiento más barato. S3 Standard es la clase por defecto: rápida, disponible y duradera. S3 Reduced Redundancy Storage (RRS) es una clase heredada (legacy). S3 Intelligent-Tiering usa machine learning para analizar el uso de los objetos y determinar la clase de almacenamiento; cobra una tarifa extra por el análisis. S3 Express One Zone ofrece rendimiento de milisegundos de un solo dígito, es un tipo de bucket especial, almacena en una sola zona de disponibilidad (AZ) y cuesta un 50% menos que Standard. S3 Standard-IA (Infrequent Access) es rápida y más barata si accedes menos de una vez al mes; tiene una tarifa extra de recuperación, cuesta un 50% menos que Standard y reduce la disponibilidad. S3 One-Zone-IA es rápida pero los objetos solo existen en una AZ; es un 20% más barata que Standard-IA, reduce la durabilidad (los datos podrían destruirse) y tiene tarifa extra de recuperación. S3 Glacier Instant Retrieval es para almacenamiento en frío a largo plazo con recuperación instantánea. S3 Glacier Flexible Retrieval tarda de minutos a horas en recuperar los datos (opciones Standard, Expedited y Bulk). S3 Glacier Deep Archive es la clase de menor coste, con un tiempo de recuperación de 12 horas. Además, S3 Outposts tiene su propia clase de almacenamiento.',
       10,
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
-- LECCIONES (8) — volumen MUCHO
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Visión general · Standard · RRS',
      'El compromiso coste/recuperación, la clase por defecto y la clase heredada.', 'normal'),
  (2, 'Intelligent-Tiering y Express One Zone',
      'Clasificación automática con ML y la clase de máximo rendimiento.', 'normal'),
  (3, 'Clases Infrequent Access',
      'S3 Standard-IA y S3 One-Zone-IA: acceso poco frecuente.', 'normal'),
  (4, 'Repaso: visión general y clases IA',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Clases Glacier',
      'Glacier Instant Retrieval, Flexible Retrieval y Deep Archive.', 'normal'),
  (6, 'Outposts y compensaciones',
      'La clase de S3 Outposts y cómo se intercambia coste por recuperación/durabilidad.', 'normal'),
  (7, 'Repaso: Glacier y compensaciones',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (8, 'Lección final: S3 Storage Classes',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Visión general · Standard · RRS (slide 42)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'El compromiso de las clases',
      E'AWS ofrece una **gama de clases de almacenamiento** de S3 que **intercambian**:\n- **Tiempo de recuperación**\n- **Accesibilidad**\n- **Durabilidad**\n\n... a cambio de un **almacenamiento más barato**.'),
  (2, 'Standard y RRS',
      E'- **S3 Standard** (por defecto): **rápida**, **disponible** y **duradera**.\n- **S3 Reduced Redundancy Storage (RRS)**: clase **heredada** (legacy).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué intercambian las clases de almacenamiento de S3 a cambio de menor coste?',
   'Tiempo de recuperación, accesibilidad y durabilidad',
   'Cifrado, versionado y replicación',
   'Región, cuenta y partición',
   'Las clases sacrifican recuperación, accesibilidad y/o durabilidad para abaratar.'),
  ('multiple_choice',
   '¿Cuál es la clase de almacenamiento por defecto?',
   'S3 Standard',
   'S3 Glacier Deep Archive',
   'S3 One-Zone-IA',
   'S3 Standard es la clase por defecto: rápida, disponible y duradera.'),
  ('true_false',
   'S3 Reduced Redundancy Storage (RRS) es una clase heredada (legacy).',
   'Verdadero', null, null,
   'RRS es una clase legacy que ya no se recomienda.'),
  ('anki_card',
   '¿Cómo se describe S3 Standard en tres palabras?',
   'Rápida, disponible y duradera.',
   null, null,
   'S3 Standard equilibra velocidad, disponibilidad y durabilidad por defecto.'),
  ('multiple_choice',
   '¿Cuál de estas es una clase heredada de S3?',
   'S3 Reduced Redundancy Storage (RRS)',
   'S3 Intelligent-Tiering',
   'S3 Glacier Instant Retrieval',
   'RRS es la clase legacy; las otras son actuales.')
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
-- LECCIÓN 2 — Intelligent-Tiering y Express One Zone (slide 42)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'S3 Intelligent-Tiering',
      E'**S3 Intelligent-Tiering** usa **machine learning (ML)** para **analizar el uso** de los objetos y **determinar** automáticamente la clase de almacenamiento más adecuada.\n- Cobra una **tarifa extra** por el **análisis**.'),
  (2, 'S3 Express One Zone',
      E'**S3 Express One Zone**:\n- Rendimiento de **milisegundos de un solo dígito**.\n- Es un **tipo de bucket especial**.\n- Almacena en **una sola AZ** (zona de disponibilidad).\n- Cuesta un **50% menos** que Standard.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué hace S3 Intelligent-Tiering?',
   'Usa ML para analizar el uso y determinar la clase de almacenamiento',
   'Replica los objetos en todas las regiones',
   'Cifra los objetos con AES-256',
   'Intelligent-Tiering mueve los objetos a la clase óptima según su uso, con ML.'),
  ('true_false',
   'S3 Intelligent-Tiering cobra una tarifa extra por analizar los objetos.',
   'Verdadero', null, null,
   'El análisis automático tiene una tarifa adicional.'),
  ('multiple_choice',
   '¿Qué caracteriza a S3 Express One Zone?',
   'Rendimiento de milisegundos de un solo dígito en una sola AZ',
   'Recuperación en 12 horas',
   'Es la clase por defecto',
   'Express One Zone prioriza latencia muy baja en una única AZ.'),
  ('multiple_choice',
   '¿Cuánto más barata es S3 Express One Zone respecto a Standard?',
   'Un 50% menos',
   'Un 20% menos',
   'Un 90% menos',
   'Express One Zone cuesta un 50% menos que Standard.'),
  ('anki_card',
   '¿En cuántas zonas de disponibilidad almacena S3 Express One Zone?',
   'En una sola AZ.',
   null, null,
   'Express One Zone usa una única AZ, lo que reduce coste y latencia.')
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
-- LECCIÓN 3 — Clases Infrequent Access (slide 42)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'S3 Standard-IA',
      E'**S3 Standard-IA** (Infrequent Access, "acceso poco frecuente"):\n- **Rápida** y **más barata** si accedes **menos de una vez al mes**.\n- Tiene una **tarifa extra** de **recuperación**.\n- Cuesta un **50% menos** que Standard (con **disponibilidad reducida**).'),
  (2, 'S3 One-Zone-IA',
      E'**S3 One-Zone-IA**:\n- Rápida, pero los objetos **solo existen en una AZ**.\n- Un **20% más barata** que Standard-IA.\n- **Durabilidad reducida**: los datos **podrían destruirse**.\n- Tiene **tarifa extra** de recuperación.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuándo conviene S3 Standard-IA?',
   'Cuando accedes a los datos menos de una vez al mes',
   'Cuando accedes a los datos varias veces al día',
   'Cuando necesitas recuperación en 12 horas',
   'Standard-IA es ideal para acceso poco frecuente (menos de una vez al mes).'),
  ('multiple_choice',
   '¿Qué diferencia principal tiene S3 One-Zone-IA frente a Standard-IA?',
   'Los objetos solo existen en una AZ (durabilidad reducida)',
   'Tarda 12 horas en recuperar los datos',
   'Usa ML para clasificar objetos',
   'One-Zone-IA guarda en una sola AZ, con menor durabilidad y coste.'),
  ('multiple_choice',
   '¿Cuánto más barata es One-Zone-IA respecto a Standard-IA?',
   'Un 20% menos',
   'Un 50% menos',
   'Un 5% menos',
   'One-Zone-IA cuesta un 20% menos que Standard-IA.'),
  ('true_false',
   'Las clases IA cobran una tarifa extra por recuperar los datos.',
   'Verdadero', null, null,
   'Tanto Standard-IA como One-Zone-IA tienen tarifa extra de recuperación.'),
  ('true_false',
   'En S3 One-Zone-IA los datos podrían destruirse si falla esa AZ.',
   'Verdadero', null, null,
   'Al existir en una sola AZ, su durabilidad es menor y los datos podrían perderse.'),
  ('anki_card',
   '¿Qué significan las siglas IA en las clases de S3?',
   'Infrequent Access (acceso poco frecuente).',
   null, null,
   'Las clases IA están pensadas para datos de acceso poco frecuente.')
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
-- LECCIÓN 4 — Repaso: visión general y clases IA (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: visión general y clases IA',
      'Vamos a repasar el **compromiso** de las clases, **Standard**, **RRS**, **Intelligent-Tiering**, **Express One Zone** y las clases **Infrequent Access**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Clases Glacier (slide 42)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Las tres clases Glacier',
      E'Las clases **Glacier** son para almacenamiento **en frío**:\n- **S3 Glacier Instant Retrieval**: almacenamiento en frío a **largo plazo**, pero recuperas los datos **al instante**.\n- **S3 Glacier Flexible Retrieval**: tarda de **minutos a horas** (opciones **Standard**, **Expedited** y **Bulk**).\n- **S3 Glacier Deep Archive**: la clase de **menor coste**; tiempo de recuperación de **12 horas**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué clase Glacier permite recuperar los datos al instante?',
   'S3 Glacier Instant Retrieval',
   'S3 Glacier Flexible Retrieval',
   'S3 Glacier Deep Archive',
   'Glacier Instant Retrieval da acceso instantáneo a datos en frío.'),
  ('multiple_choice',
   '¿Cuál es la clase de almacenamiento de menor coste?',
   'S3 Glacier Deep Archive',
   'S3 Standard',
   'S3 Glacier Instant Retrieval',
   'Glacier Deep Archive es la más barata, con recuperación de 12 horas.'),
  ('text_input',
   '¿Cuántas horas tarda en recuperar datos S3 Glacier Deep Archive? (un número)',
   '12', null, null,
   'Deep Archive recupera los datos en unas 12 horas.'),
  ('multiple_choice',
   '¿Qué opciones de recuperación ofrece S3 Glacier Flexible Retrieval?',
   'Standard, Expedited y Bulk',
   'Instant, Cold y Frozen',
   'IPv4, IPv6 y Dualstack',
   'Flexible Retrieval ofrece Standard, Expedited y Bulk (de minutos a horas).'),
  ('true_false',
   'S3 Glacier Flexible Retrieval entrega los datos al instante.',
   'Falso', null, null,
   'Tarda de minutos a horas; la instantánea es Glacier Instant Retrieval.'),
  ('anki_card',
   'Ordena de más rápida a más lenta la recuperación de las tres clases Glacier.',
   'Instant Retrieval (instantáneo) > Flexible Retrieval (minutos-horas) > Deep Archive (12 horas).',
   null, null,
   'A menor coste, mayor tiempo de recuperación.')
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
-- LECCIÓN 6 — Outposts y compensaciones (slide 42)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'S3 Outposts',
      E'**S3 Outposts** tiene su **propia clase de almacenamiento**, pensada para almacenar datos en infraestructura de AWS **on-premises** (en tus instalaciones).'),
  (2, 'El compromiso general',
      E'Recuerda la idea común a todas las clases: a **menor coste**, normalmente **peor** alguno de estos factores:\n- **Tiempo de recuperación** (instantáneo → horas).\n- **Accesibilidad/disponibilidad** (p. ej. Standard-IA).\n- **Durabilidad** (p. ej. One-Zone-IA, una sola AZ).\n\nElige la clase según **cada cuánto** accedes a los datos y **cuánta** durabilidad necesitas.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 6
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'S3 Outposts tiene su propia clase de almacenamiento.',
   'Verdadero', null, null,
   'Outposts cuenta con una clase de almacenamiento propia.'),
  ('multiple_choice',
   'En general, ¿qué obtienes al elegir una clase de almacenamiento más barata?',
   'Peor tiempo de recuperación, accesibilidad o durabilidad',
   'Mayor durabilidad garantizada',
   'Recuperación siempre instantánea',
   'El menor coste implica sacrificar recuperación, accesibilidad o durabilidad.'),
  ('multiple_choice',
   '¿Qué factor debe guiar la elección de clase de almacenamiento?',
   'Con qué frecuencia accedes a los datos y la durabilidad que necesitas',
   'El color del bucket',
   'El número de objetos exacto',
   'La frecuencia de acceso y la durabilidad requerida determinan la clase óptima.'),
  ('multiple_choice',
   '¿Para qué escenario está pensada la clase de S3 Outposts?',
   'Almacenar datos en infraestructura de AWS on-premises',
   'Archivado a 12 horas de recuperación',
   'Clasificación automática con ML',
   'Outposts lleva almacenamiento de tipo S3 a tus instalaciones (on-premises).'),
  ('anki_card',
   '¿Qué tres factores se sacrifican por un almacenamiento más barato?',
   'Tiempo de recuperación, accesibilidad y durabilidad.',
   null, null,
   'Es el compromiso central de las clases de almacenamiento de S3.')
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
-- LECCIÓN 7 — Repaso: Glacier y compensaciones (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Glacier y compensaciones',
      'Repasamos las clases **Glacier**, la clase de **Outposts** y el **compromiso** entre coste, recuperación, accesibilidad y durabilidad. Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 8 — Lección final: S3 Storage Classes (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 10 and l.position = 8
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto las **clases de almacenamiento** de S3: Standard, RRS, Intelligent-Tiering, Express One Zone, las clases **IA**, las clases **Glacier** y **Outposts**, además del **compromiso** entre coste y recuperación/durabilidad. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_12_aws-saa-c03.sql
-- =============================================================================
