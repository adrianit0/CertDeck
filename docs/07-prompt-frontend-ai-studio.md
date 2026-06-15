# CertDeck — Prompt para generar el frontend con Google AI Studio

> Prompt maestro para construir el **frontend completo (prototipo navegable, mobile-first)** de CertDeck
> en Google AI Studio. Está derivado de la [Constitución](01-constitution.md), los
> [Requisitos](02-requirements.md) y el [Catálogo de tipos de ejercicio](06-tipos-de-ejercicio.md).
>
> **Estado:** Referencia · **Fecha:** 2026-06-15
>
> ## Notas de uso
> - Google AI Studio genera un **prototipo con datos mock**; **no** se conecta a Supabase ni respeta la
>   estructura `app/features/...` de la Constitución (§8/§12). Sirve para **diseñar la UI y el estilo**.
> - Tras generarlo, hay que **portar** los componentes al árbol Next.js + Capacitor y enchufar las
>   queries reales (`app/lib/queries/content.ts`).
> - Copia el bloque de abajo tal cual en Google AI Studio.

---

```
Eres un diseñador de producto y desarrollador frontend senior. Construye el frontend completo
(prototipo navegable, mobile-first) de una app llamada **CertDeck**.

## Qué es CertDeck
App de estudio de certificaciones técnicas (AWS, ciberseguridad, cloud, programación) basada en
memorización espaciada estilo ANKI. Convierte temarios densos en sesiones cortas, motivadoras y
repetibles. Jerarquía del contenido: Curso → Etapa → Tema → Lección → (pantallas de contenido +
ejercicios). El usuario estudia un curso activo, avanza con desbloqueo progresivo y repasa con un
algoritmo espaciado.

## Stack y restricciones técnicas
- React + TypeScript estricto (sin `any`), pensado para empaquetarse luego con Next.js + Capacitor.
- Estilo con Tailwind CSS. Componentes modulares, con responsabilidad única y nombres descriptivos.
- TODO con DATOS MOCK realistas en memoria (no hay backend en este prototipo). Estructura los mocks
  para que sea fácil sustituirlos luego por llamadas a Supabase. No inventes login: asume usuario ya
  autenticado y entra directo a la app.
- Mobile-first absoluto: diseña primero para móvil (ancho ~390px) y escala a desktop centrando el
  contenido en una columna tipo móvil. Pensado para usarse con una mano.

## Estilo visual (MODERNO)
- Estética limpia, motivadora y actual: tarjetas con esquinas redondeadas (rounded-2xl), sombras
  suaves, mucho espacio en blanco, micro-animaciones y transiciones suaves al cambiar de pantalla,
  revelar tarjetas y dar feedback.
- Paleta: azules y celestes sobre blanco. Azul primario vibrante (~#2563EB), celeste de apoyo
  (~#38BDF8), fondos casi blancos (#F8FAFC), texto gris azulado oscuro. Verde para acierto, rojo para
  error, ámbar para estados "en progreso"/pista.
- Tipografía sans-serif moderna (Inter o similar), buena jerarquía, números grandes para métricas.
- Iconos grandes y botones grandes con área táctil cómoda. Contraste WCAG AA. Nada que dependa de hover.
- Estados de carga (skeletons) y de error siempre visibles. Modo claro (puedes dejar preparado oscuro).

## Arquitectura de navegación
Barra de navegación inferior PERSISTENTE con 4 pestañas: **Cursos**, **Repasos**, **Progresos**, **Perfil**.
La barra inferior SE OCULTA al entrar en una lección (modo concentración / pantalla completa).

### Pestaña CURSOS (pantalla principal)
- Cabecera superior: muestra el **curso activo** y la **etapa actual**, ambos cambiables si están
  desbloqueados (selector/dropdown). NO es un catálogo para elegir cada vez; el curso persiste.
- Debajo: catálogo de la etapa activa. Lista de **Temas**; cada tema es una cabecera con SOLO su
  nombre en formato `[Nombre del tema]` (al pulsar el tema se accede a leer su contenido). Bajo cada
  tema, sus **lecciones** con su estado visual:
  - `locked` (bloqueada, con candado y atenuada, no pulsable)
  - `available` (disponible, destacada como siguiente acción)
  - `in_progress` (en progreso, con barra/indicador)
  - `completed` (completada, con check)
- Tipos de lección visibles con icono/color distinto: normal, review (repaso), error_correction
  (corrección de errores), final, expansion.

### Pestaña REPASOS
Acceso bajo demanda a 4 sesiones, presentadas como tarjetas grandes:
Repaso de tema · Repaso general · Errores de tema · Errores generales. Cada una con descripción
breve y nº de preguntas disponibles. Lanzan una lección compuesta (mismo reproductor).

### Pestaña PROGRESOS
Avance del usuario: anillos/barras de progreso por curso/etapa/tema, lecciones completadas, % de
aciertos, tarjetas pendientes/vencidas (due). Métricas con números grandes y visual motivador.

### Pestaña PERFIL
Datos de cuenta, preferencias y opción de **cambiar de curso activo**.

## Reproductor de lección (pantalla completa, sin barra inferior)
Reglas clave de UX dentro de la lección:
- TODOS los botones anclados en la PARTE INFERIOR de la pantalla (el usuario no sube el dedo arriba).
- Cuando hay un grupo de botones, mismo ancho entre ellos.
- El texto de contenido usa una fuente ALGO MÁS GRANDE y queda repartido/espaciado a lo largo de la
  pantalla (no amontonado arriba). Soporta **negrita Markdown** (`**texto**` → negrita).
- Barra de progreso superior fina mostrando avance dentro de la lección. Botón de salir (X).

Flujo de una lección:
1. **Pantallas de contenido** (si las tiene): se muestran en orden, una a una, con botón "Continuar" abajo.
2. **Pasada principal de ejercicios**: todos los ejercicios una vez, en orden. Las respuestas (test/
   V-F) SIEMPRE en orden aleatorio. Feedback inmediato tras responder. Las falladas se apuntan.
3. **Ronda de corrección**: si hubo fallos, pantalla motivacional ("Vamos a corregir las preguntas
   incorrectas") y se repreguntan SOLO las falladas. Acierto → recuperada; segundo fallo → no se
   repite y queda registrada como incorrecta.
4. **Pantalla de resultado**: % de aciertos, % de fallos, felicitación motivadora, y la siguiente
   acción (siguiente lección desbloqueada si procede).

## Tipos de ejercicio (implementa los 4)
1. **anki_card** (Tarjeta ANKI): se muestra el frontal; el usuario pulsa para REVELAR el reverso (con
   animación de giro/flip). Tras revelar, 3 botones anclados abajo con MISMO ANCHO:
   **Incorrecto · Correcto · Muy fácil** (rojo / azul / verde-celeste).
2. **multiple_choice** (Test): enunciado + 3 opciones barajadas, 1 correcta. Tras responder, marca en
   verde la correcta y en rojo la elegida si falló, y muestra la explicación.
3. **true_false** (Verdadero/Falso): afirmación + 2 botones grandes Verdadero/Falso. Feedback +
   explicación breve tras responder.
4. **text_input** (Respuesta escrita, 1 palabra/número): enunciado + un input de texto y, debajo, UN
   HUECO POR CADA LETRA de la respuesta (el usuario ve cuántas letras tiene, p. ej. `_ _ _ _ _ _ _ _`).
   Comprobación tolerante (ignora mayúsculas, espacios y tildes/diacríticos). Si falla a la primera,
   en la corrección se revela UNA letra como pista (p. ej. `_ E _ _ _ _ _ _`) y permite UN reintento.
   Acierto a la primera = correcto; si necesitó la pista, se cierra como incorrecto mostrando la
   respuesta correcta y la explicación.

Para acierto/fallo no dependas solo del color: añade icono y texto (accesibilidad).

## Modelo de datos para los mocks (usa estos tipos TypeScript)
type LessonType = "normal" | "review" | "error_correction" | "expansion" | "final";
type ExerciseType = "anki_card" | "multiple_choice" | "true_false" | "text_input";
type LessonStatus = "locked" | "available" | "in_progress" | "completed";

interface Course   { id: string; title: string; slug: string; description: string|null; icon: string|null; color: string|null; difficulty: number; }
interface Stage    { id: string; course_id: string; title: string; description: string|null; position: number; }
interface Topic    { id: string; stage_id: string; title: string; description: string|null; summary: string|null; position: number; }
interface Lesson   { id: string; topic_id: string; title: string; description: string|null; lesson_type: LessonType; position: number; status: LessonStatus; }
interface LessonScreen { id: string; lesson_id: string; title: string|null; body: string; position: number; }
interface FlashcardQuestion { id: string; lesson_id: string; exercise_type: ExerciseType; question: string; correct_answer: string; incorrect_answer_1: string|null; incorrect_answer_2: string|null; explanation: string|null; }

Crea datos mock realistas del curso "AWS SAA-C03": 1 curso, 1-2 etapas, varios temas, y cada tema
con varias lecciones (mezcla de normal/review/error_correction/final y los 4 estados de lección).
Incluye lecciones con pantallas de contenido (con algo de **negrita** en el texto) y preguntas de los
4 tipos de ejercicio, con explicaciones reales sobre conceptos AWS (S3, EC2, VPC, IAM, etc.).

## Entregable
App React + TypeScript navegable y pulida visualmente, con las 4 pestañas, el reproductor de lección
completo con los 4 tipos de ejercicio, ronda de corrección y pantalla de resultado, todo con datos
mock. Prioriza una primera impresión visual moderna e impecable y transiciones suaves.
```
