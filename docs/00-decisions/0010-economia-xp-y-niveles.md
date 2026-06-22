# ADR 0010 — Economía de XP y curva de niveles

- **Estado:** Aceptada
- **Fecha:** 2026-06-22
- **Fase:** 5 — Implementación
- **Decisores:** Propietario del proyecto
- **Relacionado:** [Constitución](../01-constitution/constitution.md) §4; [ADR 0006](0006-persistencia-progreso-en-bd.md) (progreso autoritativo en BD); `app/lib/xp.ts`, `app/lib/level.ts`; [script-009.sql](../../supabase/sql/script-009.sql); Edge Functions `certdeck-progress-complete-lesson`, `certdeck-progress-record-review`, `certdeck-exam-grade`

## Contexto

La XP anterior (`aciertos·50 + bonus`) crecía con el **número de preguntas**: una
lección larga daba mucha más XP que una corta, y la curva de nivel era lineal
(`floor(xp/1000)+1`), por lo que se subía de nivel con muy poca XP y sin techo.
Además, la XP se calculaba en el cliente y, aunque el servidor la recalculaba para
lecciones/repasos, el examen no otorgaba XP ni contaba como actividad.

## Decisión

1. **XP por sesión desacoplada del nº de preguntas** (`app/lib/xp.ts`):
   `xp = min(100, 50 + floor(score/2))` → base **50** + **1 XP por cada 2%** de
   acierto, **máximo 100**. **Repetir** una lección ya completada da el **20%**
   (80% menos), que se **acumula** sobre la XP previa de la lección (repetir nunca
   reduce la XP total).
2. **Blindaje autoritativo (Constitución §4):** la cantidad real la calcula la
   Edge Function correspondiente con esta misma fórmula replicada (patrón RT-03,
   como `srs.ts`); el cliente solo muestra un valor **optimista**. La condición de
   "repetición" se determina en **servidor** consultando el estado previo de la
   lección (no una bandera del cliente).
3. **Repaso y examen cuentan como "una lección más"** y otorgan XP con la misma
   fórmula. El examen registra ahora una **sesión** en `certdeck_user_exam_sessions`
   (script-009.sql), análoga a `certdeck_user_review_sessions`.
4. **Curva de niveles** (`app/lib/level.ts`): **99 niveles**;
   `xpForLevel(n) = 1.000.000 · ((n-1)/98)^2.2`. Exponente > 1 ⇒ los primeros
   niveles cuestan **muy poca** XP y el coste **se acelera** hasta **~1.000.000 XP**
   en el nivel 99. El nivel es una derivación **pura** de la XP total (que sí está
   blindada), por lo que no necesita validación adicional.

## Consecuencias

- La XP es justa y acotada (0–100 por sesión), independiente de la longitud.
- No se puede inflar la XP desde el front: el servidor manda.
- El "lessons completed" y la XP total agregan lecciones + repasos + exámenes.
- Requiere aplicar `script-009.sql` y redesplegar las 4 funciones afectadas
  (+`certdeck-progress-get`, que ahora expone `review.sessions` y `exam.sessions/xp`).
- Migración: la XP histórica guardada con la fórmula antigua queda como está; los
  niveles se recalculan con la nueva curva al leer la XP total (un usuario con XP
  alta acumulada podría ver su nivel reajustado, comportamiento aceptado).
