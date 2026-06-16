-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 06
-- Archivo: supabase/sql_contenido/20260616_06_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el CUARTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Object Overview" (position 4) — basado en la diapositiva 26 del Manual
--       L1 (normal)  Qué es un objeto · ETags · Checksums      (slide 26)
--       L2 (normal)  Prefijos · Metadatos · Tags              (slide 26)
--       L3 (normal)  Object Locking · Versioning              (slide 26)
--       L4 (review)  Repaso: características de los objetos
--       L5 (final)   Lección final: S3 Object Overview
--   Volumen: POCO -> estructura normal·normal·normal·review·final (5 lecciones).
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
-- TEMA: S3 Object Overview  (etapa "Básico" = position 1; tema position 4)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Object Overview',
       'Qué son los objetos de S3 y sus características principales: ETags, checksums, prefijos, metadatos, tags, bloqueo y versionado.',
       'Los objetos de S3 son recursos que representan datos; no son infraestructura (la infraestructura es el bucket). Cada objeto tiene varias características. Los ETags permiten detectar cuándo ha cambiado el contenido de un objeto sin necesidad de descargarlo. Los checksums garantizan la integridad de un archivo al subirlo o descargarlo. Los prefijos de objeto simulan las carpetas de un sistema de archivos dentro de la jerarquía plana de S3. Los metadatos de objeto adjuntan datos junto al contenido para describirlo. Las tags de objeto aportan los beneficios del etiquetado de recursos pero a nivel de objeto. El bloqueo de objetos (Object Locking) hace que los archivos de datos sean inmutables. El versionado de objetos (Object Versioning) permite mantener varias versiones de un mismo archivo de datos.',
       4,
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
-- LECCIONES (5) — volumen POCO: normal·normal·normal·review·final
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Objetos, ETags y checksums',
      'Qué es un objeto de S3 y cómo se detecta el cambio (ETags) y se garantiza la integridad (checksums).', 'normal'),
  (2, 'Prefijos, metadatos y tags',
      'Cómo se simulan carpetas, se describen y se etiquetan los objetos.', 'normal'),
  (3, 'Bloqueo y versionado de objetos',
      'Inmutabilidad con Object Locking y múltiples versiones con Object Versioning.', 'normal'),
  (4, 'Repaso: características de los objetos',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Object Overview',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Objetos, ETags y checksums (slide 26)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un objeto de S3?',
      E'Los **objetos** de S3 son **recursos** que **representan datos**; **no son infraestructura** (la infraestructura es el **bucket**).\n\nCada objeto tiene varias **características** que veremos en este tema.'),
  (2, 'ETags y checksums',
      E'- **ETags**: permiten **detectar cuándo ha cambiado** el contenido de un objeto **sin descargarlo**.\n- **Checksums**: **garantizan la integridad** de un archivo al **subirlo** o **descargarlo**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('true_false',
   'Los objetos de S3 son infraestructura, igual que los buckets.',
   'Falso', null, null,
   'Los objetos son recursos que representan datos; la infraestructura es el bucket.'),
  ('multiple_choice',
   '¿Para qué sirven los ETags?',
   'Detectar cuándo ha cambiado el contenido de un objeto sin descargarlo',
   'Cifrar el contenido del objeto en reposo',
   'Reducir el coste de almacenamiento',
   'Un ETag permite saber si el contenido cambió sin tener que descargarlo.'),
  ('multiple_choice',
   '¿Qué garantizan los checksums?',
   'La integridad del archivo al subirlo o descargarlo',
   'La unicidad del nombre del bucket',
   'La versión más reciente del objeto',
   'Los checksums aseguran que el archivo no se ha corrompido en la transferencia.'),
  ('anki_card',
   '¿Qué es un objeto de S3?',
   'Un recurso que representa datos (no es infraestructura; eso es el bucket).',
   null, null,
   'Los objetos representan datos; el bucket es la infraestructura que los contiene.'),
  ('text_input',
   '¿Qué característica permite detectar cambios sin descargar el objeto? (una palabra)',
   'ETag', null, null,
   'El ETag detecta cambios en el contenido sin necesidad de descargarlo.')
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
-- LECCIÓN 2 — Prefijos, metadatos y tags (slide 26)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Prefijos, metadatos y tags',
      E'- **Prefijos de objeto**: **simulan las carpetas** de un sistema de archivos dentro de la **jerarquía plana** de S3.\n- **Metadatos de objeto**: **adjuntan datos** junto al contenido para **describirlo**.\n- **Tags de objeto**: aportan los beneficios del **etiquetado de recursos**, pero a **nivel de objeto**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué hacen los prefijos de objeto?',
   'Simulan carpetas de un sistema de archivos en la jerarquía plana de S3',
   'Cifran el objeto en tránsito',
   'Crean copias de seguridad automáticas',
   'Los prefijos simulan carpetas dentro de la jerarquía plana de S3.'),
  ('multiple_choice',
   '¿Para qué sirven los metadatos de objeto?',
   'Adjuntar datos junto al contenido para describirlo',
   'Eliminar versiones antiguas del objeto',
   'Acelerar las descargas',
   'Los metadatos describen el contenido y se adjuntan junto al objeto.'),
  ('true_false',
   'Las tags de objeto llevan el etiquetado de recursos al nivel de objeto.',
   'Verdadero', null, null,
   'Las tags aportan los beneficios del etiquetado de recursos a nivel de objeto.'),
  ('anki_card',
   '¿Qué característica simula las carpetas de un sistema de archivos en S3?',
   'Los prefijos de objeto.',
   null, null,
   'Los prefijos simulan carpetas dentro de la jerarquía plana de S3.'),
  ('text_input',
   '¿Qué se adjunta junto al contenido para describir un objeto? (una palabra)',
   'metadatos', null, null,
   'Los metadatos describen el contenido y se adjuntan junto al objeto.')
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
-- LECCIÓN 3 — Bloqueo y versionado de objetos (slide 26)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Bloqueo y versionado',
      E'- **Object Locking** (bloqueo de objetos): hace que los archivos de datos sean **inmutables**.\n- **Object Versioning** (versionado de objetos): permite mantener **varias versiones** de un mismo archivo de datos.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué hace Object Locking?',
   'Hace que los archivos de datos sean inmutables',
   'Crea varias versiones del archivo',
   'Comprime el archivo para ahorrar espacio',
   'El bloqueo de objetos hace los archivos inmutables (no se pueden modificar/borrar).'),
  ('multiple_choice',
   '¿Qué permite Object Versioning?',
   'Mantener varias versiones de un mismo archivo',
   'Hacer el archivo inmutable',
   'Detectar cambios sin descargar el objeto',
   'El versionado permite conservar múltiples versiones de un mismo objeto.'),
  ('true_false',
   'Object Locking permite tener varias versiones de un archivo.',
   'Falso', null, null,
   'Eso es el versionado; el bloqueo hace los archivos inmutables.'),
  ('anki_card',
   '¿Qué característica hace inmutables los archivos de datos?',
   'Object Locking (bloqueo de objetos).',
   null, null,
   'Object Locking impide modificar o borrar los datos durante el bloqueo.'),
  ('text_input',
   '¿Qué característica permite mantener múltiples versiones de un archivo? (una palabra)',
   'versionado', null, null,
   'Object Versioning (versionado) conserva varias versiones del mismo objeto.')
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
-- LECCIÓN 4 — Repaso: características de los objetos (review · sin preguntas propias)
-- Las tarjetas se reciclan en runtime de las lecciones anteriores (ADR 0005).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: características de los objetos',
      'Vamos a repasar las **características de los objetos** de S3: ETags, checksums, prefijos, metadatos, tags, bloqueo y versionado. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: S3 Object Overview (final · sin preguntas propias)
-- Recicla ~6 tarjetas al azar del tema (ADR 0005, enmienda 2026-06-16).
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 4 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto el **panorama de los objetos** de S3: ETags, checksums, prefijos, metadatos, tags, bloqueo y versionado. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_06_aws-saa-c03.sql
-- =============================================================================
