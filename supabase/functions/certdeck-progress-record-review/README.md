# Edge Function: `certdeck-progress-record-review`

Persiste una **sesión de repaso** (no atada a una lección) de forma autoritativa
(ADR 0006) y reconcilia los errores pendientes.

> **Función NUEVA.** CORS propio; no comparte código con otras funciones (Constitución §4). El agente no la despliega.

## Variables de entorno
Inyectadas por la plataforma: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Usa el JWT del
usuario (`Authorization`).

## Dependencias de base de datos
- **`script-005.sql`** aplicado (`certdeck_user_review_sessions`,
  `certdeck_user_failed_questions`).

## Payload de entrada (POST, JSON)
```json
{
  "review_type": "general-review",
  "correct_count": 8,
  "incorrect_count": 2,
  "anki_count": 4,
  "failed_questions": [{ "id": "uuid-pregunta", "lessonId": "uuid-leccion" }],
  "passed_question_ids": ["uuid-pregunta-recuperada"]
}
```
`review_type` ∈ `topic-review` · `general-review` · `topic-errors` · `general-errors`.

## Respuesta esperada
```json
{ "data": { "ok": true, "review": { "id": "…", "xp": 500, "total_answers": 10, "correct_answers": 8, "anki_cards": 4 } } }
```
El `xp` se **recalcula en el servidor** (xp = aciertos·50 + 100).

## Errores posibles
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `invalid_json` / `invalid_review_type` / `invalid_counts` | Payload inválido |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `persist_failed` | Error al persistir (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-progress-record-review
```
> El agente no ejecuta este comando (Constitución §4).
