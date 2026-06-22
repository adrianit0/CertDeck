-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 23
-- Archivo: supabase/sql_contenido/20260622_23_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el VIGÉSIMO PRIMER TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Comparativa" (position 21) — diapositiva 54
--       L1 (normal)  Durabilidad y disponibilidad      (slide 54)
--       L2 (normal)  AZs y latencia de primer byte      (slide 54)
--       L3 (review)  Repaso: garantías y latencia
--       L4 (normal)  Cargos: duración mínima y recuperación (slide 54)
--       L5 (normal)  Notas especiales y compromiso      (slide 54)
--       L6 (review)  Repaso: cargos y notas
--       L7 (final)   Lección final: Comparativa de Storage Classes
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
-- TEMA: S3 Storage Classes - Comparativa  (position 21)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Comparativa',
       'Tabla comparativa de las 8 clases de almacenamiento de S3: durabilidad, disponibilidad, AZs, cargos mínimos, tarifas de recuperación y latencia de primer byte.',
       'Comparativa de las 8 clases de almacenamiento de S3 (Express One Zone, Standard, Intelligent-Tiering, Standard-IA, One-Zone-IA, Glacier Instant Retrieval, Glacier Flexible Retrieval y Glacier Deep Archive). Durabilidad: todas ofrecen 11 nueves. Disponibilidad: Standard 99,99%, Express One Zone 99,95%, Intelligent-Tiering / Standard-IA / Glacier Instant 99,9%, One-Zone-IA 99,5%, y Glacier Flexible y Deep Archive N/A. Zonas de disponibilidad (AZs): Express One Zone y One-Zone-IA usan 1 AZ; el resto usa más de 3 AZs. Cargo mínimo de capacidad por objeto: Standard-IA y One-Zone-IA 128 KB; Glacier Flexible y Deep Archive 40 KB; el resto N/A. Cargo mínimo de duración de almacenamiento: Standard, Express e Intelligent-Tiering N/A; Standard-IA y One-Zone-IA 30 días; Glacier Instant y Glacier Flexible 90 días; Deep Archive 180 días. Tarifa de recuperación (por GB): Standard, Express e Intelligent-Tiering no tienen; Standard-IA, One-Zone-IA, Glacier Instant, Flexible y Deep Archive sí (per GB). Latencia de primer byte: Express One Zone milisegundos de un solo dígito; Standard, Intelligent, Standard-IA, One-Zone-IA y Glacier Instant milisegundos; Glacier Flexible de minutos a horas; Deep Archive horas. Notas: Intelligent-Tiering tiene un coste de monitoreo adicional, y Express One Zone aplica un cargo adicional para peticiones de archivos mayores de 512 KB.',
       21,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'Durabilidad y disponibilidad',
      'Todas con 11 nueves; la disponibilidad sí varía entre clases.', 'normal'),
  (2, 'AZs y latencia de primer byte',
      'Cuántas AZs usa cada clase y cómo de rápido entrega el primer byte.', 'normal'),
  (3, 'Repaso: garantías y latencia',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Cargos: duración mínima y recuperación',
      'Duración mínima de almacenamiento, tarifa de recuperación y mínimo por objeto.', 'normal'),
  (5, 'Notas especiales y compromiso',
      'Monitoreo de Intelligent-Tiering, cargo >512 KB de Express y la idea global.', 'normal'),
  (6, 'Repaso: cargos y notas',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: Comparativa de Storage Classes',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — Durabilidad y disponibilidad (slide 54)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Durabilidad: todas igual',
      E'**Las 8 clases** de almacenamiento de S3 ofrecen la **misma durabilidad**: **11 nueves**.\n\nLa durabilidad **no** es lo que las diferencia: lo que cambia es **disponibilidad**, **AZs**, **latencia** y **cargos**.'),
  (2, 'Disponibilidad: sí varía',
      E'- **Standard**: **99,99%** (la más alta).\n- **Express One Zone**: **99,95%**.\n- **Intelligent-Tiering**, **Standard-IA**, **Glacier Instant**: **99,9%**.\n- **One-Zone-IA**: **99,5%** (la más baja con valor).\n- **Glacier Flexible** y **Deep Archive**: **N/A**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos "nueves" de durabilidad ofrecen TODAS las clases de S3? (un número)',
   '11', null, null,
   'Las 8 clases comparten 11 nueves de durabilidad.'),
  ('multiple_choice',
   '¿Qué clase tiene la mayor disponibilidad?',
   'S3 Standard (99,99%)',
   'S3 One-Zone-IA (99,5%)',
   'S3 Express One Zone (99,95%)',
   'Standard lidera la disponibilidad con 99,99%.'),
  ('multiple_choice',
   '¿Cuál es la disponibilidad de One-Zone-IA?',
   '99,5%',
   '99,99%',
   '99,9%',
   'One-Zone-IA tiene la disponibilidad más baja con valor: 99,5%.'),
  ('multiple_choice',
   '¿Qué clases muestran disponibilidad "N/A" en la comparativa?',
   'Glacier Flexible Retrieval y Glacier Deep Archive',
   'Standard y Express One Zone',
   'Standard-IA y One-Zone-IA',
   'Flexible y Deep Archive figuran como N/A en disponibilidad.'),
  ('true_false',
   'La durabilidad es lo que diferencia a unas clases de otras.',
   'Falso', null, null,
   'Todas tienen 11 nueves; lo que varía es disponibilidad, AZs, latencia y cargos.'),
  ('multiple_choice',
   '¿Qué disponibilidad comparten Intelligent-Tiering, Standard-IA y Glacier Instant?',
   '99,9%',
   '99,99%',
   '99,5%',
   'Las tres figuran con 99,9% de disponibilidad.')
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
-- LECCIÓN 2 — AZs y latencia de primer byte (slide 54)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Zonas de disponibilidad (AZs)',
      E'- **1 AZ**: **Express One Zone** y **One-Zone-IA** (las "one zone").\n- **Más de 3 AZs (>3)**: todas las demás (Standard, Intelligent-Tiering, Standard-IA, Glacier Instant, Flexible y Deep Archive).'),
  (2, 'Latencia de primer byte',
      E'- **Express One Zone**: **milisegundos de un solo dígito** (single-digit ms).\n- **Standard**, **Intelligent-Tiering**, **Standard-IA**, **One-Zone-IA**, **Glacier Instant**: **milisegundos (ms)**.\n- **Glacier Flexible**: de **minutos a horas**.\n- **Glacier Deep Archive**: **horas**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué dos clases almacenan en una sola AZ?',
   'Express One Zone y One-Zone-IA',
   'Standard y Standard-IA',
   'Glacier Flexible y Deep Archive',
   'Las clases "one zone" (Express One Zone y One-Zone-IA) usan 1 AZ.'),
  ('multiple_choice',
   '¿Cuántas AZs usan las clases que no son "one zone"?',
   'Más de 3 (>3)',
   'Exactamente 2',
   'Solo 1',
   'El resto de clases replica en más de 3 AZs.'),
  ('multiple_choice',
   '¿Qué clase ofrece latencia de primer byte de milisegundos de un solo dígito?',
   'Express One Zone',
   'Glacier Flexible Retrieval',
   'Glacier Deep Archive',
   'Express One Zone es la de menor latencia: single-digit ms.'),
  ('multiple_choice',
   '¿Cuál es la latencia de primer byte de Glacier Deep Archive?',
   'Horas',
   'Milisegundos',
   'Minutos a horas',
   'Deep Archive entrega el primer byte en horas, la más lenta.'),
  ('multiple_choice',
   '¿Qué clase tiene latencia de primer byte de "minutos a horas"?',
   'Glacier Flexible Retrieval',
   'Glacier Instant Retrieval',
   'Standard-IA',
   'Flexible Retrieval entrega en minutos a horas; Deep Archive en horas.'),
  ('true_false',
   'Glacier Instant Retrieval tiene latencia de primer byte de milisegundos, como Standard.',
   'Verdadero', null, null,
   'Pese a ser archivo, Glacier Instant entrega el primer byte en milisegundos.')
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
-- LECCIÓN 3 — Repaso: garantías y latencia (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: garantías y latencia',
      'Repasamos que **todas** comparten **11 nueves** de durabilidad, que la **disponibilidad** varía (Standard **99,99%** → One-Zone-IA **99,5%**), que **Express One Zone** y **One-Zone-IA** usan **1 AZ** (el resto **>3**) y la **latencia de primer byte** (de **single-digit ms** a **horas**). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Cargos: duración mínima y recuperación (slide 54)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Duración mínima de almacenamiento',
      E'- **N/A** (sin mínimo): **Standard**, **Express One Zone**, **Intelligent-Tiering**.\n- **30 días**: **Standard-IA** y **One-Zone-IA**.\n- **90 días**: **Glacier Instant** y **Glacier Flexible**.\n- **180 días**: **Glacier Deep Archive**.'),
  (2, 'Recuperación y mínimo por objeto',
      E'**Tarifa de recuperación (por GB)**:\n- **Sin tarifa**: Standard, Express One Zone, Intelligent-Tiering.\n- **Per GB**: Standard-IA, One-Zone-IA, Glacier Instant, Flexible y Deep Archive.\n\n**Cargo mínimo de capacidad por objeto**:\n- **128 KB**: Standard-IA y One-Zone-IA.\n- **40 KB**: Glacier Flexible y Deep Archive.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos días de duración mínima de almacenamiento tiene Glacier Deep Archive? (un número)',
   '180', null, null,
   'Deep Archive exige el mínimo más largo: 180 días.'),
  ('multiple_choice',
   '¿Qué clases NO tienen cargo mínimo de duración de almacenamiento?',
   'Standard, Express One Zone e Intelligent-Tiering',
   'Standard-IA y One-Zone-IA',
   'Glacier Instant y Glacier Flexible',
   'Standard, Express e Intelligent-Tiering figuran como N/A en duración mínima.'),
  ('multiple_choice',
   '¿Qué duración mínima comparten Glacier Instant y Glacier Flexible?',
   '90 días',
   '30 días',
   '180 días',
   'Ambas tienen un mínimo de 90 días de almacenamiento.'),
  ('multiple_choice',
   '¿Qué clases tienen un cargo mínimo de capacidad por objeto de 128 KB?',
   'Standard-IA y One-Zone-IA',
   'Glacier Flexible y Deep Archive',
   'Standard y Express One Zone',
   'Las clases IA aplican un mínimo de 128 KB por objeto.'),
  ('multiple_choice',
   '¿Qué clases NO tienen tarifa de recuperación?',
   'Standard, Express One Zone e Intelligent-Tiering',
   'Standard-IA, One-Zone-IA y Glacier Instant',
   'Glacier Flexible y Deep Archive',
   'Solo las clases IA y Glacier cobran recuperación (per GB); las otras no.'),
  ('true_false',
   'Glacier Flexible y Deep Archive tienen un cargo mínimo de capacidad por objeto de 40 KB.',
   'Verdadero', null, null,
   'Las dos clases Glacier basadas en Vault aplican 40 KB por objeto.')
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
-- LECCIÓN 5 — Notas especiales y compromiso (slide 54)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Dos notas a recordar',
      E'- **Intelligent-Tiering**: tiene un **coste de monitoreo adicional**.\n- **Express One Zone**: aplica un **cargo adicional** para peticiones de archivos **mayores de 512 KB**.'),
  (2, 'La idea global de la comparativa',
      E'Todas las clases parten de la **misma durabilidad** (11 nueves). A partir de ahí, **bajar el coste** suele implicar **peor**: **disponibilidad**, **número de AZs**, **latencia** de recuperación o **más cargos** (duración mínima, recuperación). Elige según **frecuencia de acceso**, **urgencia** de recuperación y **durabilidad/disponibilidad** que necesites.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué clase tiene un coste de monitoreo adicional?',
   'Intelligent-Tiering',
   'Standard',
   'Glacier Deep Archive',
   'Intelligent-Tiering cobra el monitoreo por mover objetos entre tiers.'),
  ('text_input',
   'Express One Zone aplica un cargo adicional para peticiones de archivos mayores de ___ KB. (un número)',
   '512', null, null,
   'Express One Zone cobra extra por peticiones de archivos mayores de 512 KB.'),
  ('true_false',
   'Todas las clases comparten la misma durabilidad pero bajar el coste suele empeorar otros factores.',
   'Verdadero', null, null,
   'Con 11 nueves comunes, el menor coste se paga en disponibilidad, AZs, latencia o cargos.'),
  ('multiple_choice',
   '¿Qué factores debes valorar para elegir clase de almacenamiento?',
   'Frecuencia de acceso, urgencia de recuperación y durabilidad/disponibilidad',
   'El color del bucket y el nombre del objeto',
   'El número exacto de objetos del bucket',
   'La elección depende del patrón de acceso y de las garantías necesarias.'),
  ('anki_card',
   '¿Qué dos notas especiales recoge la comparativa?',
   'Intelligent-Tiering tiene coste de monitoreo; Express One Zone cobra extra por peticiones >512 KB.',
   null, null,
   'Son las dos salvedades destacadas de la tabla comparativa.')
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
-- LECCIÓN 6 — Repaso: cargos y notas (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: cargos y notas',
      'Repasamos los **cargos**: duración mínima (**30** días IA, **90** Glacier Instant/Flexible, **180** Deep Archive), **tarifa de recuperación** (per GB en IA y Glacier), **mínimo por objeto** (**128 KB** IA, **40 KB** Glacier Vault) y las **notas** (monitoreo de Intelligent-Tiering, cargo **>512 KB** de Express). Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 7 — Lección final (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 21 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cerrado la **comparativa** de las **8 clases** de S3: misma **durabilidad** (11 nueves), distinta **disponibilidad** (99,99% → 99,5%), **AZs** (1 en las "one zone", >3 el resto), **latencia de primer byte** (de single-digit ms a horas), y los **cargos** (duración mínima, recuperación per GB, mínimo por objeto), más las notas de **Intelligent-Tiering** y **Express One Zone**. Con esto completas el bloque de **S3 Storage Classes**. Esta lección final repasa una selección de lo aprendido.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_23_aws-saa-c03.sql
-- =============================================================================
