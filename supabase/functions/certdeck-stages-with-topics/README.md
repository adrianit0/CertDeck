# Edge Function: `certdeck-stages-with-topics`

Etapas de un curso, cada una con sus temas (solo lectura), ordenado por posición.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?course_id=<uuid>`. Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": [ { "id": "…", "course_id": "…", "title": "…", "description": "…", "position": 1, "topics": [ { "id": "…", "stage_id": "…", "title": "…", "summary": "…", "position": 1 } ] } ] }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `missing_course_id` | Falta `course_id` |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-stages-with-topics
```
