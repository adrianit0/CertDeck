# Edge Function: `certdeck-report-create`

Da de alta un **reporte de error** de una tarjeta (botón de *asistencia técnica*),
para que el propietario revise y corrija errores de contenido (ADR 0008, RF-30).

> **Función NUEVA.** CORS propio; no comparte código con otras funciones (Constitución §4). El agente no la despliega.

## Variables de entorno
Inyectadas por la plataforma: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Usa el JWT del
usuario (`Authorization`), de modo que RLS exige `auth.uid() = user_id`.

## Dependencias de base de datos
- **`script-007.sql`** aplicado (`certdeck_user_question_reports`).

## Payload de entrada (POST, JSON)
```json
{
  "question_id": "uuid-de-la-pregunta",
  "question_source": "flashcard",
  "lesson_id": "uuid-leccion (opcional)",
  "course_id": "uuid-curso (opcional)",
  "question_text": "Enunciado tal y como lo vio el usuario (opcional, instantánea)",
  "category": "spelling",
  "details": "Texto libre con el motivo (opcional, máx. 2000)"
}
```
- `question_source` ∈ `flashcard` · `exam`.
- `category` ∈ `bug` · `spelling` · `wrong_answer` · `confusing` · `other`.

## Respuesta esperada
```json
{ "data": { "ok": true, "id": "uuid-del-reporte" } }
```

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `invalid_json` / `invalid_question_id` / `invalid_question_source` / `invalid_category` | Payload inválido |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `persist_failed` | Error al persistir (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-report-create
```
> El agente no ejecuta este comando (Constitución §4).
