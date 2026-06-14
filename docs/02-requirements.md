# CertDeck — Requisitos

> Fase 2 del Spec Driven Development. Define **qué** debe hacer CertDeck (no el cómo). Se rige por la [Constitución](01-constitution.md); en caso de conflicto, prevalece la Constitución. Los requisitos se identifican con códigos estables (`RF-`, `RNF-`, `HU-`, `RN-`) para poder trazarlos desde la hoja de ruta y las tareas.

- **Estado:** Borrador para aprobación (Fase 2)
- **Versión:** 1.0.0
- **Fecha:** 2026-06-14
- **Fase Spec Driven Development:** 2 — Requisitos
- **Depende de:** Fase 1 (Constitución, aprobada)

---

## 1. Glosario

| Término | Definición |
|---|---|
| **Curso** | Unidad de aprendizaje de máximo nivel (p. ej. "AWS SAA-C03"). |
| **Etapa** | Agrupación de temas dentro de un curso. |
| **Tema** | Conjunto de lecciones sobre un área concreta. |
| **Lección** | Unidad mínima de estudio; contiene pantallas de contenido y ejercicios. |
| **Pantalla de contenido** | Bloque explicativo dentro de una lección, mostrado poco a poco. |
| **Ejercicio** | Interacción evaluable: tarjeta ANKI, test, verdadero/falso o examen. |
| **Tarjeta (flashcard)** | Ejercicio frontal/reverso con autoevaluación (Incorrecto/Correcto/Muy fácil). |
| **Repaso** | Lección que reutiliza preguntas previas según el algoritmo espaciado. |
| **Corrección de errores** | Lección centrada en preguntas que el usuario falló. |
| **Repetición espaciada** | Algoritmo (tipo SM-2 simplificado) que programa cuándo volver a mostrar una tarjeta. |
| **Tarjeta problemática** | Tarjeta fallada repetidamente; se marca para reforzarla. |
| **Due / vencida** | Tarjeta cuya fecha de revisión (`due_at`) ya ha llegado. |

---

## 2. Actores

- **Estudiante (usuario autenticado):** actor principal; estudia cursos y acumula progreso. Único rol del MVP en la app.
- **Propietario / Administrador de contenido:** crea y carga contenido (cursos, lecciones, preguntas) y gestiona Supabase. Fuera del alcance de UI en el MVP (carga vía SQL/datos seed por el propietario).
- **Sistema CertDeck:** aplica reglas de desbloqueo, repaso y progreso.

> Autenticación: login y registro **ya existen** (Edge Functions compartidas) y no se modifican. CertDeck consume la sesión resultante.

---

## 3. Requisitos funcionales (RF)

### 3.1 Catálogo y navegación de contenido

- **RF-01** El usuario puede ver el catálogo de cursos publicados (título, icono, color, dificultad, descripción).
- **RF-02** El usuario puede abrir el detalle de un curso y ver sus etapas publicadas, en orden (`position`).
- **RF-03** El usuario puede abrir una etapa y ver sus temas publicados, en orden.
- **RF-04** El usuario puede abrir un tema y ver: (a) su resumen en varias pantallas y (b) la lista de lecciones del tema con su estado (bloqueada/disponible/en progreso/completada).
- **RF-05** El resumen del tema muestra toda la información del tema repartida en pantallas, aunque ese contenido se vaya enseñando poco a poco dentro de las lecciones.
- **RF-06** Solo se muestra contenido con `is_published = true`; el contenido no publicado nunca es visible para el estudiante.

### 3.2 Lecciones

- **RF-07** El usuario puede iniciar una lección **disponible**.
- **RF-08** Una lección muestra primero sus pantallas de contenido (si las tiene), en orden, una a una.
- **RF-09** Tras el contenido, la lección presenta sus ejercicios en orden.
- **RF-10** El sistema soporta los tipos de lección: `normal`, `review`, `error_correction`, `expansion`, `final`.
- **RF-11** El usuario puede abandonar una lección a medias; el sistema guarda el estado `in_progress` y permite reanudar.
- **RF-12** Al terminar todos los ejercicios, el sistema muestra la **pantalla de resultado** (ver RF-30).

### 3.3 Ejercicio — Tarjeta tipo ANKI

- **RF-13** Se muestra el frontal de la tarjeta; el usuario intenta recordar el reverso y pulsa para revelarlo.
- **RF-14** Tras revelar, aparecen tres botones: **Incorrecto**, **Correcto**, **Muy fácil**.
- **RF-15** Si pulsa **Incorrecto**: la tarjeta se reencola al final de la lección actual y se actualiza su estado de repaso (ver RN de repetición espaciada).
- **RF-16** Si pulsa **Correcto**: se programa una revisión futura con intervalo moderado.
- **RF-17** Si pulsa **Muy fácil**: se programa con un intervalo mayor.
- **RF-18** Si el usuario falla repetidamente la misma tarjeta dentro de una lección, se da por válida para no bloquear la experiencia, **pero** se marca como tarjeta problemática para futuras revisiones.

### 3.4 Ejercicio — Pregunta de tres respuestas (test)

- **RF-19** Se muestra una pregunta con tres respuestas; solo una es correcta.
- **RF-20** Las respuestas se muestran **siempre en orden aleatorio**.
- **RF-21** El acierto/fallo se registra; tras responder se puede mostrar la explicación.

### 3.5 Ejercicio — Verdadero / Falso

- **RF-22** Se muestra una afirmación; el usuario responde Verdadero o Falso.
- **RF-23** El acierto/fallo se registra; tras responder se muestra una explicación breve.

### 3.6 Ejercicio — Preguntas de examen

- **RF-24** Existe un catálogo especial de preguntas de examen (más difíciles).
- **RF-25** Las preguntas de examen pueden aparecer en lecciones normales, repasos y lecciones finales.
- **RF-26** Existe una sección específica para **practicar preguntas de examen** directamente.
- **RF-27** Tipos de examen: respuesta única (`type_id = 1`) y respuesta múltiple (`type_id = 2`).
- **RF-28** Internamente la respuesta correcta es `answer_1` (única) y, en múltiple, las primeras `correct_answers_count`. El frontend **siempre desordena** y **nunca** revela el orden interno.
- **RF-29** En respuesta múltiple, el acierto solo cuenta si el usuario selecciona exactamente el conjunto correcto de respuestas.

### 3.7 Resultado y progreso

- **RF-30** Al completar una lección se muestra: porcentaje de aciertos, porcentaje de fallos, felicitación y la siguiente acción (desbloqueo si procede).
- **RF-31** El sistema guarda el progreso por lección (`status`, `score_percentage`, `correct_count`, `incorrect_count`, `completed_at`).
- **RF-32** El sistema registra cada intento de pregunta (`user_question_attempts`) con tipo de ejercicio, origen, acierto y respuesta seleccionada.
- **RF-33** El sistema mantiene el estado de repetición espaciada por tarjeta y usuario (`user_spaced_repetition`).
- **RF-34** El usuario puede ver una pantalla de **progreso** con su avance por curso/tema y métricas básicas (lecciones completadas, tarjetas pendientes/vencidas).

### 3.8 Desbloqueo

- **RF-35** La primera lección de un curso/tema puede estar disponible desde el inicio.
- **RF-36** Una lección normal se desbloquea al completar la anterior.
- **RF-37** Una lección de repaso se desbloquea al completar las lecciones requeridas previas.
- **RF-38** Cada 2 o 3 lecciones existe una lección de repaso.
- **RF-39** Al menos una vez por tema existe un repaso generalista.
- **RF-40** Si hay temas anteriores, el repaso generalista puede incluir preguntas de temas previos; si no, solo de lecciones anteriores del tema actual.
- **RF-41** Una lección de corrección de errores puede desbloquearse automáticamente tras bajo rendimiento.

### 3.9 Repaso y corrección

- **RF-42** Las lecciones de repaso seleccionan preguntas según el algoritmo (tarjetas vencidas / pendientes) y la jerarquía `Pregunta → Lección → Tema → Etapa → Curso`.
- **RF-43** Las lecciones de corrección de errores priorizan preguntas que el usuario falló previamente.
- **RF-44** Las lecciones de ampliación profundizan en contenido ya aprendido y pueden incluir preguntas más difíciles.
- **RF-45** Las lecciones finales cierran tema/etapa/curso con repaso amplio y pueden incluir preguntas de examen.

### 3.10 Reutilización de preguntas

- **RF-46** Una `flashcard_question` ligada a una lección puede ser reutilizada por repasos, correcciones, ampliaciones y lecciones finales mediante la relación jerárquica, sin duplicar el contenido.

---

## 4. Requisitos no funcionales (RNF)

### 4.1 Plataforma y rendimiento
- **RNF-01** Mobile-first: la experiencia se diseña primero para móvil (app híbrida vía Capacitor).
- **RNF-02** Sesiones cortas: una lección típica se completa en pocos minutos; la UI carga rápido y sin bloqueos perceptibles.
- **RNF-03** La app funciona como web (Next.js) y empaquetada con Capacitor sin reescritura de lógica.

### 4.2 Usabilidad y accesibilidad
- **RNF-04** Contraste de texto y controles objetivo **WCAG AA**.
- **RNF-05** Iconos y botones grandes, con área táctil cómoda; nada dependiente de hover.
- **RNF-06** Feedback inmediato tras cada respuesta (estado + explicación cuando aplique).
- **RNF-07** Paleta azul/celeste/blanco, estética limpia y motivadora, navegación consistente.

### 4.3 Mantenibilidad y calidad
- **RNF-08** TypeScript estricto en frontend y Edge Functions; sin `any` no justificado.
- **RNF-09** Lógica crítica (repetición espaciada, desbloqueo) implementada como funciones puras y testeadas.
- **RNF-10** SQL versionado en archivos numerados nuevos; nunca se sobrescriben los previos.

### 4.4 Seguridad y privacidad (resumen; detalle en §12)
- **RNF-11** El progreso de un usuario es privado; nadie puede leer/escribir el progreso de otro.
- **RNF-12** RLS activa en todas las tablas `user_*`.
- **RNF-13** No se confía en el frontend para validación crítica de integridad.

### 4.5 Fiabilidad y datos
- **RNF-14** Las respuestas correctas no se exponen al cliente antes de que el usuario responda, cuando sea evitable.
- **RNF-15** El progreso se persiste de forma consistente; reanudar una lección no pierde estado ya guardado.

### 4.6 Internacionalización (futuro)
- **RNF-16** La arquitectura no impide añadir idiomas más adelante (MVP en español).

---

## 5. Historias de usuario (HU)

> Formato: *Como [actor], quiero [acción] para [beneficio].* Cada HU enlaza con RF y se acompaña de criterios de aceptación (CA).

- **HU-01** — *Como estudiante, quiero ver el catálogo de cursos para elegir qué estudiar.* (RF-01)
  - CA: veo solo cursos publicados con título, icono, color y dificultad; puedo abrir cualquiera.
- **HU-02** — *Como estudiante, quiero navegar curso → etapa → tema → lecciones para orientarme en el temario.* (RF-02, RF-03, RF-04)
  - CA: cada nivel muestra sus hijos en orden; cada lección muestra su estado.
- **HU-03** — *Como estudiante, quiero ver el resumen del tema para tener una visión global.* (RF-05)
  - CA: el resumen se presenta en varias pantallas navegables.
- **HU-04** — *Como estudiante, quiero estudiar una lección con contenido y ejercicios para aprender de forma activa.* (RF-07, RF-08, RF-09)
  - CA: primero contenido, luego ejercicios; puedo avanzar uno a uno.
- **HU-05** — *Como estudiante, quiero autoevaluarme con tarjetas ANKI para fijar conceptos.* (RF-13–RF-18)
  - CA: revelo el reverso y elijo Incorrecto/Correcto/Muy fácil; "Incorrecto" reencola la tarjeta.
- **HU-06** — *Como estudiante, quiero responder preguntas test y V/F con explicación para entender mis errores.* (RF-19–RF-23)
  - CA: respuestas desordenadas; tras responder veo si acerté y la explicación.
- **HU-07** — *Como estudiante, quiero practicar preguntas de examen para prepararme para la certificación.* (RF-24–RF-29)
  - CA: hay sección de práctica directa; en múltiple acierto solo con el conjunto exacto; nunca veo el orden interno.
- **HU-08** — *Como estudiante, quiero ver el resultado al acabar una lección para saber cómo voy.* (RF-30)
  - CA: veo % aciertos/fallos, felicitación y la siguiente lección si se desbloquea.
- **HU-09** — *Como estudiante, quiero que las lecciones se desbloqueen progresivamente para seguir un camino claro.* (RF-35–RF-41)
  - CA: no puedo entrar a una lección bloqueada; al completar la anterior se desbloquea la siguiente.
- **HU-10** — *Como estudiante, quiero lecciones de repaso periódicas para no olvidar lo aprendido.* (RF-37–RF-40, RF-42)
  - CA: cada 2–3 lecciones hay un repaso; el repaso usa preguntas vencidas/previas.
- **HU-11** — *Como estudiante, quiero lecciones de corrección de mis fallos para reforzar mis puntos débiles.* (RF-41, RF-43)
  - CA: tras bajo rendimiento se ofrece/desbloquea una corrección centrada en mis fallos.
- **HU-12** — *Como estudiante, quiero reanudar una lección a medias para estudiar en ratos cortos.* (RF-11)
  - CA: si salgo, al volver continúo donde lo dejé.
- **HU-13** — *Como estudiante, quiero ver mi progreso general para mantener la motivación.* (RF-34)
  - CA: veo avance por curso/tema, lecciones completadas y tarjetas vencidas/pendientes.
- **HU-14** — *Como estudiante, quiero que mi progreso sea privado para sentirme seguro.* (RNF-11, RNF-12)
  - CA: no es posible acceder al progreso de otro usuario.

---

## 6. Reglas de negocio (RN)

### 6.1 Generales
- **RN-01** El contenido se organiza estrictamente como Curso → Etapa → Tema → Lección → (pantallas, ejercicios).
- **RN-02** El orden dentro de cada nivel lo determina el campo `position`.
- **RN-03** Solo el contenido `is_published = true` es visible para el estudiante.

### 6.2 Desbloqueo
- **RN-04** Una lección está `available` si es la primera marcada como inicial o si su lección anterior requerida está `completed`.
- **RN-05** Una lección de repaso requiere completar el conjunto de lecciones previas que cubre.
- **RN-06** Debe existir un repaso cada 2–3 lecciones y al menos un repaso generalista por tema.
- **RN-07** Una corrección de errores puede activarse automáticamente cuando el `score_percentage` de una lección queda por debajo de un umbral configurable (valor por defecto a fijar en Fase 3/4).
- **RN-08** El campo `unlock_rule` de la lección puede declarar condiciones explícitas de desbloqueo (extensible).

### 6.3 Ejercicios y evaluación
- **RN-09** Las respuestas de test, V/F y examen se muestran siempre en orden aleatorio.
- **RN-10** En examen, la correcta es `answer_1` (única) o las primeras `correct_answers_count` (múltiple); el orden interno nunca se expone.
- **RN-11** En examen múltiple, se cuenta acierto solo con selección exactamente igual al conjunto correcto.
- **RN-12** Una pregunta puede reutilizarse en varias lecciones mediante la jerarquía, sin duplicarla.

### 6.4 Repetición espaciada (algoritmo, tipo SM-2 simplificado)

Cada tarjeta mantiene por usuario: `ease_factor`, `interval_days`, `repetitions`, `lapses`, `due_at`, `last_reviewed_at`.

- **RN-13 (Incorrecto):**
  - La tarjeta se reencola al final de la lección actual.
  - `lapses += 1`.
  - `ease_factor` disminuye ligeramente, sin bajar de un mínimo razonable (p. ej. 1.3).
  - `interval_days` se reduce o reinicia.
  - Si acumula varios fallos, se marca como **tarjeta problemática**.
- **RN-14 (Correcto):**
  - `repetitions += 1`.
  - Intervalo con progresión moderada. Orientativo: 1.ª correcta → 1 día; 2.ª → 3 días; 3.ª → 7 días; siguientes → `interval_days_anterior × ease_factor`.
  - Se programa `due_at` a fecha futura.
- **RN-15 (Muy fácil):**
  - `repetitions += 1`.
  - `ease_factor` aumenta ligeramente.
  - Intervalo crece más rápido. Orientativo: 1.ª → 3 días; 2.ª → 7 días; siguientes → `interval_days_anterior × factor_superior`.
- **RN-16:** Los parámetros (mínimos, multiplicadores, umbrales, "varios fallos") deben ser **ajustables** sin reescribir la lógica (configuración documentada en Fase 3/4).
- **RN-17:** Si el usuario falla repetidamente una tarjeta dentro de una lección, se da por válida para terminar la lección, pero el registro de error/condición problemática se conserva para repasos y correcciones.

### 6.5 Progreso
- **RN-18** Estados de lección: `locked`, `available`, `in_progress`, `completed`.
- **RN-19** Al completar una lección se calcula `score_percentage = correct / (correct + incorrect)` y se almacena `completed_at`.
- **RN-20** Cada intento de pregunta se registra con `was_correct`, `selected_answer`, `attempt_number`, `exercise_type` y `question_source`.

---

## 7. Flujo de navegación

```txt
Inicio
 └─ Catálogo de cursos
     └─ Detalle de curso
         └─ Etapas del curso
             └─ Temas de la etapa
                 └─ Detalle/Resumen de tema  ──(pantallas de resumen)
                     └─ Lecciones del tema
                         └─ Lección
                             ├─ Pantallas de contenido
                             └─ Ejercicios (ANKI / test / V-F / examen)
                                 └─ Resultado de lección ──> (desbloqueo) siguiente lección

Accesos transversales:
 - Progreso del usuario
 - Práctica directa de preguntas de examen
```

---

## 8. Flujo de aprendizaje (dentro de una lección)

1. Si la lección tiene pantallas de contenido → mostrarlas en orden, una a una.
2. Presentar ejercicios en orden.
3. Por cada ejercicio:
   - ANKI: mostrar frontal → revelar reverso → Incorrecto/Correcto/Muy fácil → actualizar repaso; si "Incorrecto", reencolar al final.
   - Test / V-F: mostrar opciones desordenadas → responder → feedback + explicación → registrar intento.
   - Examen: mostrar opciones desordenadas → responder (única/múltiple) → feedback + `extra_information` → registrar intento.
4. Al vaciar la cola de ejercicios (incluidas las tarjetas reencoladas) → pantalla de resultado.
5. Calcular y persistir progreso; aplicar desbloqueo y posibles activaciones (corrección por bajo rendimiento).

---

## 9. Flujo de desbloqueo de lecciones

```txt
¿Es lección inicial del tema/curso?            → SÍ → available
        │ NO
¿La lección previa requerida está completed?    → NO → locked
        │ SÍ
¿Es lección de repaso?                          → SÍ → ¿completadas las lecciones que cubre? → SÍ available / NO locked
        │ NO
available

Tras completar una lección:
 - persistir progreso (status=completed, score, completed_at)
 - desbloquear siguiente(s) según reglas
 - si score < umbral → activar/ofrecer lección de corrección de errores
```

---

## 10. Tipos de ejercicio y de lección (referencia)

### 10.1 Tipos de ejercicio
| Código (`exercise_type`) | Descripción | Origen (`question_source`) |
|---|---|---|
| `anki_card` | Tarjeta frontal/reverso con autoevaluación | `flashcard` |
| `multiple_choice` | Test de 3 respuestas, 1 correcta | `flashcard` |
| `true_false` | Verdadero/Falso con explicación | `flashcard` |
| `exam_single` | Examen respuesta única | `exam` |
| `exam_multiple` | Examen respuesta múltiple | `exam` |

### 10.2 Tipos de lección
| Código (`lesson_type`) | Propósito |
|---|---|
| `normal` | Introduce contenido nuevo + ejercicios |
| `review` | Repaso espaciado de preguntas previas (cada 2–3 lecciones; generalista por tema) |
| `error_correction` | Refuerzo de preguntas falladas; activable por bajo rendimiento |
| `expansion` | Profundiza en contenido ya aprendido; preguntas más difíciles |
| `final` | Cierre de tema/etapa/curso; repaso amplio + posibles preguntas de examen |

---

## 11. Gestión de progreso y de errores del usuario

- **Progreso:** se persiste en `user_lesson_progress` (estado, score, conteos, `completed_at`), `user_question_attempts` (cada intento) y `user_spaced_repetition` (estado por tarjeta).
- **Errores del usuario:** cada fallo queda registrado como intento (`was_correct = false`) y, en tarjetas, afecta a `lapses`/condición problemática; esto alimenta lecciones de corrección y la selección de repasos.
- **Antifrustración:** fallar repetidamente una tarjeta dentro de una lección no impide terminarla, pero el sistema recuerda el fallo para reforzarlo más adelante (RN-17).

---

## 12. Requisitos de seguridad y privacidad

- **RSP-01** Toda tabla `user_*` lleva RLS que restringe acceso al `user_id` del propietario de los datos.
- **RSP-02** El contenido educativo puede ser de lectura pública/autenticada; el progreso es estrictamente privado.
- **RSP-03** Validación de datos en backend (Edge Functions / constraints SQL); no se confía solo en el cliente.
- **RSP-04** No exponer respuestas correctas de forma insegura cuando sea evitable (RNF-14).
- **RSP-05** Las claves sensibles no se incrustan en el cliente ni en el repositorio.
- **RSP-06** No se modifican login/registro ni su CORS (restricción crítica de la Constitución).
- **RSP-07** La arquitectura queda preparada para funciones premium/multiusuario sin comprometer el aislamiento por usuario.

---

## 13. Requisitos de accesibilidad

- **RA-01** Contraste AA en texto y controles.
- **RA-02** Áreas táctiles amplias (botones/iconos grandes).
- **RA-03** Foco visible y orden de foco lógico.
- **RA-04** Etiquetas accesibles en controles interactivos.
- **RA-05** No depender exclusivamente del color para transmitir estado (acierto/fallo también con icono/texto).
- **RA-06** Independencia de hover (interacción táctil primero).

---

## 14. Requisitos mobile-first

- **RM-01** Diseño primero para móvil; escalado a pantallas mayores.
- **RM-02** Navegación pensada para una mano y sesiones cortas.
- **RM-03** Compatibilidad con empaquetado Capacitor (sin depender de APIs de navegador no disponibles en móvil).
- **RM-04** Tiempos de carga percibidos mínimos; estados de carga/errores siempre visibles.

---

## 15. Fuera de alcance (MVP)

- UI de administración/creación de contenido (la carga la hace el propietario por SQL/seed).
- Gamificación avanzada (rachas, logros, ligas) más allá de la felicitación de resultado.
- Modo offline completo / sincronización avanzada.
- Pagos y funciones premium (solo se deja la arquitectura preparada).
- Multi-idioma de contenido (solo preparado, no implementado).

> El detalle de qué entra exactamente en el MVP frente a iteraciones posteriores se concreta en la Fase 3 (Hoja de ruta).

---

## 16. Supuestos y cuestiones abiertas

**Supuestos:**
- La sesión de usuario autenticado está disponible vía las Edge Functions de login/registro existentes.
- El propietario cargará contenido de ejemplo (seed) para poder validar los flujos.

**Cuestiones abiertas (a resolver en Fase 3/4):**
- **Q-01** Umbral exacto de "bajo rendimiento" que activa corrección de errores (RN-07).
- **Q-02** Definición de "varios fallos" para marcar tarjeta problemática (RN-13/RN-17).
- **Q-03** Valores por defecto definitivos del algoritmo espaciado (mínimo `ease_factor`, multiplicadores, factor "Muy fácil") (RN-16).
- **Q-04** Cadencia exacta de repasos (¿cada 2 o cada 3?) y composición del repaso generalista.
- **Q-05** ¿La lógica de desbloqueo/repaso se calcula en cliente, en Edge Function o en SQL? (decisión de arquitectura, Fase 3 + ADR).
- **Q-06** ¿La práctica directa de examen afecta al estado de repetición espaciada o es independiente?

---

## 17. Criterios de aceptación de los Requisitos (Fase 2)

Esta fase se considera **aprobada** cuando el propietario confirma que:
1. Los requisitos funcionales cubren todo el alcance deseado del producto.
2. Las reglas de negocio (especialmente desbloqueo y repetición espaciada) son correctas.
3. Los flujos de navegación, aprendizaje y desbloqueo reflejan la experiencia buscada.
4. Los requisitos no funcionales, de accesibilidad, mobile-first y seguridad son adecuados.
5. El alcance fuera del MVP y las cuestiones abiertas son aceptables para abordarse en Fase 3.

> Hasta la aprobación, no se avanza a la Fase 3 (Hoja de ruta).

---

## 18. Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-14 | Versión inicial de Requisitos (Fase 2). Pendiente de aprobación. |
