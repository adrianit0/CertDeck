-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 02
-- Archivo: supabase/sql_contenido/20260515_02_aws-saa-c03.sql
-- Fecha: 2026-06-15
--
-- Crea la PRIMERA ETAPA y el PRIMER TEMA con sus lecciones:
--   Etapa: "Básico"  (cubrirá S3, AWS API y VPC; aquí solo S3)
--     Tema: "Introduction to S3"  (basado en la diapositiva 18 del Manual)
--       L1 (normal)  ¿Qué es el almacenamiento de objetos?
--       L2 (normal)  Anatomía de un objeto en S3
--       L3 (normal)  Buckets y espacio de nombres
--       L4 (review)  Repaso: fundamentos de S3
--       L5 (final)   Lección final: Introducción a S3
--
-- Dependencias: script-001.sql (esquema contenido) + script-002.sql (preguntas)
--               + 20260515_01_aws-saa-c03.sql (curso) aplicados.
-- Idempotente: usa ON CONFLICT sobre claves naturales (position para
-- etapas/temas/lecciones/pantallas; (lesson_id, question) para las preguntas).
-- Requiere script-004.sql aplicado (flashcards sin position/difficulty).
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- ETAPA: Básico
-- ---------------------------------------------------------------------------
insert into public.certdeck_stages (course_id, title, description, position, is_published)
select c.id,
       'Básico',
       'Fundamentos de AWS. Cubrirá S3, AWS API y VPC.',
       1,
       true
from public.certdeck_courses c
where c.slug = 'aws-saa-c03'
on conflict (course_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  is_published = excluded.is_published,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- TEMA: Introduction to S3
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'Introduction to S3',
       'Conceptos básicos de Amazon S3: almacenamiento de objetos, objetos y sus componentes, buckets y espacio de nombres.',
       'Amazon S3 es un servicio de almacenamiento de objetos con capacidad prácticamente ilimitada y totalmente gestionado. Los datos se guardan como objetos (Key, Value, Version ID y Metadata) dentro de buckets, cuyos nombres son únicos globalmente. Un objeto puede medir de 0 bytes a 5 TB.',
       1,
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
-- LECCIONES (5)
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es el almacenamiento de objetos?',
      'Concepto de object storage y qué ofrece Amazon S3.', 'normal'),
  (2, 'Anatomía de un objeto en S3',
      'Qué es un objeto y sus componentes: Key, Value, Version ID y Metadata.', 'normal'),
  (3, 'Buckets y espacio de nombres',
      'Buckets, carpetas, namespace universal y tamaño de los objetos.', 'normal'),
  (4, 'Repaso: fundamentos de S3',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: Introducción a S3',
      'Repaso amplio para cerrar el tema y avanzar al siguiente.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- Subconsulta reutilizable: id de la lección por posición dentro del tema.
-- (Se repite en cada bloque para mantener el script lineal y legible.)

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es el almacenamiento de objetos?
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Almacenamiento de objetos',
      'El almacenamiento de objetos (object storage) es una arquitectura que gestiona los datos como **objetos**, a diferencia de otras arquitecturas de almacenamiento. Amazon **S3** te ofrece almacenamiento prácticamente **ilimitado** y no necesitas preocuparte por la infraestructura subyacente.'),
  (2, 'La consola de S3',
      'La **consola de S3** te proporciona una interfaz para **subir** y **acceder** a tus datos de forma sencilla.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('anki_card',
   '¿Cómo gestiona los datos el almacenamiento de objetos?',
   'Como objetos, en lugar de como bloques o ficheros jerárquicos.',
   null, null,
   'El object storage trata cada dato como un objeto independiente.'),
  ('multiple_choice',
   '¿Cuánta capacidad de almacenamiento te ofrece Amazon S3?',
   'Prácticamente ilimitada',
   'Hasta 5 GB', 'Hasta 1 TB',
   'S3 ofrece almacenamiento ilimitado; no gestionas la infraestructura.'),
  ('true_false',
   'En S3 debes aprovisionar y gestionar tú la infraestructura de almacenamiento subyacente.',
   'Falso',
   null, null,
   'S3 es un servicio gestionado: no te preocupas por la infraestructura.')
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
-- LECCIÓN 2 — Anatomía de un objeto en S3
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Los objetos son como ficheros',
      'Los **objetos** contienen tus datos; son **como ficheros**. Cada objeto puede constar de varios componentes.'),
  (2, 'Componentes de un objeto',
      E'- **Key**: el nombre del objeto.\n- **Value**: los datos en sí, una secuencia de bytes.\n- **Version ID**: la versión del objeto cuando el versionado está habilitado.\n- **Metadata**: información adicional adjunta al objeto.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué componente de un objeto S3 representa su nombre?',
   'Key', 'Value', 'Metadata',
   'La Key es el nombre que identifica al objeto dentro del bucket.'),
  ('anki_card',
   '¿Qué es el "Value" de un objeto S3?',
   'Los datos en sí, formados por una secuencia de bytes.',
   null, null,
   'El Value es el contenido del objeto.'),
  ('true_false',
   'El "Version ID" de un objeto solo es relevante cuando el versionado está habilitado.',
   'Verdadero', null, null,
   'Sin versionado no se asignan versiones a los objetos.'),
  -- Respuesta escrita (text_input): respuesta de una sola palabra.
  ('text_input',
   '¿Qué campo guarda información adicional adjunta al objeto?',
   'Metadata', null, null,
   'Los metadatos son información extra asociada al objeto.')
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
-- LECCIÓN 3 — Buckets y espacio de nombres
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Buckets',
      'Los **buckets** contienen objetos. También pueden tener **carpetas**, que a su vez contienen objetos.'),
  (2, 'Espacio de nombres y tamaño',
      'S3 es un **espacio de nombres universal**, por lo que los **nombres de bucket deben ser únicos** globalmente (como un nombre de dominio). Un objeto individual puede medir de **0 bytes a 5 TB**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('anki_card',
   '¿Qué contienen los buckets de S3?',
   'Objetos (y, opcionalmente, carpetas que contienen objetos).',
   null, null,
   'El bucket es el contenedor de nivel superior en S3.'),
  ('true_false',
   'Dos cuentas distintas pueden tener buckets con el mismo nombre.',
   'Falso', null, null,
   'El namespace de S3 es universal: los nombres de bucket son únicos globalmente.'),
  ('multiple_choice',
   '¿Cuál es el tamaño máximo de un único objeto en S3?',
   '5 TB', '5 GB', '500 GB',
   'Un objeto individual puede ir de 0 bytes hasta 5 TB.'),
  ('multiple_choice',
   '¿Por qué los nombres de bucket deben ser únicos globalmente?',
   'Porque S3 usa un espacio de nombres universal',
   'Porque cada región exige nombres distintos',
   'Porque el nombre se usa como clave de cifrado',
   'El namespace universal obliga a nombres únicos en todo S3.')
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
-- LECCIÓN 4 — Repaso: fundamentos de S3 (review)
-- Repaso explícito de las lecciones 1-3. (Cuando exista el generador dinámico
-- de repasos, ver ADR 0002, podrá componerse automáticamente.)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso de fundamentos de S3',
      'Vamos a repasar las ideas clave de las lecciones anteriores: object storage, componentes del objeto y buckets.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'Capacidad de almacenamiento que ofrece S3:',
   'Prácticamente ilimitada', 'Limitada por el disco', 'Máximo 1 TB',
   'S3 ofrece almacenamiento ilimitado y gestionado.'),
  ('multiple_choice',
   'Tamaño máximo de un objeto individual en S3:',
   '5 TB', '5 GB', '50 GB',
   'De 0 bytes a 5 TB por objeto.'),
  ('true_false',
   'Los nombres de bucket en S3 son únicos a nivel global.',
   'Verdadero', null, null,
   'S3 es un namespace universal.'),
  ('anki_card',
   '¿Qué representa la "Key" de un objeto?',
   'El nombre del objeto.',
   null, null,
   'La Key identifica al objeto dentro del bucket.')
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
-- LECCIÓN 5 — Lección final: Introducción a S3 (final)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Casi lo tienes!',
      'Has aprendido los fundamentos de Amazon S3. Esta lección final repasa lo esencial antes de avanzar al siguiente tema.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 1 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué es Amazon S3?',
   'Un servicio de almacenamiento de objetos',
   'Una base de datos relacional',
   'Un servicio de cómputo',
   'S3 es almacenamiento de objetos gestionado.'),
  ('true_false',
   'S3 almacena los datos como objetos.',
   'Verdadero', null, null,
   'S3 es object storage.'),
  ('multiple_choice',
   '¿Cuál de estos NO es un componente de un objeto S3?',
   'Tabla', 'Key', 'Metadata',
   'Los componentes son Key, Value, Version ID y Metadata.'),
  ('anki_card',
   'Resume en una frase qué es un bucket en S3.',
   'Un contenedor donde se guardan los objetos (y carpetas) en S3.',
   null, null,
   'El bucket es el contenedor de nivel superior.')
) as v(exercise_type, question, correct_answer,
       incorrect_answer_1, incorrect_answer_2, explanation)
on conflict (lesson_id, question) do update set
  exercise_type = excluded.exercise_type,
  correct_answer = excluded.correct_answer,
  incorrect_answer_1 = excluded.incorrect_answer_1,
  incorrect_answer_2 = excluded.incorrect_answer_2,
  explanation = excluded.explanation,
  updated_at = now();

-- =============================================================================
-- Fin de 20260515_02_aws-saa-c03.sql
-- =============================================================================
