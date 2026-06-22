-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 22
-- Archivo: supabase/sql_contenido/20260622_22_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el VIGÉSIMO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Intelligent-Tiering" (position 20) — diapositiva 53
--       L1 (normal)  ¿Qué es Intelligent-Tiering?     (slide 53)
--       L2 (normal)  Tiers automáticos                (slide 53)
--       L3 (review)  Repaso: concepto y tiers automáticos
--       L4 (normal)  Tiers opcionales de archivo      (slide 53)
--       L5 (normal)  Coste de monitoreo               (slide 53)
--       L6 (review)  Repaso: tiers opcionales y coste
--       L7 (final)   Lección final: Intelligent-Tiering
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
-- TEMA: S3 Storage Classes - Intelligent-Tiering  (position 20)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Intelligent-Tiering',
       'La clase que mueve los objetos automáticamente entre niveles de acceso según su uso para reducir costes, cobrando una pequeña tarifa de monitoreo.',
       'La clase de almacenamiento S3 Intelligent-Tiering mueve automáticamente los objetos a diferentes niveles (tiers) de almacenamiento para reducir los costes, pero cobra un pequeño coste mensual por el monitoreo y la automatización de los objetos. S3 Intelligent-Tiering tiene los siguientes niveles de acceso: el Frequent Access tier (automático) es el nivel por defecto, donde los objetos permanecen mientras se sigan accediendo; el Infrequent Access tier (automático) recibe los objetos que no se acceden después de 30 días; el Archive Instant Access tier (automático) recibe los objetos que no se acceden después de 90 días; el Archive Access tier (opcional) actúa, tras su activación, si el objeto no se accede después de 90 días; y el Deep Archive Access tier (opcional) actúa, tras su activación, si el objeto no se accede después de 180 días. S3 Intelligent-Tiering tiene un coste adicional por analizar los objetos durante 30 días.',
       20,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es Intelligent-Tiering?',
      'Mueve objetos entre tiers automáticamente para ahorrar costes.', 'normal'),
  (2, 'Tiers automáticos',
      'Frequent, Infrequent (30 días) y Archive Instant (90 días).', 'normal'),
  (3, 'Repaso: concepto y tiers automáticos',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Tiers opcionales de archivo',
      'Archive Access (90 días) y Deep Archive Access (180 días).', 'normal'),
  (5, 'Coste de monitoreo',
      'La tarifa por monitoreo y el análisis durante 30 días.', 'normal'),
  (6, 'Repaso: tiers opcionales y coste',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: Intelligent-Tiering',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es Intelligent-Tiering? (slide 53)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Clasificación automática',
      E'**S3 Intelligent-Tiering** **mueve automáticamente** los objetos a **diferentes niveles (tiers)** de almacenamiento para **reducir los costes**.\n\nA cambio, cobra un **pequeño coste mensual** por el **monitoreo** y la **automatización** de los objetos.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué hace S3 Intelligent-Tiering?',
   'Mueve los objetos automáticamente entre tiers para reducir costes',
   'Borra los objetos antiguos automáticamente',
   'Replica los objetos en todas las regiones',
   'Intelligent-Tiering reubica los objetos en el tier óptimo según su uso.'),
  ('true_false',
   'Intelligent-Tiering cobra un pequeño coste mensual por monitoreo y automatización.',
   'Verdadero', null, null,
   'A cambio de la clasificación automática, hay una tarifa de monitoreo.'),
  ('multiple_choice',
   '¿Cuál es el objetivo de mover los objetos entre tiers?',
   'Reducir los costes de almacenamiento',
   'Aumentar la latencia',
   'Eliminar la durabilidad',
   'El movimiento automático busca abaratar el almacenamiento según el acceso.'),
  ('anki_card',
   '¿Qué ventaja y qué coste tiene Intelligent-Tiering?',
   'Ventaja: mueve objetos al tier óptimo automáticamente; coste: una pequeña tarifa de monitoreo.',
   null, null,
   'Automatiza el ahorro a cambio de un coste de monitoreo.')
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
-- LECCIÓN 2 — Tiers automáticos (slide 53)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Tres tiers automáticos',
      E'Estos niveles funcionan de forma **automática**:\n- **Frequent Access tier**: el **por defecto**; los objetos permanecen aquí **mientras se sigan accediendo**.\n- **Infrequent Access tier**: si un objeto **no se accede tras 30 días**, se mueve aquí.\n- **Archive Instant Access tier**: si **no se accede tras 90 días**, se mueve aquí.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuál es el tier por defecto en Intelligent-Tiering?',
   'Frequent Access tier',
   'Infrequent Access tier',
   'Deep Archive Access tier',
   'Los objetos empiezan en el Frequent Access tier mientras se accedan.'),
  ('text_input',
   '¿Tras cuántos días sin acceso pasa un objeto al Infrequent Access tier? (un número)',
   '30', null, null,
   'Si no se accede en 30 días, el objeto se mueve al Infrequent Access tier.'),
  ('text_input',
   '¿Tras cuántos días sin acceso pasa un objeto al Archive Instant Access tier? (un número)',
   '90', null, null,
   'Tras 90 días sin acceso, el objeto pasa al Archive Instant Access tier.'),
  ('true_false',
   'Los tiers Frequent, Infrequent y Archive Instant Access funcionan de forma automática.',
   'Verdadero', null, null,
   'Los tres son automáticos; no requieren activación del usuario.'),
  ('multiple_choice',
   '¿Qué tier recibe un objeto que deja de accederse durante más de 30 pero menos de 90 días?',
   'Infrequent Access tier',
   'Archive Instant Access tier',
   'Deep Archive Access tier',
   'A los 30 días pasa a Infrequent; a los 90 iría a Archive Instant Access.')
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
-- LECCIÓN 3 — Repaso: concepto y tiers automáticos (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: concepto y tiers automáticos',
      'Repasamos qué es **Intelligent-Tiering** (mueve objetos entre tiers automáticamente para ahorrar, con coste de monitoreo) y sus **tiers automáticos**: **Frequent** (por defecto), **Infrequent** (tras **30 días**) y **Archive Instant Access** (tras **90 días**). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Tiers opcionales de archivo (slide 53)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Dos tiers opcionales',
      E'Estos niveles son **opcionales** (hay que **activarlos**):\n- **Archive Access tier** (opcional): tras su **activación**, actúa si el objeto **no se accede tras 90 días**.\n- **Deep Archive Access tier** (opcional): tras su **activación**, actúa si el objeto **no se accede tras 180 días**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Qué distingue a los tiers Archive Access y Deep Archive Access del resto?',
   'Son opcionales y hay que activarlos',
   'Son los tiers por defecto',
   'No tienen ningún umbral de días',
   'A diferencia de los automáticos, estos dos requieren activación.'),
  ('text_input',
   'Tras activarlo, ¿a partir de cuántos días sin acceso actúa el Deep Archive Access tier? (un número)',
   '180', null, null,
   'El Deep Archive Access tier actúa tras 180 días sin acceso, una vez activado.'),
  ('multiple_choice',
   'Tras activarlo, ¿a partir de cuántos días sin acceso actúa el Archive Access tier?',
   'Tras 90 días',
   'Tras 30 días',
   'Tras 180 días',
   'El Archive Access tier (opcional) actúa tras 90 días sin acceso.'),
  ('true_false',
   'El Deep Archive Access tier de Intelligent-Tiering se activa automáticamente sin intervención.',
   'Falso', null, null,
   'Es un tier opcional: requiere activación previa por parte del usuario.'),
  ('anki_card',
   '¿Cuáles son los dos tiers opcionales de Intelligent-Tiering y sus umbrales?',
   'Archive Access (90 días) y Deep Archive Access (180 días), ambos tras activarse.',
   null, null,
   'Son opcionales y amplían el ahorro para objetos muy poco accedidos.')
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
-- LECCIÓN 5 — Coste de monitoreo (slide 53)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'El coste de analizar',
      E'S3 Intelligent-Tiering tiene un **coste adicional** por **analizar tus objetos** durante **30 días**.\n\nEs el precio de la **automatización**: AWS observa los patrones de acceso para decidir a qué tier mover cada objeto.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Durante cuántos días analiza Intelligent-Tiering tus objetos con coste adicional? (un número)',
   '30', null, null,
   'Tiene un coste adicional por analizar los objetos durante 30 días.'),
  ('true_false',
   'Intelligent-Tiering tiene un coste adicional por analizar los objetos.',
   'Verdadero', null, null,
   'El análisis para clasificar los objetos conlleva un coste extra.'),
  ('multiple_choice',
   '¿Por qué Intelligent-Tiering cobra un coste de monitoreo?',
   'Porque analiza los patrones de acceso para mover cada objeto al tier óptimo',
   'Porque replica los datos en otra región',
   'Porque cifra los objetos con KMS',
   'El coste cubre el análisis y la automatización del movimiento entre tiers.'),
  ('multiple_choice',
   '¿Cuándo NO compensaría tanto el coste de monitoreo de Intelligent-Tiering?',
   'Con muy pocos objetos o patrones de acceso ya conocidos',
   'Con grandes volúmenes de patrones de acceso impredecibles',
   'Cuando no sabes con qué frecuencia se accederá a los datos',
   'Si ya conoces el patrón de acceso, una clase fija puede salir más barata.'),
  ('anki_card',
   '¿Qué coste adicional caracteriza a Intelligent-Tiering?',
   'Una tarifa de monitoreo por analizar los objetos durante 30 días.',
   null, null,
   'Es el coste de la automatización del movimiento entre tiers.')
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
-- LECCIÓN 6 — Repaso: tiers opcionales y coste (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: tiers opcionales y coste',
      'Repasamos los **tiers opcionales** de Intelligent-Tiering (**Archive Access** a los **90 días** y **Deep Archive Access** a los **180 días**, ambos tras activarse) y el **coste de monitoreo** por analizar los objetos durante **30 días**. Estas tarjetas se reciclan de las lecciones anteriores.')
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 20 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Intelligent-Tiering**: mueve los objetos **automáticamente** entre tiers para **ahorrar** a cambio de una **tarifa de monitoreo**. Sus tiers **automáticos** (**Frequent**, **Infrequent** a 30 días, **Archive Instant Access** a 90 días) y **opcionales** (**Archive Access** a 90 días, **Deep Archive Access** a 180 días), más el **coste** por analizar los objetos 30 días. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_22_aws-saa-c03.sql
-- =============================================================================
