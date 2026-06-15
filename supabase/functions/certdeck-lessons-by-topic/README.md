# Edge Function: `certdeck-lessons-by-topic`

Lecciones de un tema (solo lectura), ordenadas por posición.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?topic_id=<uuid>`. Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": [ { "id": "…", "topic_id": "…", "title": "…", "description": "…", "lesson_type": "normal", "position": 1 } ] }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `missing_topic_id` | Falta `topic_id` |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-lessons-by-topic
```
