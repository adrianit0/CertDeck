# Edge Function: `certdeck-courses`

Lista los cursos publicados (solo lectura). Un recurso = una función; el método HTTP distingue la operación.

> **Función NUEVA y autocontenida** (Constitución §4): CORS propio, sin código compartido. El agente no la despliega; lo hace el propietario.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`

Usa el JWT del usuario (header `Authorization`) para que RLS y `auth.uid()` apliquen.

## Petición
- **GET** (sin parámetros). Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": [ { "id": "…", "title": "…", "slug": "…", "description": "…", "icon": "…", "color": "…", "difficulty": 4 } ] }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-courses
```
