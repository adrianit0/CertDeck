# Edge Function: `certdeck-playable-lesson`

Lección reproducible: la lección + sus pantallas de teoría + sus preguntas activas (solo lectura). El orden de las preguntas lo decide el reproductor (aleatorio), no la base de datos.

> **Función NUEVA y autocontenida** (Constitución §4). El agente no la despliega.

## Composición de preguntas por tipo de lección (ADR 0005 + v2.2, repetición espaciada)
- **`normal`** → sus propias `certdeck_flashcard_questions`.
- **`review`** → hasta **6** tarjetas de las **lecciones anteriores del mismo tema**, priorizando las **vencidas** (`due_at <= now`) según `certdeck_user_spaced_repetition`.
- **`final`** → hasta **8** tarjetas de **todo el tema**, misma priorización por vencimiento.
- **`error_correction`** → hasta **6** tarjetas del tema con **problemas** (`lapses > 0` o problemática); si no hay falladas, degrada a **repaso del tema** (RF-44).

**Priorización (SM-2):** se ordenan las tarjetas por `due_at` ascendente (las vistas y más vencidas primero) y las nunca vistas al final (con desempate aleatorio). Así, en una primera pasada sin historial se comporta como selección aleatoria, y con uso real prioriza lo que toca repasar.

Las lecciones `review`/`final`/`error_correction` **no almacenan preguntas propias**: se reciclan en runtime. Cada pregunta conserva su `lesson_id` de origen. Reemplaza al modo **posicional** anterior (decisión del propietario 2026-06-16).

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
