-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 11
-- Archivo: supabase/sql_contenido/20260616_11_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el NOVENO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Access & Endpoints" (position 9) — diapositivas 38-41 del Manual
--       L1 (normal)  S3 Bucket URI                      (slide 38)
--       L2 (normal)  AWS S3 CLI                         (slide 39)
--       L3 (review)  Repaso: URI y CLI
--       L4 (normal)  Estilos de petición REST           (slide 40)
--       L5 (normal)  Dualstack Endpoints                (slide 41)
--       L6 (review)  Repaso: peticiones y endpoints
--       L7 (final)   Lección final: S3 Access & Endpoints
--   Volumen: MEDIO -> normal·normal·review·normal·normal·review·final (7 lecciones).
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
-- TEMA: S3 Access & Endpoints  (etapa "Básico" = position 1; tema position 9)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Access & Endpoints',
       'Cómo se referencia y se accede a S3: bucket URI, la AWS CLI, los estilos de petición REST y los endpoints Dualstack.',
       'El S3 Bucket URI (Uniform Resource Identifier) es una forma de referenciar la dirección de un bucket y de los objetos de S3, con el formato s3://mibucket/foto.jpg; este URI es necesario para ciertos comandos de la AWS CLI. La AWS CLI ofrece varios grupos de comandos: aws s3 es una forma de alto nivel de interactuar con buckets y objetos; aws s3api es la forma de bajo nivel; aws s3control gestiona access points, buckets de S3 Outposts, S3 Batch Operations y Storage Lens; y aws s3outposts gestiona los endpoints de S3 Outposts. Al hacer peticiones con la REST API hay dos estilos: las peticiones virtual hosted-style, donde el nombre del bucket es un subdominio del host (p. ej. examplebucket.s3.us-west-2.amazonaws.com), y las peticiones path-style, donde el nombre del bucket va en la ruta de la petición (p. ej. s3.us-west-2.amazonaws.com/examplebucket/...). S3 admite ambos estilos, pero las URL path-style se descontinuarán en el futuro; para forzar a la AWS CLI a usar virtual hosted-style hay que configurarla globalmente. Por último, al acceder a la API de S3 hay dos endpoints posibles: el endpoint estándar, que solo gestiona tráfico IPv4 (p. ej. https://s3.us-east-2.amazonaws.com), y el endpoint Dualstack, que gestiona tráfico IPv4 e IPv6 (p. ej. https://s3.dualstack.us-east-2.amazonaws.com). En su día AWS solo ofrecía IPv4, y Dualstack se diseñó como su reemplazo futuro, ya que las direcciones IPv4 se están agotando e IPv6 tiene un espacio de direcciones públicas mucho mayor. La AWS CLI probablemente usa Dualstack por debajo, aunque algunos servicios todavía generan el endpoint estándar. Existen otros endpoints de S3 (Static Website, FIPS, S3 Control, Access Points).',
       9,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'S3 Bucket URI',
      'Cómo se referencia la dirección de un bucket y sus objetos.', 'normal'),
  (2, 'AWS S3 CLI',
      'Los grupos de comandos de la CLI: s3, s3api, s3control y s3outposts.', 'normal'),
  (3, 'Repaso: URI y CLI',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Estilos de petición REST',
      'Peticiones virtual hosted-style frente a path-style.', 'normal'),
  (5, 'Dualstack Endpoints',
      'Endpoint estándar (IPv4) frente a endpoint Dualstack (IPv4 + IPv6).', 'normal'),
  (6, 'Repaso: peticiones y endpoints',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: S3 Access & Endpoints',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — S3 Bucket URI (slide 38)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es el S3 Bucket URI?',
      E'El **S3 Bucket URI** (Uniform Resource Identifier) es una forma de **referenciar la dirección** de un **bucket** y de los **objetos** de S3.\n\n- Formato: `s3://mibucket/foto.jpg`.\n- Este URI es **necesario** para **ciertos comandos** de la **AWS CLI**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué es el S3 Bucket URI?',
   'Una forma de referenciar la dirección de un bucket y sus objetos',
   'Un permiso IAM para acceder a S3',
   'Un algoritmo de cifrado de objetos',
   'El URI referencia la dirección de buckets y objetos de S3.'),
  ('multiple_choice',
   '¿Cuál es el formato correcto de un S3 Bucket URI?',
   's3://mibucket/foto.jpg',
   'https://mibucket/foto.jpg',
   'arn:aws:s3:::mibucket/foto.jpg',
   'El URI usa el esquema s3://seguido del bucket y la clave del objeto.'),
  ('true_false',
   'El S3 Bucket URI es necesario para algunos comandos de la AWS CLI.',
   'Verdadero', null, null,
   'Ciertos comandos de la CLI requieren el URI s3://.'),
  ('text_input',
   'El esquema con el que empieza un S3 Bucket URI es ____:// (una palabra).',
   's3', null, null,
   'El URI de S3 empieza por el esquema s3://.')
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
-- LECCIÓN 2 — AWS S3 CLI (slide 39)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Los grupos de comandos de la CLI',
      E'La **AWS CLI** ofrece varios grupos de comandos para S3:\n- **`aws s3`**: forma de **alto nivel** de interactuar con buckets y objetos.\n- **`aws s3api`**: forma de **bajo nivel** de interactuar con buckets y objetos.\n- **`aws s3control`**: gestiona **access points**, **buckets de S3 Outposts**, **S3 Batch Operations** y **Storage Lens**.\n- **`aws s3outposts`**: gestiona los **endpoints de S3 Outposts**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué comando de la CLI es la forma de ALTO nivel de interactuar con S3?',
   'aws s3',
   'aws s3api',
   'aws s3control',
   'aws s3 es de alto nivel; aws s3api es de bajo nivel.'),
  ('multiple_choice',
   '¿Cuál es la forma de BAJO nivel de interactuar con buckets y objetos?',
   'aws s3api',
   'aws s3',
   'aws s3outposts',
   'aws s3api ofrece el control de bajo nivel de la API de S3.'),
  ('multiple_choice',
   '¿Qué gestiona aws s3control?',
   'Access points, buckets de Outposts, Batch Operations y Storage Lens',
   'Solo la copia de archivos entre buckets',
   'El cifrado en reposo de los objetos',
   's3control administra access points, Outposts, Batch Operations y Storage Lens.'),
  ('multiple_choice',
   '¿Para qué sirve aws s3outposts?',
   'Para gestionar los endpoints de S3 Outposts',
   'Para subir objetos de alto nivel',
   'Para crear access points',
   'aws s3outposts gestiona los endpoints de S3 Outposts.'),
  ('anki_card',
   '¿Cuáles son los cuatro grupos de comandos de S3 en la AWS CLI?',
   'aws s3, aws s3api, aws s3control y aws s3outposts.',
   null, null,
   'Cada uno cubre un nivel/ámbito distinto de interacción con S3.'),
  ('true_false',
   'aws s3api es una forma de alto nivel de interactuar con S3.',
   'Falso', null, null,
   'aws s3api es de bajo nivel; el de alto nivel es aws s3.')
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
-- LECCIÓN 3 — Repaso: URI y CLI (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: URI y CLI',
      'Vamos a repasar el **S3 Bucket URI** y los **grupos de comandos** de la AWS CLI. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Estilos de petición REST (slide 40)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Dos estilos de petición',
      E'Al hacer peticiones con la **REST API** hay **dos estilos**:\n- **Virtual hosted-style**: el **nombre del bucket** es un **subdominio** del host.\n  - Ej.: `Host: examplebucket.s3.us-west-2.amazonaws.com`\n- **Path-style**: el **nombre del bucket** va en la **ruta** de la petición.\n  - Ej.: `DELETE /examplebucket/puppy.jpg` con `Host: s3.us-west-2.amazonaws.com`'),
  (2, 'Cuál usar',
      E'- S3 **admite ambos** estilos, pero las **URL path-style** se **descontinuarán** en el futuro.\n- Para **forzar** a la AWS CLI a usar **virtual hosted-style**, hay que **configurarla globalmente**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'En una petición virtual hosted-style, ¿dónde aparece el nombre del bucket?',
   'Como un subdominio del host',
   'En la ruta de la petición',
   'En la cabecera de autorización',
   'En virtual hosted-style el bucket es un subdominio del host.'),
  ('multiple_choice',
   'En una petición path-style, ¿dónde aparece el nombre del bucket?',
   'En la ruta de la petición',
   'Como subdominio del host',
   'En una cookie',
   'En path-style el nombre del bucket va dentro de la ruta.'),
  ('true_false',
   'Las URL path-style se descontinuarán en el futuro.',
   'Verdadero', null, null,
   'AWS planea retirar las URL path-style; el futuro es virtual hosted-style.'),
  ('true_false',
   'S3 admite tanto peticiones virtual hosted-style como path-style.',
   'Verdadero', null, null,
   'S3 soporta ambos estilos, aunque path-style se descontinuará.'),
  ('anki_card',
   '¿Qué hay que hacer para forzar a la AWS CLI a usar virtual hosted-style?',
   'Configurar la CLI globalmente.',
   null, null,
   'Se fuerza el estilo virtual hosted-style mediante configuración global de la CLI.'),
  ('multiple_choice',
   '¿Qué host corresponde a una petición virtual hosted-style?',
   'examplebucket.s3.us-west-2.amazonaws.com',
   's3.us-west-2.amazonaws.com',
   'examplebucket.amazonaws.com/s3',
   'El bucket aparece como subdominio: examplebucket.s3.us-west-2.amazonaws.com.')
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
-- LECCIÓN 5 — Dualstack Endpoints (slide 41)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Estándar frente a Dualstack',
      E'Al acceder a la **API de S3** hay **dos endpoints** posibles:\n- **Endpoint estándar**: gestiona **solo tráfico IPv4**.\n  - Ej.: `https://s3.us-east-2.amazonaws.com`\n- **Endpoint Dualstack**: gestiona tráfico **IPv4 e IPv6**.\n  - Ej.: `https://s3.dualstack.us-east-2.amazonaws.com`'),
  (2, 'Por qué Dualstack',
      E'- En su día AWS **solo ofrecía IPv4**; **Dualstack** se diseñó como su **reemplazo futuro**, porque las direcciones **IPv4 se están agotando** e **IPv6** tiene un **espacio de direcciones** mucho mayor.\n- La AWS CLI **probablemente usa Dualstack** por debajo, aunque algunos servicios todavía generan el **endpoint estándar**.\n- Existen **otros endpoints** de S3 (Static Website, FIPS, S3 Control, Access Points).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué tipo de tráfico gestiona el endpoint estándar de S3?',
   'Solo IPv4',
   'Solo IPv6',
   'IPv4 e IPv6',
   'El endpoint estándar solo maneja tráfico IPv4.'),
  ('multiple_choice',
   '¿Qué tráfico gestiona el endpoint Dualstack?',
   'IPv4 e IPv6',
   'Solo IPv4',
   'Solo IPv6',
   'El endpoint Dualstack admite tanto IPv4 como IPv6.'),
  ('true_false',
   'Dualstack se diseñó como reemplazo futuro porque las direcciones IPv4 se están agotando.',
   'Verdadero', null, null,
   'IPv4 se agota e IPv6 ofrece más direcciones; Dualstack es el futuro.'),
  ('multiple_choice',
   '¿Cuál de estos es un endpoint Dualstack?',
   'https://s3.dualstack.us-east-2.amazonaws.com',
   'https://s3.us-east-2.amazonaws.com',
   's3://us-east-2/dualstack',
   'El endpoint Dualstack incluye "dualstack" en el host.'),
  ('text_input',
   'El endpoint Dualstack admite IPv4 e ____ (siglas).',
   'IPv6', null, null,
   'Dualstack gestiona IPv4 e IPv6.'),
  ('anki_card',
   '¿Qué endpoint usa probablemente la AWS CLI por debajo?',
   'El endpoint Dualstack.',
   null, null,
   'La CLI tiende a usar Dualstack, aunque algunos servicios aún generan el estándar.')
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
-- LECCIÓN 6 — Repaso: peticiones y endpoints (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: peticiones y endpoints',
      'Repasamos los **estilos de petición REST** (virtual hosted-style y path-style) y los **endpoints** estándar y Dualstack. Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final: S3 Access & Endpoints (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 9 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto cómo se referencia y se accede a S3: el **bucket URI**, la **AWS CLI**, los **estilos de petición REST** y los **endpoints Dualstack**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_11_aws-saa-c03.sql
-- =============================================================================
