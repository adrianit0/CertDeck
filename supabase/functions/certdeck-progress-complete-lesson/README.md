# Edge Function: `certdeck-progress-complete-lesson`

Persiste de forma autoritativa la finalización de una lección (ADR 0002/0006).

> **Función NUEVA.** No comparte ni modifica CORS/código con `auth-login` / `auth-register` (Constitución §4). El agente no la despliega; lo hace el propietario.

## Variables de entorno
Las inyecta automáticamente la plataforma de Supabase Edge Functions:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

No requiere secretos adicionales. Usa el JWT del usuario (header `Authorization`) para que RLS y `auth.uid()` apliquen.

## Dependencias de base de datos
- `supabase/sql/script-001.sql`, `script-002.sql`, `script-003.sql` y
  **`script-005.sql`** aplicados (este último añade `xp`/`anki_count` a
  `certdeck_user_lesson_progress` y crea `certdeck_user_failed_questions`).

## Payload de entrada (POST, JSON)
```json
{
  "lesson_id": "uuid-de-la-leccion",
  "correct_count": 7,
  "incorrect_count": 2,
  "anki_count": 3,
  "failed_questions": [{ "id": "uuid-pregunta", "lessonId": "uuid-leccion" }],
  "passed_question_ids": ["uuid-pregunta-recuperada"]
}
```

## Respuesta esperada
```json
{
  "data": {
    "ok": true,
    "progress": {
      "user_id": "…",
      "lesson_id": "…",
      "status": "completed",
      "score_percentage": 78,
      "correct_count": 7,
      "incorrect_count": 2,
      "anki_count": 3,
      "xp": 600,
      "completed_at": "2026-06-15T…Z"
    }
  }
}
```
`score_percentage` y `xp` se **recalculan en el servidor** (xp = aciertos·50 + 250);
no se confía en el cliente. Además da de alta `failed_questions` y de baja
`passed_question_ids` en `certdeck_user_failed_questions`.

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `invalid_json` / `missing_lesson_id` / `invalid_counts` | Payload inválido |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `persist_failed` | Error al persistir (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
# Desde la raíz del proyecto, con la CLI de Supabase autenticada:
supabase functions deploy certdeck-progress-complete-lesson
```
> El agente no ejecuta este comando (Constitución §4).
