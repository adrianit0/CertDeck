# Edge Function: `certdeck-progress-reset`

Borra **todo el progreso** del usuario (ADR 0006): progreso de lecciones,
sesiones de repaso, errores pendientes y sesiones de examen. Sustituye al
`resetProgress()` local.

> **Función NUEVA.** CORS propio; no comparte código con otras funciones (Constitución §4). El agente no la despliega.

## Variables de entorno
Inyectadas por la plataforma: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Usa el JWT del
usuario (`Authorization`); RLS garantiza que solo borra sus propias filas.

## Dependencias de base de datos
- `script-003.sql`, **`script-005.sql`** y **`script-009.sql`**
  (`certdeck_user_exam_sessions`) aplicados.

## Entrada
`POST` sin cuerpo.

## Respuesta esperada
```json
{ "data": { "ok": true } }
```

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `reset_failed` | Error al borrar (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-progress-reset
```
> El agente no ejecuta este comando (Constitución §4).
