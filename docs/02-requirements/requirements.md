# CertDeck — Requisitos

> Fase 2 del Spec Driven Development. Define **qué** debe hacer CertDeck (no el cómo). Se rige por la [Constitución](../01-constitution/constitution.md); en caso de conflicto, prevalece la Constitución. Los requisitos se identifican con códigos estables (`RF-`, `RNF-`, `HU-`, `RN-`) para poder trazarlos desde la hoja de ruta y las tareas.

- **Estado:** Aprobada (revisión mayor de UX, navegación y composición de lecciones)
- **Versión:** 1.2.0
- **Fecha:** 2026-06-14 · **Actualizada:** 2026-06-15
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
| **Ejercicio** | Interacción evaluable: tarjeta ANKI, test, verdadero/falso, respuesta escrita o examen. Ver [catálogo](../06-referencias/tipos-de-ejercicio.md). |
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

### 3.1 Estructura de la app y navegación

- **RF-01** La app tiene una **barra de navegación inferior** persistente con 4 pestañas: **Cursos**, **Repasos**, **Progresos**, **Perfil** (ver §3.11).
- **RF-02** El usuario tiene **un curso seleccionado** (lo elige una vez); ese curso permanece como activo hasta que el propio usuario decida cambiarlo. La pestaña **Cursos** muestra directamente el curso activo, **no** un catálogo para elegir cada vez.
- **RF-03** En la parte **superior** de la pestaña Cursos se muestran el **curso activo** y la **etapa actual**; el usuario puede **cambiar** cualquiera de los dos en cualquier momento, **siempre que esté desbloqueado**.
- **RF-04** La pestaña Cursos carga el **catálogo completo de la etapa** activa: todos sus **temas** y, dentro de cada tema, sus **lecciones** con su estado (bloqueada/disponible/en progreso/completada).
- **RF-05** Cada **tema** se muestra como una cabecera con **solo su nombre** (formato `[Nombre del tema]`) seguida de sus lecciones. **No** se muestra el resumen del tema en el listado; al **pulsar el tema** se accede a leer su contenido.
- **RF-06** Solo se muestra contenido con `is_published = true`; el contenido no publicado nunca es visible para el estudiante.
- **RF-06b** El usuario puede **cambiar de curso** (selector en pestaña Cursos o en Perfil) y **cambiar de etapa** desde el selector superior, limitado a lo que tenga desbloqueado.

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
- **RF-15** Si pulsa **Incorrecto**: la tarjeta se marca como fallada en la **pasada principal** y entrará en la **ronda de corrección** al terminar (ver §3.6bis); se actualiza su estado de repaso (RN de repetición espaciada).
- **RF-16** Si pulsa **Correcto**: se programa una revisión futura con intervalo moderado.
- **RF-17** Si pulsa **Muy fácil**: se programa con un intervalo mayor.
- **RF-18** Los tres botones **Incorrecto / Correcto / Muy fácil** se muestran con el **mismo ancho** y **anclados en la parte inferior** de la pantalla (RF-50/RF-51).

### 3.4 Ejercicio — Pregunta de tres respuestas (test)

- **RF-19** Se muestra una pregunta con tres respuestas; solo una es correcta.
- **RF-20** Las respuestas se muestran **siempre en orden aleatorio**.
- **RF-21** El acierto/fallo se registra; tras responder se puede mostrar la explicación.

### 3.5 Ejercicio — Verdadero / Falso

- **RF-22** Se muestra una afirmación; el usuario responde Verdadero o Falso.
- **RF-23** El acierto/fallo se registra; tras responder se muestra una explicación breve.

### 3.5bis Ejercicio — Respuesta escrita (`text_input`)

> Tipo pensado **casi exclusivamente** para respuestas de **1 palabra** o **1 número**. Ver el [catálogo de tipos de ejercicio](../06-referencias/tipos-de-ejercicio.md).

- **RF-23a** Se muestra una pregunta con un **input de texto** y, debajo, **un hueco por cada letra** de la respuesta (el usuario ve cuántas letras tiene).
- **RF-23b** La comprobación es **tolerante**: ignora mayúsculas/minúsculas y espacios sobrantes, y **sustituye tildes y diacríticos** en **ambas** respuestas (correcta y del usuario) antes de comparar — p. ej., con respuesta `España`, el usuario que escriba ` éspanA` **acierta** (alguien sin "ñ" puede usar "n").
- **RF-23c** Si el usuario **falla la primera vez**, en la corrección se le revela **una letra** como pista (p. ej. `_ E _ _ _ _ _ _`) y puede **reintentar una vez**; si acertó a la primera cuenta como correcto, si necesitó la pista queda registrado como fallo para repasos/errores.

### 3.6 Ejercicio — Preguntas de examen ("lecciones de preguntas")

- **RF-24** Existe un catálogo especial de preguntas de examen (más difíciles), almacenado en `certdeck_exam_questions`.
- **RF-25** Las **lecciones de preguntas** son exámenes preparados específicamente para cada ocasión. **En el MVP no se cargan datos de examen por SQL todavía**, pero la **base (tabla, tipos, UI) debe quedar preparada**.
- **RF-26** Existe una sección específica para **practicar preguntas de examen** directamente.
- **RF-27** Tipos de examen: respuesta única (`type_id = 1`) y respuesta múltiple (`type_id = 2`).
- **RF-28** Internamente la respuesta correcta es `answer_1` (única) y, en múltiple, las primeras `correct_answers_count`. El frontend **siempre desordena** y **nunca** revela el orden interno.
- **RF-29** En respuesta múltiple, el acierto solo cuenta si el usuario selecciona exactamente el conjunto correcto de respuestas.

### 3.6bis Ronda de corrección de fallos (dentro de la lección)

- **RF-29a** Una lección se hace en **una pasada principal**: todas las preguntas, una vez, en orden.
- **RF-29b** Al terminar la pasada principal, **si hubo fallos**, se muestra una **pantalla motivacional** (p. ej. *"Vamos a corregir las preguntas incorrectas"*) y empieza la **ronda de corrección**: se vuelven a preguntar **solo las falladas**.
- **RF-29c** En la ronda de corrección, si el usuario **acierta**, la pregunta se da por **recuperada** (en tarjetas ANKI se marca correcta según el algoritmo, RN-14).
- **RF-29d** Si en la ronda de corrección **vuelve a fallar**, esa pregunta **no se vuelve a preguntar en esta lección**, pero queda **registrada como incorrecta** para mostrarse en el futuro en lecciones de **repaso**, de **errores** y otros lugares.
- **RF-29e** El resultado de la lección refleja aciertos/fallos tras la lógica anterior (cada pregunta cuenta una vez; la recuperación en corrección cuenta como acierto).

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

### 3.9 Composición de lecciones de repaso, errores y finales

> **Principio clave (simplifica la creación de contenido):** **solo las lecciones `normal`** (y, en el futuro, las "lecciones de preguntas"/examen) **tienen preguntas propias**. Las lecciones de **repaso**, **errores** y **finales** **no crean preguntas nuevas**: se **componen en tiempo de ejecución reciclando** preguntas ya existentes que el usuario ya ha visto. Esto evita duplicar contenido y refuerza el aprendizaje.

- **RF-42** **Repaso de este tema:** incluye **únicamente preguntas ya realizadas hasta ese momento** pertenecientes a **este tema** (recicladas de sus lecciones normales de origen). No se crean preguntas nuevas.
- **RF-43** **Repaso general:** incluye **50% preguntas de este tema + 50% de temas anteriores** (de entre las ya vistas por el usuario), para no oxidarse.
- **RF-44** **Errores de este tema:** incluye preguntas de **este tema** que el usuario **respondió mal**. Cuando una pregunta fallada se responde correctamente, se marca como correcta según el algoritmo ANKI (RN-14). **Si no hay preguntas falladas**, la lección funciona como un **repaso de este tema** (RF-42).
- **RF-44b** **Errores generales:** **50% preguntas falladas de este tema + 50% falladas de otros temas**. **Si no hay falladas**, funciona como un **repaso general** (RF-43).
- **RF-45** **Lección final:** incluye **preguntas al azar del tema** que el usuario ya ha hecho.
- **RF-45b** Las lecciones de **ampliación** (`expansion`) profundizan en contenido ya aprendido con preguntas más difíciles (fuera del alcance inmediato del MVP; base reservada).

### 3.10 Reutilización de preguntas

- **RF-46** Una pregunta vive **una sola vez** (en su lección normal de origen) y se **recicla** en repasos, errores y finales mediante la jerarquía `Pregunta → Lección → Tema → Etapa → Curso` y el historial de intentos del usuario, **sin duplicar contenido** ni crear preguntas nuevas en esas lecciones.

### 3.11 Pestañas de navegación inferior

- **RF-47** **Cursos:** curso/etapa activos arriba (cambiables si desbloqueados) + catálogo de la etapa (temas y lecciones). Punto de entrada al estudio.
- **RF-48** **Repasos:** acceso bajo demanda a sesiones de **repaso de tema**, **repaso general**, **errores de tema** y **errores generales** (compuestas según §3.9).
- **RF-49** **Progresos:** avance del usuario (lecciones completadas, métricas, por tema/etapa/curso).
- **RF-49b** **Perfil:** datos de cuenta, preferencias y **cambiar de curso**.

### 3.12 Lección a pantalla completa y disposición de controles

- **RF-50** Al **entrar en una lección**, la barra de navegación inferior **se oculta** (modo concentración).
- **RF-51** Dentro de una lección, **todos los botones se anclan en la parte inferior** de la pantalla (el usuario no tiene que subir el dedo a la parte superior).
- **RF-52** El **contenido** de las lecciones usa una **fuente algo más grande** y queda **repartido/espaciado** a lo largo de la pantalla (no amontonado arriba).
- **RF-53** El texto de contenido soporta **negrita con `**…**`** (Markdown): los dobles asteriscos se renderizan en **negrita** dentro de la app.

### 3.13 Reporte de errores en tarjetas (asistencia técnica)

> Decisión del propietario (2026-06-16). Ver [ADR 0008](../00-decisions/0008-reporte-de-errores-en-tarjetas.md).

- **RF-54** **Todas las tarjetas** de pregunta (flashcards de lección/repaso y preguntas de examen) muestran **arriba** un **botón de asistencia técnica** para reportar un problema con la tarjeta.
- **RF-55** Al pulsarlo se abre un **mini-popup** con: (a) un **combo de motivo** (`Bug`, `Falta de ortografía`, `Respuesta incorrecta`, `Pregunta confusa`, `Otro`) y (b) un **campo de detalle** de texto libre **opcional**.
- **RF-56** Al enviar, el reporte se **persiste** (tabla `user_question_reports`, vía la Edge Function `certdeck-report-create`) junto con la referencia de la pregunta (id + origen `flashcard`/`exam`), su contexto (lección/curso) y una **instantánea del enunciado**. El usuario recibe **confirmación** inmediata.
- **RF-57** Los reportes se **almacenan para gestión posterior** del propietario (revisar/corregir/descartar); su `status` (`open`/`reviewing`/`resolved`/`dismissed`) lo administra el propietario, no el usuario final.

---

## 4. Requisitos no funcionales (RNF)

### 4.1 Plataforma y rendimiento
- **RNF-01** Mobile-first: la experiencia se diseña primero para móvil (app híbrida vía Capacitor).
- **RNF-02** Sesiones cortas: una lección típica se completa en pocos minutos; la UI carga rápido y sin bloqueos perceptibles.
- **RNF-03** La app funciona como web (Next.js) y empaquetada con Capacitor sin reescritura de lógica.
- **RNF-17** **Caché de contenido en cliente** (ADR 0009): el catálogo de un curso (etapas + temas + lecciones) se guarda localmente y, al arrancar, solo se vuelve a descargar si un endpoint ligero de **versión** (`certdeck-content-version`) indica que cambió. Reduce el tiempo de carga cuando el contenido es voluminoso y estable. La caché solo guarda **contenido público de solo lectura** (nunca progreso del usuario; el progreso sigue la regla del ADR 0006).

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

- **HU-01** — *Como estudiante, quiero tener un curso ya seleccionado al abrir Cursos para ir directo a estudiar.* (RF-02, RF-03)
  - CA: la pestaña Cursos muestra mi curso activo y la etapa actual arriba, cambiables si están desbloqueados.
- **HU-02** — *Como estudiante, quiero ver el catálogo completo de la etapa (temas y lecciones) para orientarme.* (RF-04, RF-05)
  - CA: cada tema aparece como `[Nombre]` con sus lecciones y estado; al pulsar el tema accedo a su contenido.
- **HU-03** — *Como estudiante, quiero moverme por Cursos/Repasos/Progresos/Perfil con una barra inferior.* (RF-01, RF-47–RF-49b)
  - CA: la barra inferior está siempre visible salvo dentro de una lección.
- **HU-04** — *Como estudiante, quiero estudiar una lección con contenido y ejercicios para aprender de forma activa.* (RF-07, RF-08, RF-09)
  - CA: primero contenido, luego ejercicios; puedo avanzar uno a uno; los botones están abajo.
- **HU-05** — *Como estudiante, quiero autoevaluarme con tarjetas ANKI para fijar conceptos.* (RF-13–RF-18)
  - CA: revelo el reverso y elijo Incorrecto/Correcto/Muy fácil (mismo ancho, abajo); los fallos van a la ronda de corrección.
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
- **HU-15** — *Como estudiante, quiero corregir mis fallos al terminar la lección para afianzar lo que no sé.* (RF-29a–RF-29e)
  - CA: tras la pasada principal, si fallé, aparece una pantalla motivacional y repito solo las falladas; al segundo fallo no se repiten, pero quedan registradas.
- **HU-16** — *Como estudiante, quiero lecciones de repaso/errores (de tema y generales) sin contenido nuevo, reciclando lo ya visto.* (RF-42–RF-45, RF-48)
  - CA: repasos y errores se componen de mis preguntas ya vistas/falladas; si no hay fallos, los de errores actúan como repaso.
- **HU-17** — *Como estudiante, quiero concentrarme en la lección sin distracciones.* (RF-50–RF-53)
  - CA: dentro de la lección no hay barra inferior, los botones están abajo, la fuente es legible y la negrita se ve.
- **HU-18** — *Como estudiante, quiero cambiar de curso cuando yo quiera.* (RF-06b, RF-49b)
  - CA: puedo cambiar el curso activo desde Cursos o Perfil; permanece hasta que lo cambie.

---

## 6. Reglas de negocio (RN)

### 6.1 Generales
- **RN-01** El contenido se organiza estrictamente como Curso → Etapa → Tema → Lección → (pantallas, ejercicios).
- **RN-02** El orden dentro de cada nivel lo determina el campo `position`.
- **RN-03** Solo el contenido `is_published = true` es visible para el estudiante.

### 6.2 Desbloqueo
- **RN-04** Una lección está `available` si es la primera marcada como inicial o si su lección anterior requerida está `completed`.
- **RN-05** Una lección de repaso requiere completar el conjunto de lecciones previas que cubre.
- **RN-06** Debe existir un repaso **cada 3 lecciones** y **un repaso generalista al cierre de cada tema** (decidido en Q-04; cadencia configurable).
- **RN-07** Una corrección de errores puede activarse automáticamente cuando el `score_percentage` de una lección queda **por debajo del 60%** (umbral configurable; decidido en Q-01).
- **RN-08** El campo `unlock_rule` de la lección puede declarar condiciones explícitas de desbloqueo (extensible).

### 6.3 Ejercicios y evaluación
- **RN-09** Las respuestas de test, V/F y examen se muestran siempre en orden aleatorio.
- **RN-09b** Las **preguntas** de una lección **no tienen `position`**: se extraen todas al empezar y se presentan en **orden aleatorio**. Las preguntas tampoco tienen `difficulty` (se prima la calidad sobre forzar un reparto por dificultad).
- **RN-09c** En `text_input`, la comprobación normaliza ambas respuestas (mayúsculas, espacios, tildes/diacríticos) antes de comparar; el primer fallo da una pista de una letra y permite un reintento (RF-23a…RF-23c).
- **RN-10** En examen, la correcta es `answer_1` (única) o las primeras `correct_answers_count` (múltiple); el orden interno nunca se expone.
- **RN-11** En examen múltiple, se cuenta acierto solo con selección exactamente igual al conjunto correcto.
- **RN-12** Una pregunta puede reutilizarse en varias lecciones mediante la jerarquía, sin duplicarla.

### 6.4 Repetición espaciada (algoritmo, tipo SM-2 simplificado)

Cada tarjeta mantiene por usuario: `ease_factor`, `interval_days`, `repetitions`, `lapses`, `due_at`, `last_reviewed_at`.

- **RN-13 (Incorrecto):**
  - La pregunta queda marcada para la **ronda de corrección** de la lección (no se reencola de inmediato; ver RF-29a…RF-29e).
  - `lapses += 1`.
  - `ease_factor` disminuye en **0.2**, sin bajar de un mínimo de **1.3** (decidido en Q-03).
  - `interval_days` se reinicia a 0.
  - Si acumula **3 fallos** (histórico), se marca como **tarjeta problemática** (decidido en Q-02).
- **RN-14 (Correcto):**
  - `repetitions += 1`.
  - Intervalo con progresión moderada. Orientativo: 1.ª correcta → 1 día; 2.ª → 3 días; 3.ª → 7 días; siguientes → `interval_days_anterior × ease_factor`.
  - Se programa `due_at` a fecha futura.
- **RN-15 (Muy fácil):**
  - `repetitions += 1`.
  - `ease_factor` aumenta ligeramente.
  - Intervalo crece más rápido. Orientativo: 1.ª → 3 días; 2.ª → 7 días; siguientes → `interval_days_anterior × factor_superior`.
- **RN-16:** Los parámetros deben ser **ajustables** sin reescribir la lógica. **Valores por defecto (Q-03):** `ease_factor` inicial 2.5, mínimo 1.3; Correcto: pasos iniciales 1/3/7 días y luego `interval × ease_factor`; Muy fácil: pasos 3/7 días, `ease_factor += 0.15` y factor de crecimiento superior; Incorrecto: `interval = 0` y `ease_factor -= 0.2`.
- **RN-17 (Ronda de corrección):** Una lección tiene **una pasada principal** + **una ronda de corrección** de las falladas. En la corrección: acierto → recuperada (acierto, marca correcta ANKI); segundo fallo → no se repite más en esta lección y queda **registrada como incorrecta** para repasos/errores futuros. Así se evita la frustración sin ocultar el fallo.

### 6.5 Progreso
- **RN-18** Estados de lección: `locked`, `available`, `in_progress`, `completed`.
- **RN-19** Al completar una lección se calcula `score_percentage = correct / (correct + incorrect)` y se almacena `completed_at`.
- **RN-20** Cada intento de pregunta se registra con `was_correct`, `selected_answer`, `attempt_number`, `exercise_type` y `question_source`.

### 6.6 Composición de lecciones (repaso / errores / finales)
> Ver [ADR 0005](../00-decisions/0005-composicion-dinamica-de-lecciones.md). **Solo `normal` (y examen) tienen preguntas propias**; el resto se compone reciclando.
- **RN-21** El **pool de reciclaje** de un usuario son las preguntas que **ya ha visto** (con intento registrado), recuperables por la jerarquía `Pregunta → Lección → Tema → Etapa → Curso`.
- **RN-22** **Repaso de tema** = preguntas ya vistas de **ese tema**. **Repaso general** = 50% del tema actual + 50% de temas anteriores.
- **RN-23** **Errores de tema** = preguntas de **ese tema** con último intento incorrecto; si no hay, se comporta como **repaso de tema**. **Errores generales** = 50% falladas del tema + 50% falladas de otros temas; si no hay, se comporta como **repaso general**.
- **RN-24** **Final** = selección **al azar** de preguntas del tema que el usuario ya ha hecho.
- **RN-25** Una pregunta fallada deja de considerarse "error" cuando se responde correctamente (transición gestionada por el algoritmo ANKI, RN-14).
- **RN-26** Las "**lecciones de preguntas**" (examen) usan `certdeck_exam_questions`; base preparada, **sin datos por SQL en el MVP** (RF-25).

### 6.7 Navegación y app shell
- **RN-27** Existe **un curso activo** y una **etapa actual** por usuario, persistentes hasta que el usuario los cambie (RF-02/RF-03). El cambio de etapa/curso se limita a lo **desbloqueado**.
- **RN-28** La **barra inferior** (Cursos/Repasos/Progresos/Perfil) es persistente **salvo dentro de una lección**, donde se oculta (RF-50).

---

## 7. Flujo de navegación

```txt
App (barra inferior persistente: Cursos · Repasos · Progresos · Perfil)
│
├─ Cursos
│   ├─ [arriba] Curso activo + Etapa actual (cambiables si desbloqueados)
│   └─ Catálogo de la etapa:
│        [Tema 1]  (solo nombre; al pulsar → leer contenido)
│          ├─ Lección 1 … (estado)
│          └─ …
│        [Tema 2] …
│            └─ Lección  ──► (entra en modo lección: barra inferior OCULTA)
│                 ├─ Pantallas de contenido (fuente mayor, espaciada, **negrita**)
│                 ├─ Pasada principal de ejercicios (ANKI / test / V-F)
│                 ├─ (si hubo fallos) Pantalla motivacional → Ronda de corrección
│                 └─ Resultado ──► (desbloqueo) siguiente lección
│
├─ Repasos  → Repaso de tema · Repaso general · Errores de tema · Errores generales
├─ Progresos → avance por tema/etapa/curso
└─ Perfil    → cuenta, preferencias, cambiar de curso
```

---

## 8. Flujo de aprendizaje (dentro de una lección)

> Al entrar en la lección se **oculta la barra inferior** (RF-50) y **todos los botones quedan abajo** (RF-51). El contenido va con **fuente mayor y espaciado** (RF-52) y **`**negrita**`** renderizada (RF-53).

1. Si la lección tiene pantallas de contenido → mostrarlas en orden, una a una.
2. **Pasada principal:** presentar los ejercicios en orden, una vez cada uno.
   - ANKI: frontal → revelar → Incorrecto/Correcto/Muy fácil (mismo ancho, abajo) → actualizar repaso.
   - Test / V-F: opciones desordenadas → responder → feedback + explicación → registrar intento.
   - Examen: opciones desordenadas → responder (única/múltiple) → feedback + `extra_information` → registrar intento.
   - Las falladas se apuntan para la corrección.
3. **Ronda de corrección:** si hubo fallos → pantalla motivacional → repreguntar solo las falladas.
   - Acierto → recuperada (acierto). Segundo fallo → no se repite; queda registrada como incorrecta para repasos/errores futuros (RF-29a…e, RN-17).
4. Pantalla de **resultado** (% aciertos/fallos, felicitación, siguiente).
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
> Catálogo detallado (propiedades y funcionamiento) en [docs/06-referencias/tipos-de-ejercicio.md](../06-referencias/tipos-de-ejercicio.md).

| Código (`exercise_type`) | Descripción | Origen (`question_source`) |
|---|---|---|
| `anki_card` | Tarjeta frontal/reverso con autoevaluación | `flashcard` |
| `multiple_choice` | Test de 3 respuestas, 1 correcta | `flashcard` |
| `true_false` | Verdadero/Falso con explicación | `flashcard` |
| `text_input` | Respuesta escrita (1 palabra/número), comprobación tolerante + pista | `flashcard` |
| `exam_single` | Examen respuesta única | `exam` |
| `exam_multiple` | Examen respuesta múltiple | `exam` |

### 10.2 Tipos de lección
| Código (`lesson_type`) | Tiene preguntas propias | Propósito / composición |
|---|---|---|
| `normal` | **Sí** | Introduce contenido nuevo + sus ejercicios autoría |
| `review` | No (reciclada) | Repaso de tema (preguntas ya vistas del tema) o general (50% tema + 50% temas previos) — RF-42/43 |
| `error_correction` | No (reciclada) | Errores de tema o generales; si no hay fallos, actúa como repaso — RF-44/44b |
| `final` | No (reciclada) | Preguntas al azar del tema ya hecho — RF-45 |
| `expansion` | No (reservado) | Profundización; base reservada, fuera del MVP inmediato |
| (examen) | **Sí** (catálogo aparte) | "Lecciones de preguntas": `certdeck_exam_questions`; base preparada, sin datos por SQL en MVP — RF-25 |

---

## 11. Gestión de progreso y de errores del usuario

> **Nota de nomenclatura (Constitución §7/§12.2):** todas las tablas reales llevan el prefijo **`certdeck_`**. En este documento los nombres se citan sin prefijo por brevedad; en SQL son `certdeck_courses`, `certdeck_lessons`, `certdeck_user_lesson_progress`, etc.

- **Progreso:** se persiste en `user_lesson_progress` (estado, score, conteos, `completed_at`), `user_question_attempts` (cada intento) y `user_spaced_repetition` (estado por tarjeta).
- **Errores del usuario:** cada fallo queda registrado como intento (`was_correct = false`) y, en tarjetas, afecta a `lapses`/condición problemática; esto alimenta lecciones de corrección y la selección de repasos.
- **Antifrustración:** fallar repetidamente una tarjeta dentro de una lección no impide terminarla, pero el sistema recuerda el fallo para reforzarlo más adelante (RN-17).
- **Reportes de error de contenido:** los reportes que el usuario envía desde una tarjeta se guardan en `user_question_reports` (privados del usuario que los crea, RLS), para que el propietario revise y corrija el contenido (RF-54…57, ADR 0008). No forman parte del progreso ni del repaso espaciado.

---

## 12. Requisitos de seguridad y privacidad

- **RSP-01** Toda tabla `user_*` lleva RLS que restringe acceso al `user_id` del propietario de los datos.
- **RSP-02** El contenido educativo puede ser de lectura pública/autenticada; el progreso es estrictamente privado.
- **RSP-03** Validación de datos en backend (Edge Functions / constraints SQL); no se confía solo en el cliente.
- **RSP-04** No exponer respuestas correctas de forma insegura cuando sea evitable (RNF-14).
- **RSP-05** Las claves sensibles no se incrustan en el cliente ni en el repositorio.
- **RSP-06** No se modifican login/registro ni su CORS (restricción crítica de la Constitución).
- **RSP-07** La arquitectura queda preparada para funciones premium/multiusuario sin comprometer el aislamiento por usuario.
- **RSP-08** Los **reportes de error** (`user_question_reports`) llevan RLS: cada usuario solo crea y consulta los suyos (`auth.uid() = user_id`); el alta pasa por la Edge Function `certdeck-report-create` (validación en servidor, RSP-03) y la gestión/resolución es responsabilidad del propietario (service_role).

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

**Cuestiones resueltas (aprobadas el 2026-06-15 en Fase 3):**
- **Q-01 ✅** Corrección de errores se activa con `score_percentage < 60%` (ver RN-07).
- **Q-02 ✅** Tarjeta problemática a partir de **3 fallos** (ver RN-13/RN-17).
- **Q-03 ✅** Parámetros por defecto del algoritmo espaciado fijados (ver RN-16).
- **Q-04 ✅** Repaso **cada 3 lecciones** + generalista al cierre de cada tema (ver RN-06).
- **Q-05 ✅** Lógica de desbloqueo/repaso **híbrida**: cálculo optimista en cliente + validación/persistencia autoritativa en Edge Functions + RLS (ver [ADR 0002](../00-decisions/0002-logica-desbloqueo-y-repaso.md)).
- **Q-06 ✅** La práctica directa de examen **no** altera `user_spaced_repetition` en el MVP (registra intentos); revisable en v3.

**Decisiones de la revisión 1.2.0 (2026-06-15):**
- **Navegación con barra inferior + curso/etapa activos** (ver [ADR 0004](../00-decisions/0004-modelo-de-navegacion.md)).
- **Composición dinámica de lecciones de repaso/errores/finales** reciclando preguntas ya vistas; solo `normal`/examen tienen preguntas propias (ver [ADR 0005](../00-decisions/0005-composicion-dinamica-de-lecciones.md)).
- **Ronda de corrección** en lugar de reencolado inmediato (RF-29a…e, RN-17).

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
| 1.1.0 | 2026-06-15 | Integradas las decisiones Q-01…Q-06 (RN-06, RN-07, RN-13, RN-16, §16). Estado: aprobada. |
| 1.2.0 | 2026-06-15 | Revisión mayor: barra de navegación inferior (Cursos/Repasos/Progresos/Perfil), curso/etapa activos (§3.1, RN-27/28, ADR 0004); tema solo nombre sin resumen (RF-05); ronda de corrección (§3.6bis, RN-17); composición dinámica de repaso/errores/finales reciclando preguntas, solo `normal`/examen con preguntas propias (§3.9, RN-21…26, ADR 0005); lección a pantalla completa con botones abajo, fuente mayor y Markdown negrita (§3.12, RF-50…53). |
| 1.3.0 | 2026-06-15 | Limpieza del modelo de juego: lecciones sin `estimated_minutes`; preguntas flashcard sin `position` (orden aleatorio) ni `difficulty` (RN-09b). Nuevo tipo de ejercicio **`text_input`** (respuesta escrita con comprobación tolerante y pista) (§3.5bis, RF-23a…c, RN-09c, §10.1) y nuevo [catálogo de tipos de ejercicio](../06-referencias/tipos-de-ejercicio.md). SQL: `script-004.sql`. |
| 1.4.0 | 2026-06-16 | **Reporte de errores en tarjetas** (asistencia técnica): botón en todas las tarjetas + mini-popup con combo de motivo y detalle libre; persistencia para gestión posterior del propietario (§3.13, RF-54…57, RSP-08, §11; ADR 0008). SQL: `script-007.sql`; Edge Function: `certdeck-report-create`. |
| 1.5.0 | 2026-06-16 | **Caché de contenido en cliente** (RNF-17, ADR 0009): el catálogo del curso se guarda en local y solo se redescarga si cambia el token de versión que devuelve `certdeck-content-version`. SQL: `script-008.sql` (función `certdeck_course_catalog_version`). |
