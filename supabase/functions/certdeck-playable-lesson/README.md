# Edge Function: `certdeck-playable-lesson`

Lección reproducible: la lección + sus pantallas de teoría + sus preguntas activas (solo lectura). El orden de las preguntas lo decide el reproductor (aleatorio), no la base de datos.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?lesson_id=<uuid>`. Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": { "lesson": { "…": "…" }, "screens": [ { "…": "…" } ], "questions": [ { "…": "…" } ] } }
```
Si la lección no existe: `{ "data": null }`.

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `missing_lesson_id` | Falta `lesson_id` |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-playable-lesson
```
