# Edge Function: `certdeck-spaced-review-update`

Aplica y persiste el estado de **repetición espaciada** (SM-2 simplificado, RN-13…17 / Q-03) de las tarjetas revisadas en una sesión, sobre `certdeck_user_spaced_repetition`.

> **Función NUEVA y autocontenida** (Constitución §4). CORS propio. El agente no la despliega. La lógica del algoritmo replica `app/lib/srs.ts` (RT-03).

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Dependencias de base de datos
- **`script-006.sql`** aplicado (`certdeck_user_spaced_repetition`).

## Payload de entrada (POST, JSON)
```json
{
  "reviews": [
    { "question_id": "uuid", "grade": "correct" },
    { "question_id": "uuid", "grade": "fail" },
    { "question_id": "uuid", "grade": "easy" }
  ]
}
```
`grade` ∈ `fail` · `correct` · `easy`. Las tarjetas sin estado previo parten de
cero (ease 2.5). Se deduplica por `question_id` (última evaluación gana).

## Respuesta esperada
```json
{ "data": { "updated": 3 } }
```
El servidor recalcula `ease_factor`, `interval_days`, `repetitions`, `lapses`,
`is_problematic` (a 3 fallos, Q-02) y `due_at`; no se confía en el cliente.

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `invalid_json` | Cuerpo no JSON |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `query_failed` / `persist_failed` | Error de BD (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-spaced-review-update
```
> El agente no ejecuta este comando (Constitución §4).
