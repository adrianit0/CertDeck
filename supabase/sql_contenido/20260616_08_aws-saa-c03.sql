-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 08
-- Archivo: supabase/sql_contenido/20260616_08_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el SEXTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Object Metadata" (position 6) — diapositivas 30-32 del Manual
--       L1 (normal)  ¿Qué es la metadata?                        (slide 30)
--       L2 (normal)  Metadata definida por el sistema            (slide 31)
--       L3 (normal)  Metadata definida por el usuario            (slide 32)
--       L4 (review)  Repaso: metadata de objetos
--       L5 (final)   Lección final: S3 Object Metadata
--   Volumen: POCO -> normal·normal·normal·review·final (5 lecciones).
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
-- TEMA: S3 Object Metadata  (etapa "Básico" = position 1; tema position 6)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Object Metadata',
       'Metadata de los objetos de S3: qué es, la metadata definida por el sistema y la definida por el usuario.',
       'La metadata proporciona información sobre otros datos, pero no su contenido en sí. Es útil para categorizar y organizar datos y para aportar contexto sobre ellos. Amazon S3 permite adjuntar metadata a los objetos en cualquier momento. Conviene distinguirla de las tags: las resource tags y object tags se parecen a la metadata, pero las tags están pensadas para dar información sobre recursos en la nube (p. ej. objetos de S3), no sobre el contenido del objeto. La metadata puede ser de dos tipos. La metadata definida por el sistema (system defined) es la que controla Amazon; normalmente el usuario no puede establecer sus valores, aunque algunos sí (p. ej. Content-Type). Ejemplos: Content-Type, Cache-Control, Content-Disposition, Content-Encoding, Content-Language, Expires y x-amz-website-redirection-location. AWS adjunta parte de esta metadata aunque no especifiques ninguna, y existe más de la listada (p. ej. los ETags). La metadata definida por el usuario (user defined) la establece el usuario y debe empezar con el prefijo x-amz-meta-; permite usos como cumplimiento y legal, copia de seguridad y archivado, contenido, acceso y seguridad, datos de proyecto, aplicaciones personalizadas, archivos multimedia y versionado de documentos.',
       6,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es la metadata?',
      'Concepto de metadata, sus usos y diferencia con las tags.', 'normal'),
  (2, 'Metadata definida por el sistema',
      'La metadata que controla Amazon: ejemplos y matices.', 'normal'),
  (3, 'Metadata definida por el usuario',
      'La metadata que define el usuario con el prefijo x-amz-meta-.', 'normal'),
  (4, 'Repaso: metadata de objetos',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Object Metadata',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es la metadata? (slide 30)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es la metadata?',
      E'La **metadata** proporciona **información sobre otros datos**, pero **no su contenido** en sí. Es útil para:\n- **Categorizar y organizar** datos.\n- **Aportar contexto** sobre los datos.\n\nAmazon S3 permite **adjuntar metadata** a los objetos en **cualquier momento**. Puede ser **definida por el sistema** o **definida por el usuario**.'),
  (2, 'Metadata frente a tags',
      E'Las **resource tags** y **object tags** se parecen a la metadata, pero las **tags** están pensadas para dar información sobre los **recursos** en la nube (p. ej. objetos de S3), **no sobre el contenido** del objeto.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué es la metadata?',
   'Información sobre otros datos, pero no su contenido en sí',
   'El contenido binario del propio objeto',
   'Un algoritmo de cifrado',
   'La metadata describe los datos; no es el contenido en sí.'),
  ('multiple_choice',
   '¿Para qué es útil la metadata?',
   'Para categorizar, organizar y aportar contexto a los datos',
   'Para comprimir los objetos',
   'Para balancear la carga de red',
   'La metadata ayuda a categorizar, organizar y contextualizar los datos.'),
  ('true_false',
   'Amazon S3 permite adjuntar metadata a los objetos en cualquier momento.',
   'Verdadero', null, null,
   'Puedes adjuntar metadata a los objetos de S3 en cualquier momento.'),
  ('multiple_choice',
   '¿En qué se diferencian las tags de la metadata?',
   'Las tags informan sobre el recurso, no sobre el contenido del objeto',
   'Las tags cifran el objeto',
   'Las tags solo existen en buckets de directorio',
   'Las tags describen el recurso en la nube; la metadata, los datos.'),
  ('anki_card',
   '¿Cuáles son los dos tipos de metadata en S3?',
   'Definida por el sistema (system defined) y definida por el usuario (user defined).',
   null, null,
   'La metadata de S3 puede ser del sistema o del usuario.')
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
-- LECCIÓN 2 — Metadata definida por el sistema (slide 31)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Metadata del sistema',
      E'La **metadata definida por el sistema** es la que **solo Amazon controla**. Normalmente el usuario **no puede** establecer sus valores.\n- AWS **adjunta** parte de esta metadata **aunque no especifiques ninguna**.\n- **Algunos** valores **sí** se pueden modificar (p. ej. **Content-Type**).\n- Existe **más** metadata de la listada (p. ej. los **ETags**).'),
  (2, 'Ejemplos de metadata del sistema',
      E'- **Content-Type**: image/jpeg\n- **Cache-Control**: max-age=3600, must-revalidate\n- **Content-Disposition**: attachment; filename="example.pdf"\n- **Content-Encoding**: gzip\n- **Content-Language**: en-US\n- **Expires**: Thu, 01 Dec 2030 16:00:00 GMT\n- **x-amz-website-redirection-location**: /new-page.html')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Quién controla la metadata definida por el sistema?',
   'Solo Amazon',
   'Solo el usuario',
   'Cualquier cuenta de la misma partición',
   'La metadata del sistema la controla Amazon; el usuario normalmente no la fija.'),
  ('true_false',
   'AWS adjunta parte de la metadata del sistema aunque no especifiques ninguna.',
   'Verdadero', null, null,
   'AWS añade automáticamente cierta metadata del sistema.'),
  ('multiple_choice',
   '¿Cuál de estas es metadata definida por el sistema que el usuario SÍ puede modificar?',
   'Content-Type',
   'x-amz-meta-author',
   'x-amz-meta-project-id',
   'Algunos valores como Content-Type sí los puede modificar el usuario.'),
  ('multiple_choice',
   '¿Cuál de estos es un ejemplo de metadata del sistema?',
   'Cache-Control',
   'x-amz-meta-department',
   'x-amz-meta-legal-hold',
   'Cache-Control es del sistema; las x-amz-meta- son del usuario.'),
  ('anki_card',
   'Además de los ejemplos listados, ¿qué otra metadata del sistema existe?',
   'Hay más, por ejemplo los ETags.',
   null, null,
   'La lista no es exhaustiva; los ETags también son metadata del sistema.')
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
-- LECCIÓN 3 — Metadata definida por el usuario (slide 32)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Metadata del usuario',
      E'La **metadata definida por el usuario** la **establece el usuario** y **debe empezar** con el prefijo **`x-amz-meta-`**.\n\nPermite añadir información propia a cada objeto según las necesidades de tu organización.'),
  (2, 'Ejemplos de usos',
      E'- **Cumplimiento y legal**: `x-amz-meta-legal-hold: "true"`, `x-amz-meta-compliance-category: "GDPR"`, `x-amz-meta-retention-period: "5 years"`.\n- **Copia de seguridad y archivado**: `x-amz-meta-backup-status`, `x-amz-meta-archive-date`.\n- **Acceso y seguridad**: `x-amz-meta-encryption: "AES-256"`, `x-amz-meta-access-level: "confidential"`.\n- **Proyecto**: `x-amz-meta-project-id`, `x-amz-meta-department`.\n- **Multimedia**: `x-amz-meta-camera-model`, `x-amz-meta-location`.\n- **Versionado de documentos**: `x-amz-meta-version`, `x-amz-meta-last-modified-by`.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Con qué prefijo debe empezar la metadata definida por el usuario?',
   'x-amz-meta-',
   'x-amz-system-',
   'meta-user-',
   'Toda la metadata del usuario debe empezar con x-amz-meta-.'),
  ('true_false',
   'La metadata definida por el usuario la establece el propio usuario.',
   'Verdadero', null, null,
   'A diferencia de la del sistema, la metadata de usuario la define el usuario.'),
  ('text_input',
   'Prefijo obligatorio de la metadata de usuario (escríbelo tal cual, una palabra).',
   'x-amz-meta-', null, null,
   'La clave de la metadata de usuario debe comenzar con x-amz-meta-.'),
  ('multiple_choice',
   '¿Cuál de estas sería metadata definida por el usuario?',
   'x-amz-meta-project-id: "PRJ12345"',
   'Content-Type: image/jpeg',
   'Cache-Control: max-age=3600',
   'Las claves x-amz-meta- son del usuario; Content-Type y Cache-Control son del sistema.'),
  ('anki_card',
   'Da un ejemplo de uso de la metadata de usuario para cumplimiento legal.',
   'Por ejemplo x-amz-meta-legal-hold: "true" o x-amz-meta-compliance-category: "GDPR".',
   null, null,
   'La metadata de usuario sirve para cumplimiento, archivado, seguridad, proyectos, etc.')
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
-- LECCIÓN 4 — Repaso: metadata de objetos (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: metadata de objetos',
      'Vamos a repasar qué es la **metadata**, la **definida por el sistema** y la **definida por el usuario**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: S3 Object Metadata (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 6 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto la **metadata** de los objetos de S3: qué es, la **definida por el sistema** y la **definida por el usuario** (`x-amz-meta-`). Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_08_aws-saa-c03.sql
-- =============================================================================
