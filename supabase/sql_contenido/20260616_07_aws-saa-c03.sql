-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 07
-- Archivo: supabase/sql_contenido/20260616_07_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el QUINTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "ETags, Checksums & Prefixes" (position 5) — diapositivas 27-29 del Manual
--       L1 (normal)  ¿Qué es un ETag?                  (slide 27)
--       L2 (normal)  ETags en objetos de S3            (slide 27)
--       L3 (review)  Repaso: ETags
--       L4 (normal)  Checksums                         (slide 28)
--       L5 (normal)  Prefijos de objeto                (slide 29)
--       L6 (review)  Repaso: checksums y prefijos
--       L7 (final)   Lección final: ETags, Checksums & Prefixes
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
-- TEMA: ETags, Checksums & Prefixes  (etapa "Básico" = position 1; tema position 5)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'ETags, Checksums & Prefixes',
       'Características de los objetos de S3: ETags (detección de cambios), checksums (integridad) y prefijos (organización).',
       'Un ETag (entity tag) es una cabecera de respuesta HTTP que representa un recurso que ha cambiado, sin necesidad de descargarlo. Su valor suele generarse con una función de hash (p. ej. MD5 o SHA-1), forma parte del protocolo HTTP y se usa para la revalidación en sistemas de caché. Los objetos de S3 tienen un ETag que representa un hash del objeto: refleja cambios solo en el contenido del objeto (no en sus metadatos), puede ser o no un digest MD5 según si el objeto está cifrado, y representa una versión concreta del objeto. Los ETags son útiles para detectar cambios de contenido de forma programática (p. ej. con aws s3api list-objects). Un checksum se usa para comprobar la integridad de un archivo: si durante la transferencia se pierden o corrompen datos, el checksum lo detecta. Amazon S3 usa checksums para verificar la integridad al subir o descargar; AWS permite cambiar el algoritmo de checksum durante la subida, y ofrece CRC32, CRC32C, SHA1 y SHA256. Los prefijos de objeto son cadenas que preceden al nombre del archivo y forman parte de la clave del objeto (object key). Como todos los objetos se almacenan en una jerarquía plana, los prefijos permiten organizar, agrupar y filtrar objetos; usan la barra "/" como delimitador, similar a carpetas, pero no son carpetas reales. No hay límite en el número de delimitadores; el único límite es que la clave del objeto (prefijo + nombre) no puede superar los 1024 bytes.',
       5,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es un ETag?',
      'Concepto de ETag: cabecera HTTP, hashing y revalidación de caché.', 'normal'),
  (2, 'ETags en objetos de S3',
      'Cómo funcionan los ETags en S3: hash del contenido, cifrado y versiones.', 'normal'),
  (3, 'Repaso: ETags',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Checksums',
      'Integridad de datos al subir y descargar; algoritmos disponibles.', 'normal'),
  (5, 'Prefijos de objeto',
      'Cómo organizan los prefijos los objetos en la jerarquía plana de S3.', 'normal'),
  (6, 'Repaso: checksums y prefijos',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: ETags, Checksums & Prefixes',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es un ETag? (slide 27)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un ETag?',
      E'Un **ETag** (entity tag) es una **cabecera de respuesta HTTP** que **representa un recurso que ha cambiado**, sin necesidad de **descargarlo**.\n\n- Su valor suele generarse con una **función de hash** (p. ej. **MD5** o **SHA-1**).\n- Forma parte del **protocolo HTTP**.\n- Se usa para la **revalidación** en **sistemas de caché**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué es un ETag?',
   'Una cabecera de respuesta HTTP que indica que un recurso ha cambiado',
   'Un algoritmo de cifrado en reposo',
   'Un tipo de bucket de S3',
   'El ETag (entity tag) es una cabecera HTTP que señala cambios sin descargar el recurso.'),
  ('multiple_choice',
   '¿Cómo se genera normalmente el valor de un ETag?',
   'Con una función de hash (p. ej. MD5 o SHA-1)',
   'Con un número aleatorio',
   'Con la fecha de creación del objeto',
   'El valor del ETag suele ser un hash como MD5 o SHA-1.'),
  ('true_false',
   'Los ETags forman parte del protocolo HTTP.',
   'Verdadero', null, null,
   'Los ETags son parte del protocolo HTTP y se usan en revalidación de caché.'),
  ('multiple_choice',
   '¿Para qué se usan los ETags en los sistemas de caché?',
   'Para la revalidación de contenido',
   'Para comprimir los recursos',
   'Para balancear la carga',
   'Los ETags permiten revalidar si el contenido cacheado sigue vigente.'),
  ('text_input',
   'Un ETag permite saber si un recurso ha cambiado sin tener que ____lo (una palabra).',
   'descargar', null, null,
   'La ventaja del ETag es detectar cambios sin descargar el recurso.')
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
-- LECCIÓN 2 — ETags en objetos de S3 (slide 27)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'ETags en S3',
      E'Los objetos de S3 **tienen un ETag** que representa un **hash del objeto**:\n- Refleja cambios **solo en el contenido** del objeto, **no en sus metadatos**.\n- **Puede ser o no** un digest **MD5** según si el objeto está **cifrado**.\n- Representa una **versión concreta** del objeto.'),
  (2, 'Uso práctico',
      E'- Útiles para **detectar cambios de contenido** de forma **programática**.\n- Por ejemplo, con el comando `aws s3api list-objects`.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'El ETag de un objeto de S3 refleja cambios en…',
   'Solo el contenido del objeto, no sus metadatos',
   'El contenido y los metadatos por igual',
   'Solo los metadatos del objeto',
   'El ETag refleja cambios en el contenido, no en los metadatos.'),
  ('true_false',
   'El ETag de un objeto de S3 siempre es un digest MD5.',
   'Falso', null, null,
   'Puede ser o no un MD5; depende de si el objeto está cifrado.'),
  ('multiple_choice',
   '¿Qué representa el ETag respecto a las versiones?',
   'Una versión concreta del objeto',
   'Todas las versiones a la vez',
   'La fecha de caducidad del objeto',
   'El ETag identifica una versión específica del objeto.'),
  ('anki_card',
   '¿Para qué resultan útiles los ETags en S3?',
   'Para detectar cambios de contenido de forma programática (p. ej. aws s3api list-objects).',
   null, null,
   'Permiten comparar hashes y saber si el contenido cambió sin descargarlo.'),
  ('text_input',
   'Que el ETag sea o no un MD5 depende de si el objeto está ____ (una palabra).',
   'cifrado', null, null,
   'Si el objeto está cifrado, el ETag puede no ser un digest MD5.')
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
-- LECCIÓN 3 — Repaso: ETags (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: ETags',
      'Vamos a repasar qué es un **ETag** y cómo funcionan en los **objetos de S3**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Checksums (slide 28)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un checksum?',
      E'Un **checksum** se usa para **comprobar la integridad** de un archivo. Si durante la **transferencia** se **pierden** o **corrompen** datos, el checksum lo **detecta**.\n\nAmazon S3 usa checksums para **verificar la integridad** al **subir** o **descargar** archivos.'),
  (2, 'Algoritmos de checksum',
      E'- AWS permite **cambiar el algoritmo** de checksum **durante la subida** de un objeto.\n- Algoritmos disponibles: **CRC32**, **CRC32C**, **SHA1** y **SHA256**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Para qué sirve un checksum?',
   'Para comprobar la integridad de los datos de un archivo',
   'Para cifrar el archivo en reposo',
   'Para asignar permisos al objeto',
   'El checksum verifica que los datos no se han perdido ni corrompido.'),
  ('true_false',
   'Amazon S3 usa checksums para verificar la integridad al subir y descargar archivos.',
   'Verdadero', null, null,
   'S3 emplea checksums tanto en la subida como en la descarga.'),
  ('multiple_choice',
   '¿Cuándo permite AWS cambiar el algoritmo de checksum?',
   'Durante la subida del objeto',
   'Solo tras borrar el objeto',
   'Nunca; es fijo',
   'El algoritmo de checksum se puede elegir durante la subida.'),
  ('multiple_choice',
   '¿Cuál de estos es un algoritmo de checksum que ofrece S3?',
   'CRC32C',
   'AES-256',
   'RSA-2048',
   'S3 ofrece CRC32, CRC32C, SHA1 y SHA256 (AES y RSA son de cifrado).'),
  ('anki_card',
   'Enumera los algoritmos de checksum que ofrece Amazon S3.',
   'CRC32, CRC32C, SHA1 y SHA256.',
   null, null,
   'Estos son los cuatro algoritmos de checksum disponibles en S3.'),
  ('true_false',
   'Un checksum puede detectar si los datos se corrompieron en tránsito.',
   'Verdadero', null, null,
   'Si los datos se pierden o se alteran en la transferencia, el checksum lo detecta.')
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
-- LECCIÓN 5 — Prefijos de objeto (slide 29)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un prefijo?',
      E'Los **prefijos de objeto** son **cadenas que preceden** al nombre del archivo y forman parte de la **clave del objeto** (object key name).\n\nEjemplo: en `/assets/images/andrew.png`, `/assets/images/` es el **prefijo** y `andrew.png` el **nombre del archivo**.'),
  (2, 'Organización y límites',
      E'- Como todos los objetos se almacenan en una **jerarquía plana**, los prefijos permiten **organizar**, **agrupar** y **filtrar** objetos.\n- Usan la **barra "/"** como **delimitador**, similar a carpetas/subcarpetas, pero **no son carpetas reales**.\n- **No hay límite** en el número de delimitadores; el único límite es que la **clave del objeto** (prefijo + nombre) **no puede superar 1024 bytes**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué es un prefijo de objeto?',
   'Una cadena que precede al nombre del archivo y forma parte de la clave del objeto',
   'El sufijo del nombre del bucket',
   'Una etiqueta de cifrado',
   'El prefijo precede al nombre del archivo dentro de la clave del objeto.'),
  ('true_false',
   'Los prefijos de objeto son carpetas reales en S3.',
   'Falso', null, null,
   'Los prefijos simulan carpetas usando "/", pero no son carpetas reales.'),
  ('multiple_choice',
   '¿Qué carácter se usa como delimitador en los prefijos?',
   'La barra "/"',
   'El guion "-"',
   'El punto "."',
   'La barra "/" agrupa los objetos de forma similar a directorios.'),
  ('multiple_choice',
   '¿Para qué sirven los prefijos en una jerarquía plana?',
   'Para organizar, agrupar y filtrar objetos',
   'Para cifrar los objetos',
   'Para versionar los objetos',
   'Los prefijos aportan organización dentro de la estructura plana de S3.'),
  ('text_input',
   '¿Cuántos bytes como máximo puede tener la clave del objeto (prefijo + nombre)? (un número)',
   '1024', null, null,
   'La clave del objeto no puede superar los 1024 bytes.'),
  ('anki_card',
   '¿Hay límite en el número de delimitadores "/" en un prefijo?',
   'No; el único límite es que la clave del objeto no supere 1024 bytes.',
   null, null,
   'Puedes usar tantos "/" como quieras mientras la clave no pase de 1024 bytes.')
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
-- LECCIÓN 6 — Repaso: checksums y prefijos (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: checksums y prefijos',
      'Repasamos los **checksums** (integridad y algoritmos) y los **prefijos** (organización y límites). Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final: ETags, Checksums & Prefixes (final · sin preguntas)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 5 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto los **ETags** (detección de cambios), los **checksums** (integridad) y los **prefijos** (organización) de los objetos de S3. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_07_aws-saa-c03.sql
-- =============================================================================
