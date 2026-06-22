# CertDeck — Auditoría de seguridad (documento vivo)

> Registro de revisiones de seguridad del proyecto: datos expuestos, endpoints sin
> securizar, problemas de integridad y bugs aprovechables. Se actualiza en cada
> revisión; cada hallazgo lleva **severidad** y **estado** para seguimiento.
> Se rige por la [Constitución](../01-constitution/constitution.md) (§4 Edge
> Functions, §16 RLS) y los [Requisitos](../02-requirements/requirements.md)
> (RNF-13/14, RSP-01…03).

- **Última revisión:** 2026-06-22
- **Alcance revisado:** todo el proyecto (24 commits locales pendientes de push).
- **Estados posibles:** 🔴 Abierto · 🟡 Mitigado parcial · ✅ Resuelto · ⚪ Aceptado (decisión de producto)

---

## Leyenda de severidad
- **Alta:** explotable con impacto real (fuga de datos de terceros, escalada, RCE).
- **Media:** integridad/funcionalidad comprometida o superficie de riesgo evitable.
- **Baja / informativa:** defensa en profundidad o endurecimiento recomendable.

---

## Resumen del estado (2026-06-22)

Base sólida: RLS bien aplicada, sin secretos versionados, el cliente solo usa la
clave pública, y las Edge Functions de la app no usan service-role. Los problemas
principales son de **integridad de datos** (la XP no está realmente blindada) y un
**bug en el reset de progreso**. Ninguno bloquea un push a repo privado (no hay
fuga de secretos ni hacia terceros).

---

## Lo que está correcto (controles verificados)

- **Sin secretos versionados:** `app/.env`, `/android`, `/out`, `node_modules` en
  `.gitignore`; solo se versiona `app/.env.example`. La `service_role` nunca está
  en el cliente (este solo usa la *publishable/anon key*, pública por diseño).
- **RLS completa:** todas las tablas `certdeck_user_*` tienen RLS con
  `auth.uid() = user_id`. El contenido (`certdeck_courses/stages/topics/lessons/
  lesson_screens`, `*_questions`) es de **solo lectura** y filtrado por
  `is_published`.
- **Edge Functions de la app (`certdeck-*`):** todas verifican el JWT (`getUser`)
  y usan la *anon key* → la RLS se aplica; no hay bypass por service-role.
- **Función SQL `certdeck_course_catalog_version`** (script-008): `security
  invoker`, `stable`, parametrizada → sin inyección.
- **Corrección de examen** (`certdeck-exam-grade`): autoritativa (re-lee la
  pregunta de la BD y aplica la regla de conjunto exacto).

---

## Hallazgos

### SEC-01 — La XP de lecciones/repasos no está realmente blindada
- **Severidad:** Media (integridad) · **Estado:** 🔴 Abierto
- **Dónde:** `supabase/functions/certdeck-progress-complete-lesson/index.ts`,
  `supabase/functions/certdeck-progress-record-review/index.ts`
- **Descripción:** el servidor recalcula la *fórmula* de XP (ADR 0010) pero a
  partir de `correct_count`/`incorrect_count` **enviados por el cliente**:
  ```ts
  const score = total === 0 ? 100 : Math.round((correct / total) * 100);
  const xp = sessionXp(score, isRepeat); // score proviene de datos del cliente
  ```
  Un usuario puede invocar el endpoint con `correct_count: 100, incorrect_count: 0`
  (o repetirlo) para forjar/farmear XP y nivel. Contradice el objetivo de "blindar
  la XP" (solo se trasladó la fórmula, no la **verificación de respuestas**).
- **Impacto:** acotado por RLS a los datos del propio usuario (su XP/nivel); no
  afecta a terceros. Relevante si el nivel tiene valor (gamificación/ranking).
- **Relacionado:** [SEC-02](#sec-02--todas-las-respuestas-correctas-son-legibles-por-cualquier-autenticado), [ADR 0010](../00-decisions/0010-economia-xp-y-niveles.md).
- **Mitigación propuesta:** que la Edge Function reciba las **respuestas** (no los
  conteos) y las corrija contra la BD, como ya hace `certdeck-exam-grade`.

### SEC-02 — Todas las respuestas correctas son legibles por cualquier autenticado
- **Severidad:** Media · **Estado:** ⚪ Aceptado (MVP, RNF-14) — revisar post-MVP
- **Dónde:** RLS de `certdeck_flashcard_questions` y `certdeck_exam_questions`
  (script-002), columnas `correct_answer` / `answer_*`.
- **Descripción:** la política `select` expone **todas las columnas** (incluida la
  respuesta correcta) a cualquier autenticado. La regla "todo pasa por Edge
  Functions" **no está forzada en la BD**: un usuario puede consultar las tablas
  directamente (PostgREST + su JWT) y leer todas las soluciones. Combinado con
  SEC-01, hace trivial puntuar 100% siempre.
- **Impacto:** sin integridad de evaluación; habilita el farming de SEC-01.
- **Mitigación propuesta (fondo):** no exponer `correct_answer` al cliente; servir
  preguntas sin la solución y corregir en servidor (rediseño mayor).

### SEC-03 — `certdeck-progress-reset` no borra el progreso de lecciones
- **Severidad:** Media (funcional/privacidad) · **Estado:** 🔴 Abierto
- **Dónde:** `supabase/functions/certdeck-progress-reset/index.ts`; faltan
  políticas `for delete` en `certdeck_user_lesson_progress` (script-003),
  `certdeck_user_question_attempts` (script-003) y
  `certdeck_user_spaced_repetition` (script-006).
- **Descripción:** el reset hace `.delete()` sobre `certdeck_user_lesson_progress`,
  pero **sin política DELETE la RLS lo bloquea silenciosamente** (0 filas). El
  "Reiniciar progreso" deja intactas lecciones completadas, XP, nivel, intentos y
  estado SM-2; solo limpia repasos/errores/exámenes (esas sí tienen DELETE).
- **Impacto:** no es un agujero (RLS restrictiva = dirección segura), pero la
  función de reset está rota.
- **Mitigación propuesta:** añadir políticas `for delete` propias
  (`auth.uid() = user_id`) en las tres tablas en un `script-010.sql`.

### SEC-04 — `auth-register` apunta al esquema de otro proyecto y usa service-role
- **Severidad:** Media (superficie/mantenimiento) · **Estado:** 🔴 Abierto
- **Dónde:** `supabase/functions/auth-register/index.ts`,
  `supabase/functions/_shared/supabase.ts` (`getAdminClient`, service-role).
- **Descripción:** usa la *service-role key* (bypassa RLS) y referencia tablas
  `rol`, `profile_rol`, `profiles` que son de **Gessalud**, no de CertDeck. En el
  proyecto `wtkumfcjqqmgokgrbxxr` probablemente falla; además mantiene una función
  con service-role y dependencias externas dentro de este repo. `auth-login` sí es
  correcto (anon + `signInWithPassword`).
- **Mitigación propuesta:** si CertDeck no usa el registro, **sacar `auth-register`
  (y `_shared` si solo lo usa él) del repo** para reducir la superficie con
  service-role; si lo usa, adaptarlo a su propio esquema.

### SEC-05 — CORS `Access-Control-Allow-Origin: *`
- **Severidad:** Baja · **Estado:** ⚪ Aceptado
- **Dónde:** todas las Edge Functions (`corsHeaders`).
- **Descripción:** aceptable porque la auth es por *Bearer token* (no cookies), así
  que `*` no habilita peticiones con credenciales cross-site. Para Capacitor
  (origen `file://`/custom) es lo pragmático.
- **Mitigación opcional:** restringir a orígenes conocidos (defensa en profundidad).

### SEC-06 — Sin rate limiting propio
- **Severidad:** Baja · **Estado:** 🔴 Abierto
- **Dónde:** `auth-login` (fuerza bruta), `certdeck-report-create` (spam),
  endpoints de escritura (farming de SEC-01).
- **Mitigación propuesta:** rate limiting en auth y escritura (apoyarse también en
  las protecciones de plataforma de Supabase).

### SEC-07 — Entradas del cliente confiadas sin validar pertenencia
- **Severidad:** Baja · **Estado:** 🔴 Abierto
- **Dónde:** `certdeck-progress-complete-lesson` / `-record-review`
  (`failed_questions[].lessonId`, `passed_question_ids`).
- **Descripción:** se aceptan ids y `lessonId` del cliente sin verificar que
  pertenecen a la lección. Impacto limitado a filas propias (RLS).
- **Mitigación propuesta:** validar formato/pertenencia antes de upsert/delete.

### SEC-08 — Se devuelve `detail: error.message` de la BD al cliente
- **Severidad:** Baja / informativa · **Estado:** 🔴 Abierto
- **Dónde:** respuestas 500 de varias Edge Functions.
- **Descripción:** puede filtrar detalles de esquema/constraints (solo a usuarios
  autenticados).
- **Mitigación propuesta:** registrar el detalle en servidor y devolver un mensaje
  genérico al cliente.

---

## Prioridad recomendada
1. **SEC-03** (reset roto) — arreglo contenido (`script-010.sql` con políticas DELETE).
2. **SEC-01 / SEC-02** (integridad de XP y respuestas) — requiere mover la
   corrección de lecciones al servidor (cambio de mayor alcance).
3. **SEC-04** (auth-register) — decidir si sale del repo.
4. **SEC-05…08** — endurecimiento.

---

## Historial de revisiones
| Fecha | Revisor | Alcance | Notas |
|---|---|---|---|
| 2026-06-22 | Revisión asistida (Claude) | Proyecto completo (pre-push, 24 commits) | Alta inicial de SEC-01…08. Ningún hallazgo bloquea el push (sin secretos ni fuga a terceros). |
