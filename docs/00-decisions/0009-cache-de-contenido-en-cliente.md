# ADR 0009 — Caché de contenido del curso en cliente con token de versión

- **Estado:** Aceptada
- **Fecha:** 2026-06-16
- **Fase:** 5 — Implementación
- **Decisores:** Propietario del proyecto
- **Relacionado:** [Requisitos](../02-requirements/requirements.md) RNF-17; [Constitución](../01-constitution/constitution.md) §4/§7; [ADR 0006](0006-persistencia-progreso-en-bd.md) (el progreso NO se cachea en disco); [script-008.sql](../../supabase/sql/script-008.sql); Edge Function `certdeck-content-version`

## Contexto

El catálogo de un curso (etapas → temas → lecciones) se carga en cada arranque:
`certdeck-stages-with-topics` + **N** llamadas `certdeck-lessons-by-topic` (una por
tema). A medida que se añade contenido —que es el caso deseado— esa carga inicial
se vuelve **lenta**. Pero el contenido de un curso, una vez creado, **apenas
cambia**. Es un candidato claro a caché.

Restricción importante: el **ADR 0006** estableció que el **progreso del usuario**
NO se cachea en disco (la BD es la única fuente de verdad). Ese ADR aplica a datos
de usuario, no al **contenido educativo**, que es público y de solo lectura.

## Decisión

1. **Cachear el catálogo del curso** (etapas + temas + lecciones) en
   `localStorage`, junto a un **token de versión** (`app/lib/cache/contentCache.ts`).
2. Añadir un **endpoint ligero de versión**, `certdeck-content-version`, que
   devuelve un token calculado por la función SQL `certdeck_course_catalog_version`
   (script-008.sql). El token combina el **max `updated_at`** del curso y sus
   etapas/temas/lecciones con un **recuento de filas**, de modo que detecta
   **ediciones, altas y bajas**.
3. **Flujo de arranque** (en `AppShell`): se pide primero el token; si coincide con
   el guardado, se usa la **caché** y se evitan las descargas pesadas; si difiere
   (o no hay caché), se descarga el catálogo y se reescribe la caché con el token.
4. **Degradación:** si el token no se puede obtener (offline) pero hay caché, se
   usa la caché; si la descarga falla y hay caché previa, también se cae a ella.
5. La función SQL se ejecuta **como el usuario** (security invoker): la RLS aplica
   y el token cuenta solo contenido **publicado**, coherente con lo que se cachea.

## Alcance y límites

- Solo se cachea el **catálogo** (estructura). Las **pantallas y preguntas** de una
  lección (`certdeck-playable-lesson`) se siguen pidiendo al abrir la lección: es
  una sola llamada puntual y así reflejan ediciones de contenido sin invalidar la
  caché del catálogo.
- El token se basa en curso/etapas/temas/lecciones (no en preguntas), para
  maximizar los aciertos de caché del catálogo.

## Alternativas consideradas

1. **Sin caché (estado actual).** Rechazada: carga inicial lenta con mucho contenido.
2. **Caché con expiración por tiempo (TTL).** Rechazada: o caduca de más (descargas
   innecesarias) o sirve contenido viejo; el token de versión es exacto.
3. **ETag/If-None-Match HTTP por recurso.** Más estándar, pero exige soporte de
   cabeceras condicionales por endpoint y no encaja con el patrón actual de Edge
   Functions; el token explícito es más simple y suficiente.
4. **Bundle único de todo el catálogo en una sola función.** Útil para acelerar el
   *cache miss*, pero ortogonal a esta decisión; puede abordarse aparte.

## Consecuencias

**Positivas:** arranque casi instantáneo cuando el contenido no cambia; una sola
llamada ligera por curso en el caso común; mejor experiencia offline (cae a caché);
sin tocar el modelo de progreso (ADR 0006 intacto).

**A tener en cuenta:**
- `localStorage` tiene cuota (~5 MB); si falla la escritura se ignora y se sigue
  yendo a red. Para catálogos muy grandes podría migrarse a IndexedDB / Capacitor
  Preferences en el futuro.
- El token cuenta contenido publicado: publicar/despublicar una etapa o lección
  cambia el token y refresca la caché (correcto).
