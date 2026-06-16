-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 09
-- Archivo: supabase/sql_contenido/20260616_09_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el SÉPTIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "WORM" (position 7) — diapositiva 33 del Manual
--       L1 (normal)  ¿Qué es WORM?                      (slide 33)
--       L2 (normal)  Casos de uso de WORM               (slide 33)
--       L3 (normal)  Ejemplo: cartuchos y ROM           (slide 33)
--       L4 (review)  Repaso: WORM
--       L5 (final)   Lección final: WORM
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
-- TEMA: WORM  (etapa "Básico" = position 1; tema position 7)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'WORM',
       'WORM (Write Once Read Many): qué es, para qué sirve y un ejemplo cotidiano.',
       'WORM (Write Once Read Many, "escribir una vez, leer muchas") es una característica de cumplimiento de almacenamiento que hace que los datos sean inmutables: escribes el archivo una sola vez y nunca podrá modificarse ni borrarse, pero puedes leerlo un número ilimitado de veces. WORM es útil en sectores como la sanidad o las finanzas, donde los archivos deben poder auditarse y permanecer sin alterar. Un ejemplo de WORM son los cartuchos de videojuegos: los datos se escriben de forma permanente en una ROM (Read Only Memory, memoria de solo lectura); puedes jugar (leer los datos) tantas veces como quieras, pero no puedes cambiar los datos.',
       7,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es WORM?',
      'Write Once Read Many: datos inmutables que se escriben una vez y se leen muchas.', 'normal'),
  (2, 'Casos de uso de WORM',
      'Por qué importa WORM en sectores como la sanidad y las finanzas.', 'normal'),
  (3, 'Ejemplo: cartuchos y ROM',
      'Un ejemplo cotidiano de WORM: los cartuchos de videojuegos y la ROM.', 'normal'),
  (4, 'Repaso: WORM',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Lección final: WORM',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es WORM? (slide 33)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es WORM?',
      E'**WORM** (Write Once Read Many, "**escribir una vez, leer muchas**") es una característica de **cumplimiento de almacenamiento** que hace que los datos sean **inmutables**.\n\n- **Escribes** el archivo **una sola vez**.\n- **Nunca** podrá **modificarse** ni **borrarse**.\n- Puedes **leerlo** un número **ilimitado** de veces.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué significan las siglas WORM?',
   'Write Once Read Many',
   'Write Often Read Maybe',
   'Write Only Read Memory',
   'WORM = Write Once Read Many: escribir una vez, leer muchas.'),
  ('multiple_choice',
   '¿Qué hace WORM con los datos?',
   'Los hace inmutables',
   'Los cifra en tránsito',
   'Los comprime automáticamente',
   'WORM es una característica de cumplimiento que hace los datos inmutables.'),
  ('true_false',
   'Con WORM puedes leer un archivo un número ilimitado de veces.',
   'Verdadero', null, null,
   'WORM permite lecturas ilimitadas; lo que no permite es modificar o borrar.'),
  ('true_false',
   'Con WORM puedes modificar o borrar el archivo tras escribirlo.',
   'Falso', null, null,
   'Una vez escrito, el archivo no puede modificarse ni borrarse.'),
  ('text_input',
   'WORM hace que los datos sean ____ (una palabra).',
   'inmutables', null, null,
   'La esencia de WORM es la inmutabilidad de los datos.')
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
-- LECCIÓN 2 — Casos de uso de WORM (slide 33)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Para qué sirve WORM?',
      E'WORM es útil en sectores como la **sanidad** (healthcare) o las **finanzas** (financial), donde los archivos:\n- Deben poder **auditarse**.\n- Deben permanecer **sin alterar** (untampered).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿En qué sectores es especialmente útil WORM?',
   'Sanidad y finanzas',
   'Videojuegos y streaming',
   'Marketing y publicidad',
   'WORM destaca en sanidad y finanzas, donde se exige auditoría e integridad.'),
  ('multiple_choice',
   '¿Por qué se usa WORM en esos sectores?',
   'Porque los archivos deben auditarse y permanecer sin alterar',
   'Porque reduce el coste de almacenamiento a la mitad',
   'Porque acelera las descargas',
   'En esos sectores los archivos deben ser auditables y no manipulables.'),
  ('true_false',
   'WORM ayuda a garantizar que los archivos no han sido manipulados.',
   'Verdadero', null, null,
   'Al ser inmutables, los archivos WORM permanecen sin alterar (untampered).'),
  ('anki_card',
   '¿Qué dos características de los archivos buscan los sectores que usan WORM?',
   'Que se puedan auditar y que permanezcan sin alterar.',
   null, null,
   'WORM aporta auditabilidad e integridad de los datos.')
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
-- LECCIÓN 3 — Ejemplo: cartuchos y ROM (slide 33)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Un ejemplo cotidiano',
      E'Un ejemplo de WORM son los **cartuchos de videojuegos**:\n- Los datos se escriben de forma **permanente** en una **ROM** (Read Only Memory, memoria de **solo lectura**).\n- Puedes **jugar** (leer los datos) **tantas veces** como quieras.\n- Pero **no puedes cambiar** los datos.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué ejemplo cotidiano ilustra el concepto WORM?',
   'Los cartuchos de videojuegos (ROM)',
   'Un disco duro externo',
   'Una memoria USB regrabable',
   'En un cartucho, los datos se escriben una vez y solo se leen, como en WORM.'),
  ('multiple_choice',
   '¿Qué significa ROM?',
   'Read Only Memory (memoria de solo lectura)',
   'Random Object Memory',
   'Rewritable Optical Media',
   'ROM es memoria de solo lectura: se lee, pero no se reescribe.'),
  ('true_false',
   'En un cartucho de videojuego puedes cambiar los datos grabados en la ROM.',
   'Falso', null, null,
   'La ROM es de solo lectura: puedes jugar (leer) pero no cambiar los datos.'),
  ('text_input',
   'En el ejemplo, los datos del cartucho se graban en una ____ (siglas en inglés).',
   'ROM', null, null,
   'La ROM (Read Only Memory) almacena los datos de forma permanente y de solo lectura.'),
  ('anki_card',
   '¿Por qué un cartucho de videojuego es un buen ejemplo de WORM?',
   'Porque los datos se escriben una vez en la ROM y solo se pueden leer (jugar), no modificar.',
   null, null,
   'Refleja la idea de WORM: escribir una vez, leer muchas, sin poder modificar.')
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
-- LECCIÓN 4 — Repaso: WORM (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: WORM',
      'Vamos a repasar qué es **WORM**, sus **casos de uso** y el **ejemplo** de los cartuchos. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Lección final: WORM (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 7 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **WORM** (Write Once Read Many): datos **inmutables**, sus **casos de uso** en sanidad y finanzas, y el **ejemplo** de los cartuchos y la ROM. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_09_aws-saa-c03.sql
-- =============================================================================
