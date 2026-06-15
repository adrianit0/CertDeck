# ADR 0004 — Modelo de navegación: barra inferior + curso/etapa activos

- **Estado:** Aceptada
- **Fecha:** 2026-06-15
- **Fase:** Revisión de Requisitos 1.2.0
- **Relacionado:** [Requisitos](../02-requirements/requirements.md) §3.1, §3.11, §3.12, RN-27/28; [Constitución](../01-constitution/constitution.md) §10; [ADR 0003](0003-render-strategy.md)

## Contexto

La navegación inicial (catálogo de cursos → curso → etapa → tema → lecciones, en cascada) no encaja con el uso real: el estudiante prepara **un** curso durante semanas y quiere ir directo a estudiar, no reelegir curso cada vez. Además se busca una navegación móvil de una mano.

## Decisión

1. **Barra de navegación inferior persistente** con 4 pestañas: **Cursos**, **Repasos**, **Progresos**, **Perfil**.
2. **Curso activo y etapa actual por usuario**, persistentes hasta que el usuario los cambie. La pestaña **Cursos** entra directa al curso activo; arriba muestra **curso + etapa** como selectores (limitados a lo desbloqueado).
3. La pestaña Cursos carga el **catálogo de la etapa** completa: temas (mostrados como `[Nombre]`, sin resumen) con sus lecciones y estado. Pulsar el tema abre su contenido.
4. **Dentro de una lección** la barra inferior **se oculta** (modo concentración) y **todos los botones se anclan abajo** (RF-50/51).
5. **Persistencia del estado activo:** preferencia del usuario. En el MVP puede vivir en cliente (localStorage) y migrar a una tabla `certdeck_user_*` (p. ej. `certdeck_user_settings`) cuando se requiera multi-dispositivo. Decisión de almacenamiento definitivo pendiente para v2.

## Alternativas consideradas

1. **Cascada con catálogo de cursos cada vez.** Rechazada: fricción innecesaria para un uso mono-curso prolongado.
2. **Drawer lateral.** Rechazada: peor ergonomía a una mano que la barra inferior en móvil.
3. **Barra inferior + curso/etapa activos.** **Elegida.**

## Consecuencias

**Positivas:** acceso inmediato al estudio; navegación móvil cómoda; coherente con sesiones cortas.
**A tener en cuenta:**
- Hay que gestionar el "curso/etapa activo" y su cambio (con control de desbloqueo).
- Implica refactor de las pantallas ya creadas en v1 (catálogo, curso, tema) hacia el nuevo modelo.
- Con export estático (ADR 0003), las pestañas son rutas estáticas que leen estado/cliente; sin rutas dinámicas de servidor.

## Notas de implementación
- Pestañas como rutas: `/courses` (activo), `/reviews`, `/progress`, `/profile`.
- Estado activo en un contexto de cliente + persistencia (localStorage en MVP).
- La lección (`/lesson`) renderiza **sin** la barra inferior.
