-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 15
-- Archivo: supabase/sql_contenido/20260622_15_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOTERCER TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Standard-IA" (position 13) — diapositiva 46
--       L1 (normal)  Durabilidad, disponibilidad y redundancia  (slide 46)
--       L2 (normal)  Coste, recuperación y rendimiento          (slide 46)
--       L3 (review)  Repaso: características de Standard-IA
--       L4 (normal)  Casos de uso                               (slide 46)
--       L5 (normal)  Precios de Standard-IA                     (slide 46)
--       L6 (review)  Repaso: usos y precios
--       L7 (final)   Lección final: S3 Storage Classes - Standard-IA
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
-- TEMA: S3 Storage Classes - Standard-IA  (etapa "Básico" = position 1; tema position 13)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Standard-IA',
       'S3 Standard-IA (Infrequent Access): para datos de acceso poco frecuente que necesitan acceso rápido cuando se solicitan, a menor coste que Standard.',
       'La clase S3 Standard-IA (Infrequent Access) está diseñada para datos a los que se accede con poca frecuencia pero que requieren acceso rápido cuando se necesitan. Ofrece una durabilidad alta de 11 nueves (igual que S3 Standard) y una disponibilidad de 3 nueves (99,9%), algo menor que Standard. Los datos se almacenan de forma redundante en 3 o más zonas de disponibilidad (AZs). Es un almacenamiento rentable: cuesta un 50% menos que Standard, siempre que no accedas a un archivo más de una vez al mes. El tiempo de recuperación es de milisegundos (baja latencia) y está optimizada para acceso rápido, aunque a datos accedidos con menos frecuencia que en Standard. Escala con facilidad en tamaño y número de peticiones, igual que Standard. Es ideal para datos a los que se accede con poca frecuencia pero que requieren acceso rápido cuando se necesitan, como recuperación ante desastres (disaster recovery), copias de seguridad (backups) o almacenes de datos a largo plazo. En cuanto a precios: cobra por almacenamiento por GB y por peticiones, tiene una tarifa de recuperación (retrieval fee) y un cargo mínimo por duración de almacenamiento de 30 días.',
       13,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Durabilidad, disponibilidad y redundancia',
      'Las garantías de Standard-IA frente a S3 Standard.', 'normal'),
  (2, 'Coste, recuperación y rendimiento',
      'El ahorro del 50%, la latencia y el rendimiento de la clase.', 'normal'),
  (3, 'Repaso: características de Standard-IA',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Casos de uso',
      'Disaster recovery, backups y almacenes a largo plazo.', 'normal'),
  (5, 'Precios de Standard-IA',
      'Almacenamiento, peticiones, tarifa de recuperación y duración mínima.', 'normal'),
  (6, 'Repaso: usos y precios',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: S3 Storage Classes - Standard-IA',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Durabilidad, disponibilidad y redundancia (slide 46)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es Standard-IA?',
      E'**S3 Standard-IA** (Infrequent Access, "acceso poco frecuente") está diseñada para datos a los que se accede con **poca frecuencia** pero que requieren **acceso rápido** cuando se necesitan.'),
  (2, 'Durabilidad, disponibilidad y redundancia',
      E'- **Durabilidad alta**: **11 nueves**, **igual** que S3 Standard.\n- **Disponibilidad**: **3 nueves** (99,9%), **algo menor** que Standard.\n- **Redundancia**: datos en **3 o más AZs** (zonas de disponibilidad).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Para qué datos está diseñada S3 Standard-IA?',
   'Datos de acceso poco frecuente que requieren acceso rápido cuando se necesitan',
   'Datos de acceso constante en tiempo real',
   'Datos de archivo con recuperación de 12 horas',
   'Standard-IA es para acceso poco frecuente pero rápido cuando se solicita.'),
  ('text_input',
   '¿Cuántos "nueves" de durabilidad ofrece Standard-IA? (un número)',
   '11', null, null,
   'Standard-IA tiene 11 nueves de durabilidad, igual que S3 Standard.'),
  ('multiple_choice',
   '¿Cuál es la disponibilidad de Standard-IA?',
   '3 nueves (99,9%)',
   '4 nueves (99,99%)',
   '11 nueves (99,999999999%)',
   'Standard-IA ofrece 3 nueves (99,9%), algo menos que Standard.'),
  ('true_false',
   'Standard-IA tiene la misma durabilidad que S3 Standard pero menor disponibilidad.',
   'Verdadero', null, null,
   'Misma durabilidad (11 nueves), pero disponibilidad de 3 nueves frente a 4.'),
  ('multiple_choice',
   '¿En cuántas AZs almacena los datos Standard-IA?',
   'En 3 o más AZs',
   'En una sola AZ',
   'En exactamente 2 AZs',
   'Standard-IA replica en 3 o más AZs, como Standard.')
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
-- LECCIÓN 2 — Coste, recuperación y rendimiento (slide 46)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Coste: 50% menos (con condición)',
      E'**Almacenamiento rentable**: Standard-IA cuesta un **50% menos** que Standard...\n\n**...siempre que NO accedas a un archivo más de una vez al mes.** Si accedes más a menudo, las tarifas de recuperación encarecen el uso.'),
  (2, 'Recuperación, rendimiento y escalabilidad',
      E'- **Tiempo de recuperación**: en **milisegundos** (baja latencia).\n- **Alto rendimiento (high throughput)**: optimizada para **acceso rápido**, aunque a datos accedidos **con menos frecuencia** que en Standard.\n- **Escalabilidad**: escala con facilidad en **tamaño** y **número de peticiones**, igual que Standard.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuánto más barata es Standard-IA respecto a Standard?',
   'Un 50% menos',
   'Un 20% menos',
   'Un 90% menos',
   'Standard-IA cuesta un 50% menos que Standard.'),
  ('true_false',
   'El ahorro de Standard-IA solo compensa si NO accedes a un archivo más de una vez al mes.',
   'Verdadero', null, null,
   'El 50% de ahorro asume acceso de menos de una vez al mes; acceder más encarece.'),
  ('multiple_choice',
   '¿Cuál es el tiempo de recuperación de Standard-IA?',
   'Milisegundos (baja latencia)',
   'De minutos a horas',
   'Unas 12 horas',
   'Standard-IA recupera en milisegundos, como Standard.'),
  ('multiple_choice',
   '¿En qué se diferencia el rendimiento de Standard-IA respecto a Standard?',
   'Está optimizada para acceso rápido pero a datos accedidos con menos frecuencia',
   'Recupera los datos en horas en vez de milisegundos',
   'No escala en número de peticiones',
   'Mantiene acceso rápido, pero asume acceso menos frecuente que Standard.'),
  ('anki_card',
   '¿Cuál es la condición para que Standard-IA salga rentable?',
   'No acceder a un archivo más de una vez al mes.',
   null, null,
   'El acceso poco frecuente es lo que hace que compense su menor coste.')
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
-- LECCIÓN 3 — Repaso: características de Standard-IA (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: características de Standard-IA',
      'Repasamos las garantías de **Standard-IA**: **11 nueves** de durabilidad, **3 nueves** de disponibilidad, datos en **3+ AZs**, el ahorro del **50%** (si accedes menos de una vez al mes), la recuperación en **milisegundos** y su rendimiento. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Casos de uso (slide 46)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Cuándo usar Standard-IA?',
      E'Ideal para datos a los que se accede con **poca frecuencia** pero que requieren **acceso rápido** cuando se necesitan:\n- **Disaster recovery** (recuperación ante desastres).\n- **Backups** (copias de seguridad).\n- **Almacenes de datos a largo plazo** a los que no se accede con frecuencia.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es un caso de uso típico de Standard-IA?',
   'Backups y disaster recovery',
   'Servir un sitio web de muy alto tráfico',
   'Datos temporales que se borran cada minuto',
   'Standard-IA encaja con backups, DR y almacenes a largo plazo.'),
  ('true_false',
   'Standard-IA es adecuada para almacenes de datos a largo plazo de acceso poco frecuente.',
   'Verdadero', null, null,
   'Es uno de sus casos de uso ideales: long-term data stores.'),
  ('multiple_choice',
   '¿Qué tienen en común los casos de uso de Standard-IA?',
   'Acceso poco frecuente pero necesidad de acceso rápido cuando se requiere',
   'Acceso constante en tiempo real',
   'Que nunca se vuelve a leer el dato',
   'Todos comparten acceso infrecuente con recuperación rápida.'),
  ('multiple_choice',
   '¿Cuál de estos escenarios NO es típico de Standard-IA?',
   'Un dato que se lee miles de veces al día',
   'Una copia de seguridad',
   'Un plan de disaster recovery',
   'El acceso muy frecuente encaja mejor con S3 Standard.'),
  ('anki_card',
   'Menciona tres casos de uso de Standard-IA.',
   'Disaster recovery, backups y almacenes de datos a largo plazo.',
   null, null,
   'Son los ejemplos de acceso poco frecuente con recuperación rápida.')
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
-- LECCIÓN 5 — Precios de Standard-IA (slide 46)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Cómo factura Standard-IA',
      E'El **modelo de precios** de Standard-IA:\n- **Almacenamiento por GB** (storage per GB).\n- **Por peticiones** (per requests).\n- **Tiene tarifa de recuperación** (retrieval fee).\n- **Tiene un cargo mínimo** por duración de almacenamiento de **30 días**.'),
  (2, 'La diferencia frente a Standard',
      E'A diferencia de **S3 Standard**, Standard-IA **sí penaliza el acceso**:\n- **Cobra** por **recuperar** los datos.\n- **Exige** mantener el dato **al menos 30 días**.\n\nPor eso solo compensa con **acceso poco frecuente**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'Standard-IA tiene una tarifa de recuperación (retrieval fee).',
   'Verdadero', null, null,
   'A diferencia de Standard, Standard-IA cobra por recuperar los datos.'),
  ('text_input',
   '¿Cuántos días dura el cargo mínimo de almacenamiento de Standard-IA? (un número)',
   '30', null, null,
   'Standard-IA tiene un cargo mínimo por duración de almacenamiento de 30 días.'),
  ('multiple_choice',
   '¿Por qué dos conceptos principales factura Standard-IA además de las tarifas extra?',
   'Almacenamiento por GB y por peticiones (per requests)',
   'Por número de buckets y de cuentas',
   'Por color del bucket y nombre del objeto',
   'Cobra por GB almacenado y por peticiones, más recuperación y duración mínima.'),
  ('multiple_choice',
   '¿Qué penalización tiene Standard-IA que NO tiene S3 Standard?',
   'Tarifa de recuperación y duración mínima de 30 días',
   'Menor durabilidad de los datos',
   'Almacenamiento en una sola AZ',
   'Standard-IA penaliza el acceso con retrieval fee y mínimo de 30 días.'),
  ('anki_card',
   '¿Qué dos cargos extra distinguen a Standard-IA de S3 Standard?',
   'Una tarifa de recuperación y un cargo mínimo de duración de 30 días.',
   null, null,
   'Son las penalizaciones que hacen que solo compense con acceso poco frecuente.')
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
-- LECCIÓN 6 — Repaso: usos y precios (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: usos y precios',
      'Repasamos los **casos de uso** de Standard-IA (disaster recovery, backups, almacenes a largo plazo) y su **modelo de precios** (por GB, por peticiones, **tarifa de recuperación** y **mínimo de 30 días**). Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final: S3 Storage Classes - Standard-IA (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 13 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Standard-IA**: la clase de **acceso poco frecuente** con **11 nueves** de durabilidad, **3 nueves** de disponibilidad, datos en **3+ AZs**, un **50%** de ahorro frente a Standard (si accedes menos de una vez al mes), recuperación en **milisegundos**, casos de uso como **backups** y **disaster recovery**, y un modelo de precios con **tarifa de recuperación** y **mínimo de 30 días**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_15_aws-saa-c03.sql
-- =============================================================================
