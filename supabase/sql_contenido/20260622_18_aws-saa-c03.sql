-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 18
-- Archivo: supabase/sql_contenido/20260622_18_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOSEXTO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Glacier Storage Classes vs Vault" (position 16) — diapositiva 49
--       L1 (normal)  S3 Glacier "Vault"               (slide 49)
--       L2 (normal)  Las S3 Glacier Storage Classes   (slide 49)
--       L3 (normal)  Relación entre clases y Vault     (slide 49)
--       L4 (review)  Repaso: Glacier vs Vault
--       L5 (final)   Lección final: S3 Glacier Storage Classes vs Vault
--   Volumen: POCO -> normal·normal·normal·review·final (5).
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
-- TEMA: S3 Glacier Storage Classes vs Vault  (etapa "Básico" = position 1; tema position 16)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Glacier Storage Classes vs Vault',
       'La diferencia entre el servicio independiente S3 Glacier (basado en vaults) y las clases de almacenamiento Glacier que viven dentro de los buckets de S3.',
       'S3 Glacier es un servicio independiente de S3 que usa "vaults" (en lugar de buckets) para almacenar datos a largo plazo. Es el servicio de vault original: tiene políticas de control de vault (vault control policies), la mayoría de las interacciones ocurren a través de la AWS CLI y todavía hay empresas que usan S3 Glacier Vault. Por otro lado, las S3 Glacier Storage Classes ofrecen una funcionalidad similar a la de S3 Glacier pero con mayor comodidad y flexibilidad, todo dentro de buckets de S3. S3 Glacier Instant Retrieval es una clase nueva sin vínculo con S3 Glacier Vault. En cambio, S3 Glacier Flexible Retrieval y S3 Glacier Deep Archive usan S3 Glacier Vault por debajo, aunque desde el punto de vista del usuario no requieren gestionar un vault. S3 Glacier Deep Archive forma parte del conjunto S3 Glacier Vault.',
       16,
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
-- LECCIONES (5) — volumen POCO
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, 'S3 Glacier "Vault"',
      'El servicio independiente original basado en vaults.', 'normal'),
  (2, 'Las S3 Glacier Storage Classes',
      'Funcionalidad Glacier con más comodidad, dentro de buckets de S3.', 'normal'),
  (3, 'Relación entre clases y Vault',
      'Cuáles usan Vault por debajo y cuál no.', 'normal'),
  (4, 'Repaso: Glacier vs Vault',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: S3 Glacier Storage Classes vs Vault',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — S3 Glacier "Vault" (slide 49)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Un servicio independiente',
      E'**S3 Glacier** es un **servicio independiente** de S3 que usa **vaults** (en lugar de **buckets**) para almacenar datos **a largo plazo**.\n\nEs el **servicio de vault original**.'),
  (2, 'Características de Glacier Vault',
      E'- Tiene **políticas de control de vault** (vault control policies).\n- La mayoría de las **interacciones** ocurren a través de la **AWS CLI**.\n- Todavía hay **empresas** que usan **S3 Glacier Vault**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué usa S3 Glacier (el servicio independiente) para almacenar datos?',
   'Vaults',
   'Buckets',
   'Directory buckets',
   'El servicio S3 Glacier usa vaults en lugar de buckets.'),
  ('true_false',
   'S3 Glacier es un servicio independiente de S3 y es el servicio de vault original.',
   'Verdadero', null, null,
   'S3 Glacier es stand-alone y el vault original para almacenamiento a largo plazo.'),
  ('multiple_choice',
   '¿A través de qué se realizan la mayoría de interacciones con S3 Glacier Vault?',
   'La AWS CLI',
   'La consola móvil de AWS',
   'Un Directory bucket',
   'La mayoría de las interacciones con Glacier Vault ocurren vía AWS CLI.'),
  ('true_false',
   'Las empresas ya no usan S3 Glacier Vault en absoluto.',
   'Falso', null, null,
   'Todavía hay enterprises que siguen usando S3 Glacier Vault.'),
  ('anki_card',
   '¿Qué son las "vault control policies"?',
   'Las políticas de control de acceso del servicio S3 Glacier Vault.',
   null, null,
   'Glacier Vault gestiona permisos mediante sus propias vault control policies.')
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
-- LECCIÓN 2 — Las S3 Glacier Storage Classes (slide 49)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Glacier, pero dentro de S3',
      E'Las **S3 Glacier Storage Classes** ofrecen una **funcionalidad similar** a la de S3 Glacier, pero con **mayor comodidad y flexibilidad**, todo **dentro de buckets de S3**.\n\nSon las clases: **Glacier Instant Retrieval**, **Glacier Flexible Retrieval** y **Glacier Deep Archive**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Dónde viven las S3 Glacier Storage Classes?',
   'Dentro de buckets de S3',
   'En vaults independientes',
   'En Directory buckets exclusivos',
   'Las Glacier Storage Classes funcionan dentro de buckets de S3.'),
  ('multiple_choice',
   '¿Qué ventaja aportan las Glacier Storage Classes frente al servicio Glacier Vault?',
   'Mayor comodidad y flexibilidad, dentro de S3',
   'Mayor durabilidad garantizada',
   'Recuperación siempre instantánea y gratuita',
   'Ofrecen funcionalidad similar con más conveniencia y flexibilidad dentro de S3.'),
  ('true_false',
   'Las Glacier Storage Classes ofrecen funcionalidad similar a S3 Glacier pero con más comodidad.',
   'Verdadero', null, null,
   'Replican la funcionalidad Glacier con mayor comodidad y flexibilidad en S3.'),
  ('anki_card',
   'Nombra las tres S3 Glacier Storage Classes.',
   'Glacier Instant Retrieval, Glacier Flexible Retrieval y Glacier Deep Archive.',
   null, null,
   'Son las tres clases Glacier que viven dentro de los buckets de S3.'),
  ('multiple_choice',
   '¿Cuál NO es una S3 Glacier Storage Class?',
   'S3 Glacier Vault',
   'S3 Glacier Instant Retrieval',
   'S3 Glacier Deep Archive',
   'Glacier Vault es el servicio independiente, no una de las storage classes.')
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
-- LECCIÓN 3 — Relación entre clases y Vault (slide 49)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Cuáles usan Vault por debajo?',
      E'- **Glacier Instant Retrieval**: clase **nueva**, **sin vínculo** con S3 Glacier Vault.\n- **Glacier Flexible Retrieval** y **Glacier Deep Archive**: usan **S3 Glacier Vault por debajo**, aunque **no requieres gestionar un vault**.\n- **S3 Glacier Deep Archive** forma parte del conjunto **S3 Glacier Vault**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué clase Glacier NO tiene vínculo con S3 Glacier Vault?',
   'S3 Glacier Instant Retrieval',
   'S3 Glacier Flexible Retrieval',
   'S3 Glacier Deep Archive',
   'Glacier Instant Retrieval es una clase nueva sin attachment a Glacier Vault.'),
  ('multiple_choice',
   '¿Qué dos clases usan S3 Glacier Vault por debajo?',
   'Glacier Flexible Retrieval y Glacier Deep Archive',
   'Glacier Instant Retrieval y Standard',
   'Standard-IA y One-Zone-IA',
   'Flexible Retrieval y Deep Archive se apoyan en Glacier Vault por debajo.'),
  ('true_false',
   'Aunque Flexible Retrieval y Deep Archive usan Vault por debajo, el usuario no necesita gestionar un vault.',
   'Verdadero', null, null,
   'Desde el punto de vista del usuario, las storage classes no requieren gestionar un vault.'),
  ('anki_card',
   '¿Qué relación tiene S3 Glacier Deep Archive con Glacier Vault?',
   'Deep Archive forma parte del conjunto S3 Glacier Vault y lo usa por debajo.',
   null, null,
   'Deep Archive se apoya en la tecnología de Glacier Vault.'),
  ('true_false',
   'Glacier Instant Retrieval requiere crear y administrar un vault.',
   'Falso', null, null,
   'Instant Retrieval es una clase nueva sin vínculo con Glacier Vault.')
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
-- LECCIÓN 4 — Repaso: Glacier vs Vault (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Glacier vs Vault',
      'Repasamos la diferencia entre el servicio independiente **S3 Glacier Vault** (vaults, AWS CLI, original) y las **S3 Glacier Storage Classes** dentro de S3, y cuáles usan **Vault por debajo** (Flexible y Deep Archive) y cuál **no** (Instant Retrieval). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 16 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto la diferencia entre **S3 Glacier Vault** (servicio independiente, basado en **vaults**, gestionado vía **AWS CLI**) y las **S3 Glacier Storage Classes** dentro de S3, además de la relación de cada clase con el Vault (**Instant** sin vínculo; **Flexible** y **Deep Archive** apoyadas en Vault). Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_18_aws-saa-c03.sql
-- =============================================================================
