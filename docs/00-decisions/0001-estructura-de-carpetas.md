# ADR 0001 — Estructura de carpetas: `docs/` y `supabase/`

- **Estado:** Aceptada
- **Fecha:** 2026-06-14
- **Fase:** 1 — Constitución
- **Decisores:** Propietario del proyecto

## Contexto

El prompt maestro de CertDeck prescribe una estructura de repositorio con dos carpetas concretas:

- `specs/` para la documentación de Spec Driven Development.
- `supabase-artifacts/` con subcarpetas `edge-functions/` y `sql/` para los artefactos de Supabase.

Sin embargo, el repositorio ya existía con un scaffold previo que usa una convención distinta:

- `docs/` (vacía) para documentación.
- `supabase/` con subcarpetas `functions/` y `sql/` (vacías) para artefactos.
- El archivo `.gitignore` ya hace referencia a rutas bajo `supabase/` (`supabase/.temp/`) y `app/`.

Esto crea un conflicto entre la estructura prescrita por el prompt y la estructura ya presente en el repositorio.

## Decisión

Se adopta la estructura **ya existente en el repositorio**:

- La documentación de Spec Driven Development vive en **`docs/`**, con **una carpeta numerada por documento** (`NN-nombre/nombre.md`): `01-constitution/`, `02-requirements/`, `03-roadmap/`, `04-tasks/`, `05-implementation/`, más las carpetas de apoyo `00-decisions/` (ADR), `06-referencias/` y `08-courses/`.
- Los artefactos de Supabase viven en **`supabase/`**:
  - Edge Functions nuevas en `supabase/functions/<nombre-funcion>/index.ts`.
  - Scripts SQL versionados en `supabase/sql/script-NNN.sql`.

Se mantienen intactas todas las demás reglas del prompt maestro (numeración incremental de SQL, no sobrescribir scripts, no tocar login/registro, etc.). El cambio es **únicamente de nombres de carpeta**, no de comportamiento.

## Alternativas consideradas

1. **Seguir el prompt al pie de la letra (`specs/`, `supabase-artifacts/`).** Rechazada: duplicaría carpetas con las ya creadas, desalinearía el `.gitignore` existente y obligaría a mantener dos convenciones.
2. **Híbrido (`specs/` para docs, `supabase/` para artefactos).** Rechazada: mezcla la convención del prompt con la del repo sin una ventaja clara.
3. **Adaptar al repo (`docs/`, `supabase/`).** **Elegida** por el propietario: aprovecha el scaffold existente, respeta el `.gitignore` actual y mantiene una única convención coherente.

## Consecuencias

**Positivas:**
- Una sola convención coherente con el repositorio y su `.gitignore`.
- Sin carpetas duplicadas ni vacías huérfanas.

**Negativas / a tener en cuenta:**
- Divergencia respecto a la nomenclatura literal del prompt maestro; toda referencia a `specs/` debe leerse como `docs/`, y `supabase-artifacts/` como `supabase/`.
- Esta equivalencia queda documentada en la Constitución (§12) y en este ADR para evitar confusiones futuras.

## Equivalencia de nombres (mapa rápido)

| Prompt maestro            | Repositorio (real) |
|---------------------------|--------------------|
| `specs/`                  | `docs/`            |
| `supabase-artifacts/`     | `supabase/`        |
| `supabase-artifacts/edge-functions/` | `supabase/functions/` |
| `supabase-artifacts/sql/` | `supabase/sql/`    |
