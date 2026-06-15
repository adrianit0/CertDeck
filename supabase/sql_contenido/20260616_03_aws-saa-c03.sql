-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 03
-- Archivo: supabase/sql_contenido/20260616_03_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el SEGUNDO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Bucket" (position 2) — basado en las diapositivas 19-22 del Manual
--       L1 (normal)  Visión general de los buckets           (slide 19)
--       L2 (normal)  Reglas de nombrado de buckets           (slide 20)
--       L3 (review)  Repaso: buckets y nombrado
--       L4 (normal)  Ejemplos de nombres válidos e inválidos (slide 21)
--       L5 (normal)  Restricciones y límites de los buckets  (slide 22)
--       L6 (review)  Repaso: ejemplos y límites
--       L7 (final)   Lección final: S3 Bucket
--
-- COMPOSICIÓN DINÁMICA (ADR 0005, enmienda 2026-06-16): las lecciones `review`
-- y `final` NO almacenan preguntas propias; sus tarjetas se reciclan en runtime
-- (`certdeck-playable-lesson`): review -> ~4 de las 5 lecciones anteriores;
-- final -> ~6 del mismo tema. Aquí solo llevan una pantalla de introducción.
--
-- Dependencias: script-001.sql + script-002.sql + script-004.sql aplicados y
--               20260515_01/02 aplicados (curso + etapa "Básico").
-- Idempotente: ON CONFLICT sobre claves naturales (position para
-- etapas/temas/lecciones/pantallas; (lesson_id, question) para las preguntas).
-- NO ejecutado por el agente (Constitución §4). El propietario lo aplica.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TEMA: S3 Bucket  (etapa "Básico" = position 1; tema position 2)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Bucket',
       'Buckets de S3: visión general, reglas de nombrado (con ejemplos válidos/inválidos) y restricciones y límites.',
       'Los buckets de Amazon S3 son la infraestructura que contiene los objetos. S3 es un servicio global, pero cada bucket se crea en una región concreta. Existen reglas estrictas de nombrado: 3–63 caracteres; solo minúsculas, números, puntos (.) y guiones (-); deben empezar y terminar con letra o número; sin puntos adyacentes; no con formato de dirección IP; y sin mayúsculas, guiones bajos ni espacios. Además hay prefijos reservados (xn--, s3alias-, amzn-s3-demo, sthree-, sthree-configurator) y sufijos reservados (-s3alias, --ol-s3, --x-s3, .mrap), y el nombre debe ser único en todas las cuentas y regiones dentro de una partición (aws, aws-cn, aws-us-gov). Los nombres siguen reglas parecidas a las de las URL porque se usan para formar enlaces HTTPS. En cuanto a límites: por defecto puedes crear 100 buckets por cuenta (ampliables a 1000 mediante una solicitud de servicio), debes vaciar un bucket antes de borrarlo, no hay tamaño máximo de bucket ni límite en el número de objetos, los archivos miden de 0 a 5 TB y los mayores de 100 MB deberían subirse con multipart upload.',
       2,
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
-- LECCIONES (7)
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Visión general de los buckets',
      'Qué es un bucket, qué contiene y panorama de sus funciones.', 'normal'),
  (2, 'Reglas de nombrado de buckets',
      'Cómo deben nombrarse los buckets: longitud, caracteres, unicidad y prefijos/sufijos reservados.', 'normal'),
  (3, 'Repaso: buckets y nombrado',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Ejemplos de nombres válidos e inválidos',
      'Clasificar nombres de bucket según las reglas.', 'normal'),
  (5, 'Restricciones y límites de los buckets',
      'Cuántos buckets, tamaños de archivo, borrado y operaciones.', 'normal'),
  (6, 'Repaso: ejemplos y límites',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: S3 Bucket',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Visión general de los buckets (slide 19)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un bucket?',
      'Los **buckets** son **infraestructura** y **contienen** los objetos de S3. S3 es un servicio **disponible globalmente**, pero al **crear** un bucket especificas una **región** concreta.'),
  (2, 'Qué veremos sobre los buckets',
      E'Sobre los buckets aprenderemos:\n- **Reglas de nombrado**: cómo deben llamarse.\n- **Restricciones y límites**: qué se puede y qué no.\n- **Tipos**: de propósito general (flat) y de directorio.\n- **Carpetas virtuales**, **versionado**, **cifrado** y **alojamiento de webs estáticas**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'S3 es un servicio global, pero un bucket se crea en una región concreta.',
   'Verdadero', null, null,
   'S3 está disponible globalmente; al crear el bucket eliges su región.'),
  ('multiple_choice',
   '¿Qué contienen los buckets de S3?',
   'Objetos (el bucket es la infraestructura que los contiene)',
   'Bloques de disco sin formato',
   'Funciones de cómputo',
   'Un bucket es infraestructura que almacena objetos de S3.'),
  ('anki_card',
   '¿Qué dos tipos de bucket existen en S3?',
   'De propósito general (flat) y de directorio (directory).',
   null, null,
   'S3 ofrece buckets de propósito general y de directorio.'),
  ('multiple_choice',
   '¿Cuál de estas es una función de los buckets de S3?',
   'Versionado de los objetos',
   'Ejecutar contenedores',
   'Consultas SQL nativas sobre tablas',
   'Entre sus funciones están versionado, cifrado y hosting web estático.')
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
-- LECCIÓN 2 — Reglas de nombrado de buckets (slide 20)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Reglas básicas de nombrado',
      E'- **Longitud**: 3–63 caracteres.\n- **Caracteres**: solo minúsculas, números, puntos (.) y guiones (-).\n- **Inicio/fin**: deben empezar y terminar con letra o número.\n- **Sin puntos adyacentes** y **sin formato de IP** (p. ej. 192.168.5.4).\n- **Sin mayúsculas, sin guiones bajos y sin espacios**.'),
  (2, 'Unicidad y nombres reservados',
      E'- **Únicos** en todas las cuentas y regiones dentro de una **partición** (aws, aws-cn, aws-us-gov); no se reutilizan hasta borrar el original.\n- **Prefijos prohibidos**: xn--, s3alias-, amzn-s3-demo, sthree-, sthree-configurator.\n- **Sufijos prohibidos**: -s3alias, --ol-s3, --x-s3, .mrap.\n- Con **Transfer Acceleration** el nombre no puede llevar puntos.\n\nSiguen reglas parecidas a las **URL** porque se usan para formar enlaces HTTPS.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué longitud debe tener el nombre de un bucket?',
   'Entre 3 y 63 caracteres',
   'Entre 1 y 255 caracteres',
   'Exactamente 64 caracteres',
   'El nombre debe medir de 3 a 63 caracteres.'),
  ('true_false',
   'Los nombres de bucket pueden contener mayúsculas y guiones bajos.',
   'Falso', null, null,
   'No se permiten mayúsculas, guiones bajos ni espacios.'),
  ('multiple_choice',
   '¿Cuál de estos caracteres está permitido en un nombre de bucket?',
   'El guion (-)',
   'El guion bajo (_)',
   'El espacio',
   'Solo se permiten minúsculas, números, puntos y guiones.'),
  ('anki_card',
   '¿Se permiten dos puntos adyacentes (..) en el nombre de un bucket?',
   'No, los puntos adyacentes no están permitidos.',
   null, null,
   'Los nombres no pueden contener dos puntos seguidos.'),
  ('text_input',
   'Un bucket debe ser único en todas las cuentas y regiones dentro de una ____ (una palabra).',
   'partición', null, null,
   'La unicidad se exige dentro de una partición (aws, aws-cn, aws-us-gov).')
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
-- LECCIÓN 3 — Repaso: buckets y nombrado (review · sin preguntas propias)
-- Las tarjetas se reciclan en runtime de las lecciones anteriores (ADR 0005).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: buckets y nombrado',
      'Vamos a repasar lo visto hasta ahora: qué es un bucket y las **reglas de nombrado**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Ejemplos de nombres válidos e inválidos (slide 21)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Clasificar nombres',
      E'Vamos a clasificar nombres de bucket como **válidos** o **inválidos** según las reglas.\n\n**Válidos**: `mybucket-123`, `log-bucket`, `example-bucket-1`, `test.bucket.data`, `archive-bucket`.'),
  (2, 'Por qué fallan algunos',
      E'- `123.456.789.012` → **inválido**: formato de **IP**.\n- `My-Bucket` → **inválido**: **mayúsculas**.\n- `data.bucket..archive` → **inválido**: **puntos adyacentes**.\n- `xn--bucketname` → **inválido**: prefijo **xn--**.\n- `bucket_name` → **inválido**: **guion bajo**.\n- `sthree-config-bucket` → **inválido**: prefijo **sthree-config**.\n- `new-bucket-s3alias` → **inválido**: sufijo **-s3alias**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Por qué "My-Bucket" es un nombre inválido?',
   'Contiene letras mayúsculas',
   'Contiene un guion',
   'Es demasiado corto',
   'No se permiten mayúsculas en los nombres de bucket.'),
  ('multiple_choice',
   '¿Por qué "data.bucket..archive" es inválido?',
   'Tiene puntos adyacentes',
   'Empieza por un punto',
   'Es demasiado largo',
   'No se permiten dos puntos seguidos.'),
  ('true_false',
   '"bucket_name" es un nombre de bucket válido.',
   'Falso', null, null,
   'Contiene un guion bajo (_), que no está permitido.'),
  ('multiple_choice',
   '"123.456.789.012" es inválido porque…',
   'Tiene formato de dirección IP',
   'Contiene números',
   'Es demasiado largo',
   'Los nombres no pueden tener formato de IP.'),
  ('anki_card',
   '¿Es válido el nombre "log-bucket"?',
   'Sí: usa solo minúsculas y un guion, cumpliendo las reglas.',
   null, null,
   'Cumple longitud y caracteres permitidos.')
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
-- LECCIÓN 5 — Restricciones y límites de los buckets (slide 22)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Límites de buckets',
      E'- Por defecto puedes crear **100 buckets**; con una **solicitud de servicio** puedes aumentar a **1000**.\n- Debes **vaciar** un bucket antes de poder **borrarlo**.\n- **No hay tamaño máximo** de bucket ni **límite** en el número de objetos.'),
  (2, 'Archivos y operaciones',
      E'- Los archivos miden de **0 a 5 TB**.\n- Los mayores de **100 MB** deberían usar **multipart upload**.\n- **Get, Put, List y Delete** están diseñadas para **alta disponibilidad**; las de **crear/borrar/configurar** conviene ejecutarlas con menos frecuencia.\n- **S3 para AWS Outposts** tiene límites propios.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuántos buckets puedes crear por defecto?',
   '100',
   '10',
   '1000',
   'El límite por defecto es de 100 buckets por cuenta.'),
  ('multiple_choice',
   'Con una solicitud de servicio, ¿hasta cuántos buckets puedes llegar?',
   '1000',
   '500',
   'Ilimitados',
   'Puedes ampliar el límite hasta 1000 buckets.'),
  ('true_false',
   'Puedes borrar un bucket sin vaciarlo antes.',
   'Falso', null, null,
   'Hay que vaciar el bucket antes de poder borrarlo.'),
  ('multiple_choice',
   '¿A partir de qué tamaño se recomienda usar multipart upload?',
   '100 MB',
   '5 GB',
   '1 TB',
   'Los archivos de más de 100 MB deberían subirse con multipart upload.'),
  ('anki_card',
   '¿Cuál es el tamaño máximo de un archivo en S3?',
   '5 TB (los archivos van de 0 a 5 TB).',
   null, null,
   'Cada archivo puede medir de 0 a 5 TB.'),
  ('text_input',
   '¿Qué debes hacer con un bucket antes de borrarlo? (una palabra)',
   'vaciarlo', null, null,
   'Un bucket debe vaciarse antes de eliminarlo.')
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
-- LECCIÓN 6 — Repaso: ejemplos y límites (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: ejemplos y límites',
      'Repasamos los **ejemplos de nombrado** y las **restricciones y límites** de los buckets. Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final: S3 Bucket (final · sin preguntas propias)
-- Recicla ~6 tarjetas al azar del tema (ADR 0005, enmienda 2026-06-16).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 2 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto los **buckets de S3**: visión general, reglas de nombrado, ejemplos y límites. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_03_aws-saa-c03.sql
-- =============================================================================
