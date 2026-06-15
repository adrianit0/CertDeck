# Edge Function: `certdeck-progress-get`

Devuelve el **estado completo de progreso** del usuario (ADR 0006). Es la única
lectura de progreso: la app ya no usa `localStorage` como fuente de verdad.

> **Función NUEVA.** CORS propio; no comparte código con otras funciones (Constitución §4). El agente no la despliega.

## Variables de entorno
Inyectadas por la plataforma: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Usa el JWT del
usuario (`Authorization`) para que RLS y `auth.uid()` apliquen.

## Dependencias de base de datos
- `script-003.sql` (progreso de lección) y **`script-005.sql`**
  (`certdeck_user_review_sessions`, `certdeck_user_failed_questions`, columnas
  `xp`/`anki_count`).

## Entrada
`GET` sin cuerpo. Filtra por el usuario del JWT.

## Respuesta esperada
```json
{
  "data": {
    "lessons": {
      "uuid-leccion": {
        "status": "completed",
        "scorePercentage": 78,
        "correctCount": 7,
        "incorrectCount": 2,
        "ankiCount": 3,
        "xp": 600,
        "completedAt": "2026-06-15T…Z"
      }
    },
    "failedQuestions": { "uuid-pregunta": "uuid-leccion" },
    "review": { "xp": 0, "totalAnswers": 0, "correctAnswers": 0, "ankiCards": 0 },
    "activeDays": ["2026-06-14", "2026-06-15"]
  }
}
```
`activeDays` se **deriva** de las fechas de lecciones completadas y sesiones de
repaso; la racha se calcula en el cliente a partir de ese listado.

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de lectura (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-progress-get
```
> El agente no ejecuta este comando (Constitución §4).
