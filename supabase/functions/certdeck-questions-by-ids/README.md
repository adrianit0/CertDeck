# Edge Function: `certdeck-questions-by-ids`

Preguntas concretas por id (solo lectura), para los repasos de errores acumulados.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?ids=<uuid>&ids=<uuid>…` (parámetro repetido). Requiere `Authorization: Bearer <jwt>` y `apikey`. Sin `ids` devuelve `{ "data": [] }`.

## Respuesta
```json
{ "data": [ { "id": "…", "lesson_id": "…", "exercise_type": "true_false", "question": "…", "correct_answer": "…", "incorrect_answer_1": "…", "incorrect_answer_2": null, "explanation": "…" } ] }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-questions-by-ids
```
