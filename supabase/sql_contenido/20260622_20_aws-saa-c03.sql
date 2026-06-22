-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 20
-- Archivo: supabase/sql_contenido/20260622_20_aws-saa-c03.sql
-- Fecha: 2026-06-22
--
-- Crea el DECIMOCTAVO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Storage Classes - Glacier Flexible Retrieval" (position 18) — diapositiva 51
--       L1 (normal)  ¿Qué es Glacier Flexible Retrieval?  (slide 51)
--       L2 (normal)  Los 3 tiers de recuperación          (slide 51)
--       L3 (review)  Repaso: Flexible Retrieval y tiers
--       L4 (normal)  Coste de recuperación                (slide 51)
--       L5 (normal)  Overhead de 40 KB por objeto         (slide 51)
--       L6 (review)  Repaso: costes y overhead
--       L7 (final)   Lección final: Glacier Flexible Retrieval
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
-- TEMA: S3 Storage Classes - Glacier Flexible Retrieval  (position 18)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Storage Classes - Glacier Flexible Retrieval',
       'La clase de archivo (antes "S3 Glacier") con tres niveles de recuperación: Expedited, Standard y Bulk. Combina S3 y Glacier en una sola API.',
       'S3 Glacier Flexible Retrieval (antes llamada simplemente S3 Glacier) combina S3 y Glacier en un único conjunto de APIs. Es considerablemente más rápida que el almacenamiento basado en Glacier Vault. No es un servicio separado y no requiere un Vault. Ofrece 3 niveles (tiers) de recuperación, donde más rápido significa más caro: el Expedited Tier recupera en 1-5 minutos para peticiones urgentes y está limitado a archivos de hasta 250 MB; el Standard Tier recupera en 3-5 horas, sin límite de tamaño de archivo, y es la opción por defecto; el Bulk Tier recupera en 5-12 horas, sin límite de tamaño (incluso petabytes) y la recuperación Bulk es gratuita (sin coste por GB). Pagas por GB recuperado y por número de peticiones, un coste separado del de solo almacenar. Además, los objetos archivados tienen 40 KB adicionales de datos: 32 KB para el índice del archivo y los metadatos, y 8 KB para el nombre del objeto. Por eso conviene almacenar menos archivos y más grandes en lugar de muchos archivos pequeños, ya que esos 40 KB en miles de archivos se acumulan.',
       18,
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es Glacier Flexible Retrieval?',
      'Antes "S3 Glacier": combina S3 y Glacier en una sola API, sin Vault.', 'normal'),
  (2, 'Los 3 tiers de recuperación',
      'Expedited, Standard y Bulk: tiempos, límites y opción por defecto.', 'normal'),
  (3, 'Repaso: Flexible Retrieval y tiers',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (4, 'Coste de recuperación',
      'Pagas por GB recuperado y por peticiones, aparte del almacenamiento.', 'normal'),
  (5, 'Overhead de 40 KB por objeto',
      'Por qué conviene pocos archivos grandes en vez de muchos pequeños.', 'normal'),
  (6, 'Repaso: costes y overhead',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (7, 'Lección final: Glacier Flexible Retrieval',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es Glacier Flexible Retrieval? (slide 51)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Antes "S3 Glacier"',
      E'**S3 Glacier Flexible Retrieval** (antes llamada simplemente **S3 Glacier**) **combina S3 y Glacier** en un **único conjunto de APIs**.\n\nEs **considerablemente más rápida** que el almacenamiento basado en **Glacier Vault**.'),
  (2, 'Sin Vault',
      E'- **No** es un **servicio separado**.\n- **No requiere** un **Vault**.\n\nFunciona como una clase de almacenamiento dentro de S3.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cómo se llamaba antes S3 Glacier Flexible Retrieval?',
   'Simplemente "S3 Glacier"',
   'S3 Glacier Deep Archive',
   'S3 Glacier Instant',
   'Flexible Retrieval era la clase conocida antes como "S3 Glacier".'),
  ('true_false',
   'Glacier Flexible Retrieval combina S3 y Glacier en un único conjunto de APIs.',
   'Verdadero', null, null,
   'Unifica S3 y Glacier en una sola API, más rápida que el Vault.'),
  ('multiple_choice',
   '¿Es Glacier Flexible Retrieval más rápida o más lenta que el almacenamiento basado en Glacier Vault?',
   'Considerablemente más rápida',
   'Considerablemente más lenta',
   'Exactamente igual de rápida',
   'Es bastante más rápida que el almacenamiento basado en Vault.'),
  ('true_false',
   'Glacier Flexible Retrieval requiere crear y gestionar un Vault.',
   'Falso', null, null,
   'No es un servicio separado ni requiere Vault.'),
  ('anki_card',
   '¿Qué combina Glacier Flexible Retrieval en una sola API?',
   'S3 y Glacier.',
   null, null,
   'Unifica ambos en un único conjunto de APIs, sin Vault.')
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
-- LECCIÓN 2 — Los 3 tiers de recuperación (slide 51)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Tres niveles: más rápido = más caro',
      E'Hay **3 tiers** de recuperación (cuanto más rápido, más caro):\n- **Expedited Tier**: **1-5 minutos**. Para peticiones **urgentes**. Limitado a archivos de **hasta 250 MB**.\n- **Standard Tier**: **3-5 horas**. **Sin límite** de tamaño. Es la opción **por defecto**.\n- **Bulk Tier**: **5-12 horas**. Sin límite de tamaño (incluso **petabytes**). La recuperación Bulk es **gratuita** (sin coste por GB).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿En cuánto tiempo recupera el Expedited Tier?',
   '1-5 minutos',
   '3-5 horas',
   '5-12 horas',
   'Expedited es el más rápido: 1-5 minutos, para peticiones urgentes.'),
  ('text_input',
   '¿A cuántos MB de tamaño de archivo está limitado el Expedited Tier? (un número)',
   '250', null, null,
   'Expedited está limitado a archivos de hasta 250 MB.'),
  ('multiple_choice',
   '¿Cuál es el tier de recuperación por defecto?',
   'Standard Tier (3-5 horas)',
   'Expedited Tier (1-5 minutos)',
   'Bulk Tier (5-12 horas)',
   'El Standard Tier (3-5 horas, sin límite de tamaño) es la opción por defecto.'),
  ('multiple_choice',
   '¿Qué tier de recuperación es gratuito (sin coste por GB)?',
   'Bulk Tier (5-12 horas)',
   'Expedited Tier (1-5 minutos)',
   'Standard Tier (3-5 horas)',
   'La recuperación Bulk es gratuita, aunque tarda de 5 a 12 horas.'),
  ('true_false',
   'En Glacier Flexible Retrieval, cuanto más rápida es la recuperación, más cara resulta.',
   'Verdadero', null, null,
   'Los tiers ordenan velocidad y coste: más rápido implica más caro.'),
  ('anki_card',
   'Ordena los 3 tiers de Flexible Retrieval de más rápido a más lento con sus tiempos.',
   'Expedited (1-5 min) > Standard (3-5 h) > Bulk (5-12 h).',
   null, null,
   'A mayor velocidad, mayor coste; Bulk es el más lento pero gratuito.')
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
-- LECCIÓN 3 — Repaso: Flexible Retrieval y tiers (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Flexible Retrieval y tiers',
      'Repasamos qué es **Glacier Flexible Retrieval** (antes "S3 Glacier", combina S3 y Glacier, sin Vault) y sus **3 tiers**: **Expedited** (1-5 min, ≤250 MB), **Standard** (3-5 h, por defecto) y **Bulk** (5-12 h, gratuito). Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 4 — Coste de recuperación (slide 51)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Pagas por recuperar',
      E'Con Glacier Flexible Retrieval **pagas por**:\n- **GB recuperado**.\n- **Número de peticiones**.\n\nEste es un coste **separado** del simple coste de **almacenar**. Recuperar datos no es gratis (salvo el tier **Bulk**, que no cobra por GB).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 4
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'En Glacier Flexible Retrieval, ¿por qué pagas al recuperar datos?',
   'Por GB recuperado y por número de peticiones',
   'Solo por el número de buckets',
   'Por el color del objeto',
   'La recuperación se cobra por GB recuperado y por peticiones.'),
  ('true_false',
   'El coste de recuperación es un coste separado del coste de almacenamiento.',
   'Verdadero', null, null,
   'Recuperar es un cargo aparte del simple hecho de almacenar.'),
  ('multiple_choice',
   '¿Qué tier permite recuperar sin coste por GB?',
   'Bulk Tier',
   'Expedited Tier',
   'Standard Tier',
   'La recuperación Bulk es gratuita (no hay coste por GB).'),
  ('true_false',
   'Recuperar datos en el Expedited o Standard Tier es siempre gratuito.',
   'Falso', null, null,
   'Solo Bulk es gratuito por GB; Expedited y Standard tienen coste de recuperación.'),
  ('anki_card',
   '¿Por qué dos conceptos se cobra la recuperación en Flexible Retrieval?',
   'Por GB recuperado y por número de peticiones.',
   null, null,
   'Es un coste aparte del almacenamiento, salvo el tier Bulk (gratis por GB).')
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
-- LECCIÓN 5 — Overhead de 40 KB por objeto (slide 51)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '40 KB extra por objeto',
      E'Los objetos archivados tienen **40 KB adicionales** de datos:\n- **32 KB** para el **índice del archivo** y los **metadatos**.\n- **8 KB** para el **nombre** del objeto.'),
  (2, 'Pocos archivos grandes',
      E'Por ese overhead conviene **almacenar menos archivos y más grandes** en lugar de **muchos archivos pequeños**.\n\n**40 KB** multiplicados por **miles** de archivos **se acumulan**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('text_input',
   '¿Cuántos KB adicionales de datos tiene cada objeto archivado en Flexible Retrieval? (un número)',
   '40', null, null,
   'Cada objeto archivado lleva 40 KB extra (32 KB + 8 KB).'),
  ('multiple_choice',
   '¿Cómo se reparten los 40 KB de overhead por objeto?',
   '32 KB para índice y metadatos, y 8 KB para el nombre',
   '20 KB para índice y 20 KB para el nombre',
   '8 KB para índice y 32 KB para el nombre',
   'Son 32 KB de índice/metadatos y 8 KB del nombre del objeto.'),
  ('multiple_choice',
   '¿Qué recomendación se deriva del overhead de 40 KB?',
   'Almacenar pocos archivos grandes en vez de muchos pequeños',
   'Almacenar muchos archivos pequeños',
   'No almacenar metadatos',
   'Como los 40 KB se acumulan, conviene menos archivos y más grandes.'),
  ('true_false',
   'El overhead de 40 KB es irrelevante aunque tengas miles de archivos pequeños.',
   'Falso', null, null,
   '40 KB por miles de archivos se acumulan y encarecen el almacenamiento.'),
  ('anki_card',
   '¿Para qué se usan los 32 KB y los 8 KB del overhead?',
   '32 KB para el índice del archivo y los metadatos; 8 KB para el nombre del objeto.',
   null, null,
   'Juntos suman los 40 KB extra de cada objeto archivado.')
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
-- LECCIÓN 6 — Repaso: costes y overhead (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: costes y overhead',
      'Repasamos el **coste de recuperación** (por **GB** y **peticiones**, aparte del almacenamiento; **Bulk** gratis por GB) y el **overhead de 40 KB** por objeto (**32 KB** índice/metadatos + **8 KB** nombre), que aconseja **pocos archivos grandes**. Estas tarjetas se reciclan de las lecciones anteriores.')
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
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 18 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Glacier Flexible Retrieval**: la clase antes llamada "S3 Glacier", que combina S3 y Glacier **sin Vault**, con **3 tiers** de recuperación (**Expedited** 1-5 min/≤250 MB, **Standard** 3-5 h por defecto, **Bulk** 5-12 h gratis por GB), su **coste de recuperación** por GB y peticiones, y el **overhead de 40 KB** por objeto que aconseja pocos archivos grandes. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260622_20_aws-saa-c03.sql
-- =============================================================================
