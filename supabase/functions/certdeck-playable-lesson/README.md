# Edge Function: `certdeck-playable-lesson`

Lección reproducible: la lección + sus pantallas de teoría + sus preguntas activas (solo lectura). El orden de las preguntas lo decide el reproductor (aleatorio), no la base de datos.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Composición de preguntas por tipo de lección (ADR 0005, regla 2026-06-16)
- **`normal`** → sus propias `certdeck_flashcard_questions`.
- **`review`** → ~**4** tarjetas al azar de las **5 lecciones inmediatamente anteriores** en el recorrido del curso (orden `etapa.position → tema.position → lección.position`); puede **cruzar al tema anterior**.
- **`final`** → ~**6** tarjetas al azar de **cualquier lección del mismo tema**.

Las lecciones `review`/`final` **no almacenan preguntas propias**: se reciclan en tiempo de ejecución. Si no hay tarjetas suficientes en el pool, se devuelven las que haya. Cada pregunta conserva su `lesson_id` de origen (útil para el seguimiento de errores).

## Variables de entorno (inyectadas por la plataforma)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` · usa el JWT del usuario (RLS).

## Petición
- **GET** `?lesson_id=<uuid>`. Requiere `Authorization: Bearer <jwt>` y `apikey`.

## Respuesta
```json
{ "data": { "lesson": { "…": "…" }, "screens": [ { "…": "…" } ], "questions": [ { "…": "…" } ] } }
```
Si la lección no existe: `{ "data": null }`.

## Errores
| HTTP | `error` | Causa |
|---|---|---|
| 400 | `missing_lesson_id` | Falta `lesson_id` |
| 401 | `missing_authorization` / `unauthorized` | Sin sesión válida |
| 405 | `method_not_allowed` | Método distinto de GET |
| 500 | `query_failed` | Error de consulta (ver `detail`) |

## Despliegue manual (lo hace el propietario)
```bash
supabase functions deploy certdeck-playable-lesson
```
