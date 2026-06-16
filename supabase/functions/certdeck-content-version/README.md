# Edge Function: `certdeck-content-version`

Devuelve un **token de versión** del catálogo de un curso (etapas + temas +
lecciones), para que el cliente decida si su **caché local** sigue vigente o debe
volver a descargar el contenido (ADR 0009 · RNF-17).

> **Función NUEVA.** CORS propio; no comparte código con otras funciones (Constitución §4). El agente no la despliega.

## Variables de entorno
Inyectadas por la plataforma: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Usa el JWT del
usuario (`Authorization`), de modo que la RPC respeta la RLS (cuenta solo lo publicado).

## Dependencias de base de datos
- **`script-008.sql`** aplicado (función `certdeck_course_catalog_version(uuid)`).

## Parámetros (GET, query)
- `course_id` — UUID del curso (obligatorio).

## Respuesta esperada
```json
{ "data": { "version": "1750000000.27" } }
```
`version` = `<epoch de la última actualización>.<recuento de etapas+temas+lecciones>`.
Es **opaco**: el cliente solo comprueba igualdad con el token guardado.

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `missing_course_id` | Falta el parámetro |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error en la RPC (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-content-version
```
> El agente no ejecuta este comando (Constitución §4).
