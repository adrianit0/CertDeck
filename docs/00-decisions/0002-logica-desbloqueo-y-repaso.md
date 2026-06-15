# ADR 0002 — Ubicación de la lógica de desbloqueo y repaso espaciado

- **Estado:** Aceptada — **parcialmente enmendada por [ADR 0006](0006-persistencia-progreso-en-bd.md)** (la "capa optimista local" pasa a ser optimista **en memoria**, sin persistencia en disco; la BD es la única fuente de verdad del progreso).
- **Fecha:** 2026-06-15
- **Fase:** 3 — Hoja de ruta (resuelve Q-05)
- **Decisores:** Propietario del proyecto
- **Relacionado:** [Constitución](../01-constitution/constitution.md) §3.5, §9; [Requisitos](../02-requirements/requirements.md) RN-04…RN-17, RSP-01…RSP-03; [ADR 0001](0001-estructura-de-carpetas.md)

## Contexto

CertDeck tiene dos clases de lógica sensibles para la integridad del producto:

1. **Desbloqueo de lecciones** (RF-35…RF-41, RN-04…RN-08): qué lecciones están `available` para un usuario.
2. **Repetición espaciada** (RN-13…RN-17, Q-03): cómo evolucionan `ease_factor`, `interval_days`, `repetitions`, `lapses` y `due_at` de cada tarjeta, y la selección de preguntas en lecciones de repaso/corrección.

La cuestión abierta Q-05 pregunta dónde debe vivir esa lógica: **cliente**, **Edge Function** o **SQL**. La Constitución establece dos principios que condicionan la respuesta:

- §3.5 *"No confiar en el frontend para validación crítica."*
- §9.5 *"Reglas de negocio sensibles … se implementan en SQL/Edge Functions cuando su integridad importe."*

Además, la experiencia debe ser **mobile-first y de respuesta inmediata** (RNF-02, RNF-06): el usuario no debería esperar a un ida y vuelta de red para ver feedback tras responder.

## Decisión

Se adopta un modelo **híbrido con backend autoritativo**:

1. **Cliente (optimista, no autoritativo):**
   - Calcula y muestra de inmediato el feedback del ejercicio (acierto/fallo, reencolado de tarjeta "Incorrecto" dentro de la lección).
   - Mantiene la lógica de repetición espaciada como **función pura testeable** en `app/lib/` para previsualizar el siguiente estado y ordenar la cola de la lección.
   - Calcula un estado de desbloqueo **provisional** para pintar la UI sin esperar al servidor.
   - **Nunca** es la fuente de verdad: cualquier valor que envíe se vuelve a validar en el backend.

2. **Backend (autoritativo):**
   - **Edge Functions nuevas** (TypeScript/Deno) concentran la lógica que decide y persiste:
     - `certdeck-progress-complete-lesson`: valida fin de lección, calcula `score_percentage`, persiste progreso y determina el desbloqueo real (RF-30, RF-35/36, RN-18/19).
     - `certdeck-spaced-review-update`: aplica el algoritmo SM-2 simplificado (Q-03) y persiste `user_spaced_repetition` de forma autoritativa (RN-13…RN-17).
     - `certdeck-review-build-lesson`: compone lecciones de repaso/generalistas a partir de tarjetas vencidas (`due_at <= now`) y la jerarquía `Pregunta → Lección → Tema → Etapa → Curso` (RF-42, RN-06).
   - La **misma lógica pura** del algoritmo se comparte conceptualmente entre cliente y Edge Function (mismos parámetros Q-03) para que la previsualización del cliente coincida con la decisión del servidor.

3. **Base de datos (guardarraíl):**
   - **RLS** garantiza que un usuario solo lee/escribe sus propias filas `user_*` (RSP-01, RNF-12), incluso si una Edge Function tuviera un fallo.
   - **Constraints** (CHECK/FK/NOT NULL) protegen los rangos válidos (p. ej. `ease_factor >= 1.3`, `score_percentage` 0–100) como última línea.
   - No se incrusta lógica de negocio compleja en triggers/PLpgSQL en el MVP (se prefiere mantenerla en Edge Functions, más fácil de testear en TS); la BD solo valida invariantes.

## Alternativas consideradas

1. **Todo en el cliente.** Rechazada: viola la Constitución §3.5; un usuario podría manipular su progreso/desbloqueo.
2. **Todo en SQL (triggers/funciones PLpgSQL).** Rechazada para el MVP: lógica crítica más difícil de testear y de versionar como código tipado; el algoritmo evoluciona y conviene tenerlo en TS. La BD se reserva para invariantes (RLS/constraints).
3. **Solo Edge Functions, sin cálculo en cliente.** Rechazada: penaliza la UX mobile-first (latencia perceptible tras cada respuesta).
4. **Híbrido con backend autoritativo.** **Elegida**: feedback inmediato + integridad garantizada.

## Consecuencias

**Positivas:**
- UX inmediata sin sacrificar integridad.
- Lógica crítica testeable (funciones puras en TS) y reutilizable cliente/servidor.
- Defensa en profundidad: Edge Function (decisión) + RLS/constraints (guardarraíl).

**Negativas / a tener en cuenta:**
- Posible **duplicación conceptual** del algoritmo (cliente y Edge Function): debe mantenerse sincronizado mediante parámetros compartidos y los mismos tests. Riesgo registrado como **RT-03** en el roadmap.
- El cliente puede mostrar un estado optimista que el servidor corrija (raro, pero hay que manejar la reconciliación: el servidor "gana").
- Requiere que el propietario **despliegue** las Edge Functions y aplique el SQL/RLS (Constitución §4): el agente solo entrega los archivos.

## Notas de implementación (para Fases 4–5)

- Centralizar parámetros del algoritmo (Q-03) en un único módulo de configuración en `app/lib/` y replicar esos valores en las Edge Functions, documentándolos como variables/constantes.
- El cliente envía "eventos" (respuesta a tarjeta, fin de lección); la Edge Function decide y devuelve el estado autoritativo (nuevo `due_at`, desbloqueos), que el cliente aplica.
- Tests unitarios obligatorios sobre la función pura del algoritmo y sobre la resolución de desbloqueo (RNF-09).
