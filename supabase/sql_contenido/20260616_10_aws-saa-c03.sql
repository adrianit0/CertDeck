-- =============================================================================
-- CertDeck — CONTENIDO · Curso AWS SAA-C03 · Fragmento 10
-- Archivo: supabase/sql_contenido/20260616_10_aws-saa-c03.sql
-- Fecha: 2026-06-16
--
-- Crea el OCTAVO TEMA de la etapa "Básico":
--   Etapa: "Básico" (position 1, ya creada en el fragmento 02)
--     Tema: "S3 Object Lock" (position 8) — diapositivas 34-37 del Manual
--       L1 (normal)  ¿Qué es S3 Object Lock?            (slide 34)
--       L2 (normal)  Retención y configuración          (slides 34-35)
--       L3 (normal)  Modo Governance                    (slide 36)
--       L4 (review)  Repaso: Object Lock y Governance
--       L5 (normal)  Modo Compliance                    (slide 36)
--       L6 (normal)  Legal holds                        (slide 37)
--       L7 (review)  Repaso: Compliance y legal holds
--       L8 (final)   Lección final: S3 Object Lock
--   Volumen: MUCHO -> normal·normal·normal·review·normal·normal·review·final (8).
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
-- TEMA: S3 Object Lock  (etapa "Básico" = position 1; tema position 8)
-- ---------------------------------------------------------------------------
insert into public.certdeck_topics (stage_id, title, description, summary, position, is_published)
select s.id,
       'S3 Object Lock',
       'S3 Object Lock: protección WORM de objetos, periodos de retención, modos Governance y Compliance, y legal holds.',
       'S3 Object Lock permite evitar el borrado de objetos en un bucket; solo puede activarse al crear el bucket. Está pensado para empresas que necesitan impedir el borrado de objetos para lograr integridad de datos y cumplimiento normativo. Cumple con las regulaciones SEC 17a-4, CTCC y FINRA, y permite almacenar objetos con un modelo write-once-read-many (WORM), igual que S3 Glacier. La retención se gestiona de dos formas: periodos de retención (un periodo fijo de tiempo durante el cual el objeto permanece bloqueado, que puede ser fijo o indefinido) y legal holds (bloqueos que permanecen hasta que se eliminan). Los buckets con Object Lock no pueden usarse como destino de los logs de acceso al servidor. Object Lock se configura mediante la AWS API (CLI, SDK) y la consola de AWS. Existen dos modos de retención. En modo Governance, el objeto protegido no se puede modificar ni borrar sin permisos especiales, y el periodo de bloqueo puede cambiarse, acortarse o eliminarse por usuarios especiales; sirve para probar la configuración de retención antes de pasar a Compliance. Los permisos especiales para saltarse Governance son el permiso IAM s3:BypassGovernanceRetention y la cabecera x-amz-bypass-governance-retention:true; se usa el comando aws s3api put-object-retention para cambiar el bloqueo. En modo Compliance, el objeto protegido no puede ser sobrescrito ni borrado por ningún usuario, ni siquiera el usuario root; el periodo de bloqueo no se puede cambiar ni acortar, garantizando la integridad de la versión durante todo el periodo (borrar un objeto en Compliance exige eliminar la cuenta de AWS asociada). Un legal hold, como un periodo de retención, impide sobrescribir o borrar una versión de objeto, pero no tiene un tiempo fijo asociado y permanece hasta que se retira; requiere el permiso IAM s3:PutObjectLegalHold y se activa poniendo el flag --legal-hold en ON. Los legal holds son independientes de los periodos de retención: poner un legal hold no afecta al modo ni al periodo de retención de esa versión de objeto.',
       8,
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
-- LECCIONES (8) — volumen MUCHO
-- ---------------------------------------------------------------------------
with t as (
  select tp.id
  from public.certdeck_topics tp
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8
)
insert into public.certdeck_lessons
  (topic_id, title, description, lesson_type, position, is_published)
select t.id, v.title, v.description, v.lesson_type, v.position, true
from t,
(values
  (1, '¿Qué es S3 Object Lock?',
      'Protección WORM contra el borrado de objetos: para qué sirve y cumplimiento.', 'normal'),
  (2, 'Retención y configuración',
      'Las dos formas de retención y cómo se configura Object Lock.', 'normal'),
  (3, 'Modo Governance',
      'El modo flexible: cómo saltarse el bloqueo con permisos especiales.', 'normal'),
  (4, 'Repaso: Object Lock y Governance',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (5, 'Modo Compliance',
      'El modo estricto: nadie puede modificar ni borrar, ni el root.', 'normal'),
  (6, 'Legal holds',
      'Bloqueos sin tiempo fijo, independientes de la retención.', 'normal'),
  (7, 'Repaso: Compliance y legal holds',
      'Repaso de las lecciones anteriores del tema.', 'review'),
  (8, 'Lección final: S3 Object Lock',
      'Evaluación final del tema con tarjetas recicladas.', 'final')
) as v(position, title, description, lesson_type)
on conflict (topic_id, position) do update set
  title = excluded.title,
  description = excluded.description,
  lesson_type = excluded.lesson_type,
  is_published = excluded.is_published,
  updated_at = now();

-- ===========================================================================
-- LECCIÓN 1 — ¿Qué es S3 Object Lock? (slide 34)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 1
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es S3 Object Lock?',
      E'**S3 Object Lock** permite **evitar el borrado de objetos** en un bucket.\n- Solo puede **activarse al crear el bucket**.\n- Pensado para empresas que necesitan impedir el borrado para lograr **integridad de datos** y **cumplimiento normativo**.\n- Permite almacenar objetos con un modelo **WORM** (write-once-read-many), igual que **S3 Glacier**.'),
  (2, 'Cumplimiento y restricciones',
      E'- Cumple con las regulaciones **SEC 17a-4**, **CTCC** y **FINRA**.\n- Los buckets con Object Lock **no pueden usarse como destino** de los **logs de acceso al servidor** (server access log).')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 1
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Para qué sirve S3 Object Lock?',
   'Para evitar el borrado de objetos en un bucket',
   'Para cifrar los objetos en tránsito',
   'Para reducir el coste de almacenamiento',
   'Object Lock impide el borrado de objetos (modelo WORM).'),
  ('true_false',
   'S3 Object Lock solo puede activarse al crear el bucket.',
   'Verdadero', null, null,
   'Object Lock únicamente se puede habilitar en el momento de crear el bucket.'),
  ('multiple_choice',
   '¿Qué modelo de almacenamiento usa Object Lock?',
   'WORM (write-once-read-many), igual que S3 Glacier',
   'Read-write-many',
   'First-in-first-out',
   'Object Lock aplica un modelo WORM, como S3 Glacier.'),
  ('multiple_choice',
   '¿Con cuál de estas regulaciones cumple Object Lock?',
   'SEC 17a-4, CTCC y FINRA',
   'GDPR y HIPAA únicamente',
   'PCI-DSS y SOC 2 únicamente',
   'Object Lock es compatible con SEC 17a-4, CTCC y FINRA.'),
  ('true_false',
   'Un bucket con Object Lock puede usarse como destino de los logs de acceso al servidor.',
   'Falso', null, null,
   'Los buckets con Object Lock no pueden ser destino de server access logs.')
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
-- LECCIÓN 2 — Retención y configuración (slides 34-35)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 2
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Dos formas de retención',
      E'Puedes evitar que un objeto se **borre** o **sobrescriba** durante un tiempo **fijo** o **indefinidamente**. La retención se gestiona de **dos formas**:\n- **Periodos de retención**: un **periodo fijo** durante el cual el objeto permanece **bloqueado**.\n- **Legal holds**: el objeto permanece bloqueado **hasta que retiras** el hold.'),
  (2, 'Cómo se configura',
      E'Object Lock se puede configurar mediante:\n- La **AWS API** (**CLI**, **SDK**).\n- La **consola de AWS**.\n\nEsto permite que tanto usuarios **técnicos** como **no técnicos** puedan impedir el borrado o la modificación de objetos, garantizando **cumplimiento** e **integridad de datos**.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 2
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuáles son las dos formas de gestionar la retención en Object Lock?',
   'Periodos de retención y legal holds',
   'Cifrado y versionado',
   'Tags y metadata',
   'La retención se gestiona con periodos de retención y con legal holds.'),
  ('multiple_choice',
   '¿Qué es un periodo de retención?',
   'Un periodo fijo de tiempo durante el cual el objeto permanece bloqueado',
   'Un bloqueo que dura hasta que lo retiras manualmente',
   'Un permiso para borrar objetos antes de tiempo',
   'El periodo de retención bloquea el objeto durante un tiempo fijo.'),
  ('true_false',
   'Object Lock puede proteger un objeto durante un tiempo fijo o indefinidamente.',
   'Verdadero', null, null,
   'Puedes evitar el borrado/sobrescritura por un tiempo fijo o de forma indefinida.'),
  ('multiple_choice',
   '¿Cómo se puede configurar Object Lock?',
   'Mediante la AWS API (CLI, SDK) y la consola de AWS',
   'Solo editando el objeto a mano',
   'Solo desde S3 Glacier',
   'Se configura por API (CLI/SDK) y por la consola de AWS.'),
  ('anki_card',
   '¿Qué ventaja aporta poder configurar Object Lock por API y por consola?',
   'Que tanto usuarios técnicos como no técnicos pueden impedir el borrado o la modificación.',
   null, null,
   'La doble vía hace accesible la protección a perfiles técnicos y no técnicos.')
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
-- LECCIÓN 3 — Modo Governance (slide 36)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 3
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Modo Governance',
      E'Existen **dos modos de retención**: **Governance** y **Compliance**. El **modo Governance** es el **flexible**:\n- El objeto protegido **no se puede modificar ni borrar sin permisos especiales**.\n- El periodo de bloqueo **puede cambiarse, acortarse o eliminarse** por usuarios especiales.\n- Sirve para **probar** la configuración de retención **antes** de pasar a Compliance.'),
  (2, 'Permisos para saltarse Governance',
      E'Para **saltarse** el bloqueo en Governance necesitas permisos especiales:\n- **Permiso IAM**: `s3:BypassGovernanceRetention`.\n- **Cabecera de la petición**: `x-amz-bypass-governance-retention:true`.\n- Usa el comando `aws s3api put-object-retention` para **cambiar** la configuración del bloqueo.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 3
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿Cuáles son los dos modos de retención de Object Lock?',
   'Governance y Compliance',
   'Standard y Glacier',
   'Público y privado',
   'Los modos de retención son Governance (flexible) y Compliance (estricto).'),
  ('multiple_choice',
   'En modo Governance, ¿quién puede modificar o borrar un objeto protegido?',
   'Usuarios con permisos especiales',
   'Absolutamente nadie',
   'Cualquier usuario sin restricciones',
   'En Governance se puede modificar/borrar solo con permisos especiales.'),
  ('multiple_choice',
   '¿Qué permiso IAM se necesita para saltarse el bloqueo en Governance?',
   's3:BypassGovernanceRetention',
   's3:PutObjectLegalHold',
   's3:DeleteBucket',
   'El permiso s3:BypassGovernanceRetention permite saltarse Governance.'),
  ('text_input',
   'Cabecera necesaria para saltarse Governance: x-amz-bypass-governance-retention:____ (una palabra)',
   'true', null, null,
   'La cabecera x-amz-bypass-governance-retention:true permite el bypass.'),
  ('anki_card',
   '¿Para qué es útil el modo Governance antes de usar Compliance?',
   'Para probar la configuración de retención antes de aplicar el modo estricto.',
   null, null,
   'Governance permite ensayar la retención por ser modificable.'),
  ('multiple_choice',
   '¿Qué comando de la CLI se usa para cambiar la configuración del bloqueo?',
   'aws s3api put-object-retention',
   'aws s3 cp',
   'aws s3api delete-bucket',
   'put-object-retention cambia los ajustes de retención del objeto.')
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
-- LECCIÓN 4 — Repaso: Object Lock y Governance (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 4
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Object Lock y Governance',
      'Vamos a repasar qué es **Object Lock**, las formas de **retención**, la **configuración** y el modo **Governance**. Estas tarjetas se toman de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 5 — Modo Compliance (slide 36)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 5
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Modo Compliance',
      E'El **modo Compliance** es el **estricto**:\n- El objeto protegido **no puede ser sobrescrito ni borrado por ningún usuario**, **ni siquiera el usuario root**.\n- El periodo de bloqueo **no se puede cambiar ni acortar**.\n- Garantiza la **integridad de la versión** del objeto durante **todo el periodo** de retención.\n- **Borrar** un objeto en Compliance exige **eliminar la cuenta de AWS** asociada.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 5
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   'En modo Compliance, ¿quién puede borrar un objeto protegido?',
   'Nadie, ni siquiera el usuario root',
   'Solo el usuario root',
   'Cualquier usuario con permisos especiales',
   'En Compliance nadie puede borrar el objeto, ni el root.'),
  ('true_false',
   'En modo Compliance el periodo de bloqueo puede acortarse.',
   'Falso', null, null,
   'En Compliance el periodo de bloqueo no se puede cambiar ni acortar.'),
  ('multiple_choice',
   '¿Qué hace falta para borrar un objeto en modo Compliance?',
   'Eliminar la cuenta de AWS asociada',
   'Usar el permiso s3:BypassGovernanceRetention',
   'Añadir la cabecera de bypass',
   'La única forma es eliminar la cuenta de AWS asociada.'),
  ('multiple_choice',
   '¿Qué garantiza el modo Compliance durante el periodo de retención?',
   'La integridad de la versión del objeto',
   'La reducción del coste de almacenamiento',
   'La replicación automática entre regiones',
   'Compliance asegura la integridad de la versión durante todo el periodo.'),
  ('true_false',
   'El modo Compliance es más estricto que el modo Governance.',
   'Verdadero', null, null,
   'Compliance no admite excepciones; Governance sí, con permisos especiales.')
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
-- LECCIÓN 6 — Legal holds (slide 37)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 6
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¿Qué es un legal hold?',
      E'Como un periodo de retención, un **legal hold** impide que una **versión de objeto** se **sobrescriba** o se **borre**.\n- **No tiene un tiempo fijo** asociado: permanece en vigor **hasta que lo retiras**.\n- Requiere el **permiso IAM** `s3:PutObjectLegalHold`.\n- Basta con poner el flag `--legal-hold` en **ON**.'),
  (2, 'Independientes de la retención',
      E'Los legal holds son **independientes** de los periodos de retención:\n- Poner un legal hold sobre una versión de objeto **no afecta** al **modo** ni al **periodo de retención** de esa versión.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 6
)
insert into public.certdeck_flashcard_questions
  (lesson_id, exercise_type, question, correct_answer,
   incorrect_answer_1, incorrect_answer_2, explanation)
select l.id, v.exercise_type, v.question, v.correct_answer,
       v.incorrect_answer_1, v.incorrect_answer_2, v.explanation
from l,
(values
  ('multiple_choice',
   '¿En qué se diferencia un legal hold de un periodo de retención?',
   'No tiene un tiempo fijo: dura hasta que lo retiras',
   'Solo dura 30 días como máximo',
   'Permite borrar el objeto de inmediato',
   'El legal hold no tiene plazo fijo; permanece hasta que se elimina.'),
  ('multiple_choice',
   '¿Qué permiso IAM se necesita para poner un legal hold?',
   's3:PutObjectLegalHold',
   's3:BypassGovernanceRetention',
   's3:CreateBucket',
   'El permiso s3:PutObjectLegalHold permite aplicar legal holds.'),
  ('true_false',
   'Poner un legal hold cambia el modo o el periodo de retención del objeto.',
   'Falso', null, null,
   'Los legal holds son independientes: no afectan al modo ni al periodo de retención.'),
  ('multiple_choice',
   '¿Cómo se activa un legal hold?',
   'Poniendo el flag --legal-hold en ON',
   'Eliminando la cuenta de AWS',
   'Cambiando la clase de almacenamiento',
   'Basta con poner el flag --legal-hold en ON.'),
  ('anki_card',
   '¿Qué impide un legal hold sobre una versión de objeto?',
   'Que se sobrescriba o se borre, hasta que se retira el hold.',
   null, null,
   'Como la retención, protege la versión, pero sin plazo fijo.')
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
-- LECCIÓN 7 — Repaso: Compliance y legal holds (review · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 7
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, 'Repaso: Compliance y legal holds',
      'Repasamos el modo **Compliance** y los **legal holds**. Estas tarjetas se reciclan de las lecciones anteriores.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- ===========================================================================
-- LECCIÓN 8 — Lección final: S3 Object Lock (final · sin preguntas propias)
-- ===========================================================================
with l as (
  select l.id from public.certdeck_lessons l
  join public.certdeck_topics tp on tp.id = l.topic_id
  join public.certdeck_stages s on s.id = tp.stage_id
  join public.certdeck_courses c on c.id = s.course_id
  where c.slug = 'aws-saa-c03' and s.position = 1 and tp.position = 8 and l.position = 8
)
insert into public.certdeck_lesson_screens (lesson_id, title, body, position)
select l.id, v.title, v.body, v.position
from l,
(values
  (1, '¡Cierre del tema!',
      'Has cubierto **S3 Object Lock**: protección **WORM**, formas de **retención**, los modos **Governance** y **Compliance**, y los **legal holds**. Esta lección final repasa una selección de lo aprendido antes de avanzar.')
) as v(position, title, body)
on conflict (lesson_id, position) do update set
  title = excluded.title, body = excluded.body, updated_at = now();

-- =============================================================================
-- Fin de 20260616_10_aws-saa-c03.sql
-- =============================================================================
