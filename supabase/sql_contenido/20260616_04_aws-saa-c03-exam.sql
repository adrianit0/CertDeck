-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 04 (EXAMEN)
-- Archivo: supabase/sql_contenido/20260616_04_aws-saa-c03-exam.sql
-- Fecha: 2026-06-16
--
-- Primer lote de PREGUNTAS DE EXAMEN (v3 · RF-24…29) para la práctica directa.
-- Catálogo `certdeck_exam_questions` (independiente de las flashcards):
--   type_id = 1 -> respuesta única   (correcta = answer_1)
--   type_id = 2 -> respuesta múltiple (correctas = primeras correct_answers_count)
-- El frontend SIEMPRE desordena las respuestas (RF-28); aquí answer_1.. se
-- guardan con las correctas primero.
--
-- Temas de la etapa "Básico" (stage position 1):
--   - "Introduction to S3" (topic position 1)
--   - "S3 Bucket"          (topic position 2)
--
-- Dependencias: script-001.sql + script-002.sql aplicados y 20260515_01/02 +
-- 20260616_03 (curso + etapa + temas) aplicados.
-- Idempotente: cada INSERT se guarda con NOT EXISTS sobre (course_id, question)
-- porque la tabla no tiene clave natural. NO ejecutado por el agente (§4).
-- =============================================================================

-- Helper conceptual: resolvemos course_id y topic_id por slug/posición en cada
-- INSERT … SELECT … WHERE NOT EXISTS.

-- 1) Única · Introduction to S3 · dificultad 3
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  '¿En qué nivel del modelo de Amazon S3 se define la región donde residen físicamente los datos?',
  1,
  'En el bucket (cada bucket se crea en una región concreta)',
  'En cada objeto de forma individual',
  'En la cuenta de AWS de forma global',
  'En la política IAM asociada',
  1,
  'S3 es un servicio global por espacio de nombres, pero cada bucket se aloja en una región específica que elige el usuario al crearlo.',
  3, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 1
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = '¿En qué nivel del modelo de Amazon S3 se define la región donde residen físicamente los datos?'
  );

-- 2) Múltiple · S3 Bucket (nombrado) · dificultad 4
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, answer_5, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  'Selecciona TODAS las reglas válidas de nombrado de un bucket de S3.',
  2,
  'Entre 3 y 63 caracteres',
  'Solo minúsculas, números, puntos y guiones',
  'Debe empezar y terminar con letra o número',
  'Puede contener mayúsculas y guiones bajos',
  'Puede tener formato de dirección IP (p. ej. 192.168.0.1)',
  3,
  'Los nombres de bucket: 3–63 caracteres; solo minúsculas, dígitos, "." y "-"; empiezan/terminan con letra o número. NO admiten mayúsculas, guiones bajos, espacios ni formato de IP.',
  4, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 2
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = 'Selecciona TODAS las reglas válidas de nombrado de un bucket de S3.'
  );

-- 3) Única · S3 Bucket (límites) · dificultad 3
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  '¿Cuál es el número de buckets por cuenta que AWS permite por defecto (ampliable por solicitud)?',
  1,
  '100 buckets (ampliable hasta 1000)',
  '10 buckets (ampliable hasta 100)',
  '1000 buckets (no ampliable)',
  'Ilimitado desde el inicio',
  1,
  'Por defecto son 100 buckets por cuenta; mediante una solicitud de servicio puede ampliarse hasta 1000.',
  3, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 2
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = '¿Cuál es el número de buckets por cuenta que AWS permite por defecto (ampliable por solicitud)?'
  );

-- 4) Única · S3 Bucket (objetos) · dificultad 2
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  '¿Cuál es el tamaño máximo de un único objeto almacenado en S3?',
  1,
  '5 TB',
  '5 GB',
  '100 MB',
  'No hay límite',
  1,
  'Un objeto mide de 0 a 5 TB. Los archivos mayores de 100 MB deberían subirse con multipart upload.',
  2, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 2
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = '¿Cuál es el tamaño máximo de un único objeto almacenado en S3?'
  );

-- 5) Múltiple · S3 Bucket (borrado/multipart) · dificultad 4
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  'Marca TODAS las afirmaciones correctas sobre los límites y la gestión de un bucket.',
  2,
  'Hay que vaciar un bucket antes de poder borrarlo',
  'No existe un límite en el número de objetos de un bucket',
  'Los objetos mayores de 100 MB deberían subirse con multipart upload',
  'Cada bucket tiene un tamaño máximo de 5 TB',
  3,
  'Un bucket debe vaciarse antes de borrarse; no hay límite de objetos ni tamaño máximo de bucket; multipart upload se recomienda a partir de 100 MB.',
  4, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 2
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = 'Marca TODAS las afirmaciones correctas sobre los límites y la gestión de un bucket.'
  );

-- 6) Única · Introduction to S3 · dificultad 2
insert into public.certdeck_exam_questions
  (course_id, topic_id, question, type_id, answer_1, answer_2, answer_3, answer_4, correct_answers_count, extra_information, difficulty, is_active)
select c.id, tp.id,
  '¿Qué tipo de almacenamiento ofrece principalmente Amazon S3?',
  1,
  'Almacenamiento de objetos',
  'Almacenamiento de bloques',
  'Almacenamiento de ficheros NFS',
  'Base de datos relacional',
  1,
  'S3 es un servicio de almacenamiento de objetos; EBS ofrece bloques y EFS ofrece ficheros.',
  2, true
from public.certdeck_courses c
join public.certdeck_stages s on s.course_id = c.id and s.position = 1
join public.certdeck_topics tp on tp.stage_id = s.id and tp.position = 1
where c.slug = 'aws-saa-c03'
  and not exists (
    select 1 from public.certdeck_exam_questions q
    where q.course_id = c.id
      and q.question = '¿Qué tipo de almacenamiento ofrece principalmente Amazon S3?'
  );

-- =============================================================================
-- Fin de fragmento 04 (examen).
-- =============================================================================
