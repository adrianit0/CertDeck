# Edge Function: `certdeck-exam-grade`

Corrección **autoritativa** de un lote de respuestas de examen (v3 · RF-29/RSP-03)
y registro del intento. Reaplica en servidor la regla de **conjunto exacto**
(RN-11) sin confiar en el cliente y persiste cada intento en
`certdeck_user_question_attempts`. **No** altera la repetición espaciada (Q-06):
el examen no alimenta el repaso en el MVP.

Además registra una **sesión de examen** en `certdeck_user_exam_sessions` con XP
autoritativa (`xp = min(100, 50 + floor(score/2))`); cada sesión cuenta como "una
lección más" y aporta XP al total.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Dependencias de base de datos
- `certdeck_exam_questions`, `certdeck_user_question_attempts` y **`script-009.sql`**
  (`certdeck_user_exam_sessions`).

## Petición
- **POST** con `Authorization: Bearer <jwt>` y `apikey`.
```json
{ "attempts": [ { "question_id": "<uuid>", "selected_answers": ["Texto A", "Texto B"] } ] }
```

## Respuesta
```json
{ "data": { "results": [ { "questionId": "<uuid>", "correct": true } ], "correctCount": 1, "total": 1, "score": 100, "xp": 100 } }
```

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `invalid_json` | Cuerpo no JSON |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de POST |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-exam-grade
```
