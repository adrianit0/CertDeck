# Edge Function: `certdeck-exam-questions`

Práctica directa de examen (solo lectura, v3 · RF-24…29). Devuelve preguntas de
`certdeck_exam_questions` filtrables por tema y dificultad, con las respuestas
**ya desordenadas** (RF-28/RN-10) y un flag `isCorrect` por opción para el
feedback inmediato (RNF-14). La corrección autoritativa la hace
`certdeck-exam-grade`.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?course_id=<uuid>` (obligatorio) `&topic_id=<uuid>` `&difficulty=<1..5>` `&limit=<n>` (def. 10, máx. 40).
- Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": [ {
  "id": "…", "courseId": "…", "topicId": "…", "lessonId": null,
  "question": "…", "typeId": 2,
  "options": [ { "text": "…", "isCorrect": true }, { "text": "…", "isCorrect": false } ],
  "correctAnswersCount": 2, "extraInformation": "…", "difficulty": 3
} ] }
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
supabase functions deploy certdeck-exam-questions
```
