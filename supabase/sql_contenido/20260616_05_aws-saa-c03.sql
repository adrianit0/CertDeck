-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 05
-- Archivo: supabase/sql_contenido/20260616_05_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el TERCER TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Bucket Types" (position 3) — basado en las diapositivas 23-25 del Manual
--       L1 (normal)  Tipos de bucket: general y de directorio   (slide 23)
--       L2 (normal)  Carpetas en S3 (objetos de 0 bytes)        (slides 24-25)
--       L3 (review)  Repaso: tipos de bucket y carpetas
--       L4 (final)   Lección final: S3 Bucket Types
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
-- TEMA: S3 Bucket Types  (etapa "Básico" = position 1; tema position 3)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Bucket Types',
       'Tipos de bucket de S3 (de propósito general y de directorio) y cómo funcionan realmente las carpetas en S3.',
       'Amazon S3 ofrece dos tipos de bucket. Los buckets de propósito general (general purpose) son el tipo original y recomendado para la mayoría de casos de uso: organizan los datos en una jerarquía plana (flat), funcionan con todas las clases de almacenamiento excepto S3 Express One Zone, no tienen límites de prefijos y tienen un límite por defecto de 100 buckets por cuenta. Los buckets de directorio (directory) organizan los datos en una jerarquía de carpetas, se usan únicamente con la clase S3 Express One Zone y se recomiendan cuando necesitas rendimiento de milisegundos de un solo dígito en operaciones PUT y GET; los directorios individuales escalan horizontalmente y el límite por defecto es de 10 buckets de directorio por cuenta. En cuanto a las carpetas: la consola de S3 permite "crear carpetas", pero los buckets de propósito general no tienen carpetas reales como las de un sistema de archivos jerárquico. Al crear una carpeta, S3 genera un objeto de cero bytes cuyo nombre termina en una barra (p. ej. myfolder/). Las carpetas son simplemente objetos de S3: no son entidades independientes, no tienen metadatos ni permisos, no contienen nada (no pueden estar llenas ni vacías) y no se "mueven": al renombrarlas, los objetos que comparten el mismo prefijo se renombran. Un objeto dentro de una carpeta lleva un prefijo que representa esa carpeta.',
       3,
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
-- LECCIONES (4)
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Tipos de bucket: general y de directorio',
      'Buckets de propósito general (flat) frente a buckets de directorio (jerarquía de carpetas).', 'normal'),
  (2, 'Carpetas en S3',
      'Qué son realmente las carpetas en S3: objetos de cero bytes y prefijos.', 'normal'),
  (3, 'Repaso: tipos de bucket y carpetas',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Lección final: S3 Bucket Types',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Tipos de bucket: general y de directorio (slide 23)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Dos tipos de bucket',
      E'Amazon S3 tiene **dos tipos de bucket**:\n- **De propósito general** (general purpose): el tipo **original** y recomendado para la **mayoría** de casos de uso.\n- **De directorio** (directory): pensado para **alto rendimiento** con la clase S3 Express One Zone.'),
  (2, 'Buckets de propósito general',
      E'- Organizan los datos en una **jerarquía plana** (flat).\n- Es el tipo de bucket **original** y **recomendado** para la mayoría de casos.\n- Se usan con **todas las clases de almacenamiento excepto S3 Express One Zone**.\n- **No** hay **límites de prefijos**.\n- Límite por defecto de **100 buckets** de propósito general por cuenta.'),
  (3, 'Buckets de directorio',
      E'- Organizan los datos en una **jerarquía de carpetas**.\n- Se usan **únicamente** con la clase **S3 Express One Zone**.\n- Recomendados cuando necesitas **rendimiento de milisegundos de un solo dígito** en **PUT** y **GET**.\n- **No** hay límites de prefijos; los directorios individuales **escalan horizontalmente**.\n- Límite por defecto de **10 buckets** de directorio por cuenta.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cómo organizan los datos los buckets de propósito general?',
   'En una jerarquía plana (flat)',
   'En una jerarquía de carpetas',
   'En una base de datos relacional',
   'Los buckets de propósito general usan una jerarquía plana; los de directorio, de carpetas.'),
  ('multiple_choice',
   '¿Con qué clase de almacenamiento se usan los buckets de directorio?',
   'S3 Express One Zone',
   'S3 Standard',
   'S3 Glacier Deep Archive',
   'Los buckets de directorio se usan únicamente con S3 Express One Zone.'),
  ('true_false',
   'Los buckets de propósito general pueden usarse con la clase S3 Express One Zone.',
   'Falso', null, null,
   'Los de propósito general se usan con todas las clases EXCEPTO S3 Express One Zone.'),
  ('multiple_choice',
   '¿Cuándo se recomiendan los buckets de directorio?',
   'Cuando necesitas rendimiento de milisegundos de un solo dígito en PUT y GET',
   'Cuando necesitas el menor coste de almacenamiento',
   'Cuando quieres archivar datos a largo plazo',
   'Los buckets de directorio aportan latencia de un solo dígito de milisegundos en PUT/GET.'),
  ('text_input',
   'Límite por defecto de buckets de propósito general por cuenta (un número).',
   '100', null, null,
   'Por defecto hay 100 buckets de propósito general (y 10 de directorio) por cuenta.'),
  ('anki_card',
   '¿Cuál es el límite por defecto de buckets de directorio por cuenta?',
   '10 buckets de directorio por cuenta.',
   null, null,
   'El límite por defecto es de 10 buckets de directorio por cuenta.')
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
-- LECCIÓN 2 — Carpetas en S3 (slides 24-25)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Las carpetas no son carpetas reales',
      E'La **consola de S3** te permite "**crear carpetas**", pero los buckets de propósito general **no tienen carpetas reales** como las de un sistema de archivos jerárquico.\n\nAl crear una carpeta, S3 genera un **objeto de cero bytes** cuyo nombre **termina en una barra** (p. ej. `myfolder/`).'),
  (2, 'Las carpetas son solo objetos',
      E'Las carpetas de S3 **no son entidades independientes**, sino simplemente **objetos de S3**:\n- **No** incluyen **metadatos** ni **permisos**.\n- **No** contienen nada: no pueden estar **llenas** ni **vacías**.\n- **No se mueven**: al renombrar, los objetos que comparten el **mismo prefijo** se renombran.'),
  (3, 'Carpetas y prefijos',
      E'- Una carpeta se **representa como un objeto**.\n- Ese objeto ocupa **0 bytes**.\n- Un objeto **dentro** de una carpeta lleva un **prefijo** que representa esa carpeta (p. ej. `myfolder/archivo.txt`).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'Cuando creas una "carpeta" en la consola de S3, ¿qué crea S3 realmente?',
   'Un objeto de cero bytes cuyo nombre termina en una barra (/)',
   'Un directorio real en un sistema de archivos',
   'Un nuevo bucket de directorio',
   'S3 crea un objeto de 0 bytes con nombre terminado en "/", p. ej. myfolder/.'),
  ('true_false',
   'Los buckets de propósito general tienen carpetas reales como un sistema de archivos jerárquico.',
   'Falso', null, null,
   'No las tienen: las "carpetas" son objetos de cero bytes, no carpetas reales.'),
  ('multiple_choice',
   '¿Qué es cierto sobre una carpeta de S3?',
   'No incluye metadatos ni permisos propios',
   'Tiene sus propios permisos independientes',
   'Almacena los objetos en su interior',
   'Las carpetas son objetos: no tienen metadatos ni permisos y no contienen nada.'),
  ('true_false',
   'Una carpeta de S3 puede estar "llena" o "vacía".',
   'Falso', null, null,
   'Una carpeta no contiene nada, así que no puede estar llena ni vacía.'),
  ('anki_card',
   '¿Qué le ocurre a los objetos cuando "mueves" o renombras una carpeta de S3?',
   'Los objetos que comparten el mismo prefijo se renombran (las carpetas no se mueven).',
   null, null,
   'Las carpetas no se mueven; al renombrar, se renombran los objetos con ese prefijo.'),
  ('text_input',
   'Un objeto dentro de una carpeta lleva un ____ que representa esa carpeta (una palabra).',
   'prefijo', null, null,
   'El prefijo (p. ej. myfolder/) representa la carpeta dentro del nombre del objeto.')
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
-- LECCIÓN 3 — Repaso: tipos de bucket y carpetas (review · sin preguntas propias)
-- Las tarjetas se reciclan en runtime de las lecciones anteriores (ADR 0005).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: tipos de bucket y carpetas',
      'Vamos a repasar lo visto: los **tipos de bucket** (de propósito general y de directorio) y cómo funcionan las **carpetas** en S3. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Lección final: S3 Bucket Types (final · sin preguntas propias)
-- Recicla ~6 tarjetas al azar del tema (ADR 0005, enmienda 2026-06-16).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 3 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto los **tipos de bucket** de S3 (de propósito general y de directorio) y cómo funcionan realmente las **carpetas**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_05_aws-saa-c03.sql
-- =============================================================================
