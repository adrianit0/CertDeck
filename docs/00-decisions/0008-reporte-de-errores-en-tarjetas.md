# ADR 0008 — Reporte de errores en tarjetas (asistencia técnica)

- **Estado:** Aceptada
- **Fecha:** 2026-06-16
- **Fase:** 5 — Implementación
- **Decisores:** Propietario del proyecto
- **Relacionado:** [Requisitos](../02-requirements/requirements.md) §3.13 (RF-54…57), RSP-08; [Constitución](../01-constitution/constitution.md) §4/§5/§7; [ADR 0006](0006-persistencia-progreso-en-bd.md) (escritura vía Edge Function); [script-007.sql](../../supabase/sql/script-007.sql); Edge Function `certdeck-report-create`

## Contexto

El contenido educativo se carga por SQL a mano a partir del Manual; pese a la revisión, pueden colarse errores (bugs de render, faltas de ortografía, respuestas marcadas incorrectamente, enunciados ambiguos). Hasta ahora no había forma de que el usuario los señalara: el propietario quiere un canal **dentro de la propia tarjeta** para recogerlos y corregirlos después.

Restricciones del proyecto relevantes:

1. **Toda escritura pasa por una Edge Function** (`lib/edge/invoke`), nunca por la tabla directamente.
2. **RLS obligatoria** en toda tabla de datos de usuario (Constitución §5, RSP-01).
3. Una pregunta puede vivir en **dos catálogos distintos**: `certdeck_flashcard_questions` (lección/repaso) o `certdeck_exam_questions` (examen). No hay un identificador común con FK única.

## Decisión

1. **Botón de asistencia técnica en todas las tarjetas** de pregunta (flashcards y examen), arriba de la tarjeta. Componente reutilizable `app/components/ReportControl.tsx`.
2. Al pulsarlo abre un **mini-popup** con un **combo de motivo** (`bug`, `spelling`, `wrong_answer`, `confusing`, `other`) y un **campo de detalle** libre opcional (máx. 2000 caracteres).
3. El reporte se guarda en una **tabla nueva** `certdeck_user_question_reports` (script-007.sql) mediante la Edge Function **`certdeck-report-create`** (alta como el usuario autenticado; RLS exige `auth.uid() = user_id`).
4. **Sin FK a la pregunta:** se guarda `question_source` (`flashcard`/`exam`) + `question_id`, igual que en `certdeck_user_question_attempts`, más una **instantánea del enunciado** (`question_text`) y contexto opcional (`lesson_id`, `course_id`).
5. **Ciclo de vida** vía `status` (`open`/`reviewing`/`resolved`/`dismissed`), gestionado por el propietario (service_role / panel futuro); el usuario solo da de alta y consulta los suyos.
6. Los reportes **no** forman parte del progreso ni del repaso espaciado: son un canal de calidad de contenido independiente.

## Alternativas consideradas

1. **Insertar directamente desde el cliente con una policy de INSERT.** Rechazada: rompe la regla "toda escritura pasa por Edge Function" (ADR 0006) y dificulta la validación en servidor.
2. **FK polimórfica real / unificar identificadores de flashcard y examen.** Rechazada: cambio estructural no trivial para un dato de baja criticidad; basta `source` + `id` + instantánea.
3. **Enviar el reporte por email/servicio externo.** Rechazada en el MVP: añade dependencias e impide gestionarlos junto al resto de datos.

## Consecuencias

**Positivas:** canal sencillo de calidad de contenido; datos estructurados y filtrables por motivo/estado; aislamiento por usuario (RLS); coherente con la arquitectura de escritura.

**A tener en cuenta:**
- La **gestión/resolución** de reportes (panel de administración, transición de `status`, deduplicación) queda **fuera de alcance** de esta iteración; se aborda más adelante.
- Como no hay FK a la pregunta, un reporte puede quedar "huérfano" si la pregunta se elimina; la instantánea `question_text` mitiga la pérdida de contexto.
- El botón aparece también durante la ronda de corrección y los repasos (cualquier tarjeta), lo cual es deseable.
