# Edge Function: `certdeck-questions-by-lessons`

Preguntas de un conjunto de lecciones (solo lectura), para los repasos por tema / generales.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?lesson_ids=<uuid>&lesson_ids=<uuid>…` (parámetro repetido). Requiere `Authorization: Bearer <jwt>` y `apikey`. Sin `lesson_ids` devuelve `{ "data": [] }`.

## Respuesta
```json
{ "data": [ { "id": "…", "lesson_id": "…", "exercise_type": "multiple_choice", "question": "…", "correct_answer": "…", "incorrect_answer_1": "…", "incorrect_answer_2": "…", "explanation": "…" } ] }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-questions-by-lessons
```
