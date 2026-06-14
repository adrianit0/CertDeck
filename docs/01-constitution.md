# CertDeck — Constitución del Proyecto

> **Documento maestro de gobernanza.** Establece las reglas no negociables del proyecto. Toda fase posterior (requisitos, hoja de ruta, tareas, implementación) y todo el código generado deben respetar este documento. En caso de conflicto entre cualquier artefacto y esta Constitución, **prevalece la Constitución**, salvo que el propietario apruebe explícitamente una excepción documentada en `docs/decisions/`.

- **Estado:** Aprobada
- **Versión:** 1.3.0
- **Fecha:** 2026-06-14 · **Aprobada:** 2026-06-14 · **Actualizada:** 2026-06-15
- **Fase Spec Driven Development:** 1 — Constitución
- **Aprobación requerida antes de continuar a Fase 2 (Requisitos):** Sí (concedida)

---

## 1. Visión del producto

**CertDeck** es una aplicación de aprendizaje **mobile-first** orientada al estudio de certificaciones de **ciberseguridad, cloud, programación y tecnología** mediante **memorización espaciada** inspirada en ANKI.

El producto convierte temarios densos de certificación en sesiones cortas, motivadoras y repetibles, organizadas jerárquicamente y con desbloqueo progresivo, de modo que el usuario consolide conocimiento a largo plazo en lugar de memorizar a corto plazo.

**Propuesta de valor:**

- Aprendizaje estructurado: Curso → Etapa → Tema → Lección → Ejercicios.
- Refuerzo mediante repetición espaciada (algoritmo tipo SM-2 simplificado).
- Sesiones cortas optimizadas para móvil.
- Feedback inmediato y progreso visible.
- Repasos y correcciones automáticas basadas en el rendimiento real del usuario.

**Para quién:** personas que preparan certificaciones técnicas (p. ej. AWS, seguridad, programación) y quieren estudiar en cualquier momento desde el móvil.

---

## 2. Principios de producto

1. **Mobile-first siempre.** Todo se diseña primero para móvil; el escritorio es secundario.
2. **Sesiones cortas.** Una lección debe poder completarse en pocos minutos.
3. **Feedback inmediato.** El usuario sabe al instante si acertó o falló, con explicación.
4. **Progresión guiada.** El usuario nunca queda perdido: siempre hay una "siguiente acción" clara.
5. **Motivación sin frustración.** Si el usuario falla repetidamente una pregunta dentro de una lección, no se le bloquea; se marca el error para reforzarlo después.
6. **Memoria a largo plazo, no atajos.** El sistema prioriza la consolidación mediante repaso espaciado.
7. **Contenido reutilizable.** Una pregunta vive una vez y se reutiliza en repasos, correcciones, ampliaciones y lecciones finales.
8. **Accesibilidad real.** Contraste suficiente, botones e iconos grandes, navegación clara.
9. **Privacidad por defecto.** El progreso de un usuario es solo suyo.

---

## 3. Principios técnicos

1. **Spec Driven Development.** No se escribe código sin que la documentación de la fase correspondiente esté aprobada.
2. **Incremental y versionado.** Cambios pequeños, trazables y reversibles. SQL siempre en archivos nuevos numerados.
3. **Tipado estricto.** TypeScript en frontend y en Edge Functions; sin `any` salvo justificación documentada.
4. **Separación de responsabilidades.** Lógica de aplicación, contenido educativo y progreso del usuario claramente separados.
5. **No confiar en el frontend para validación crítica.** Las reglas de progreso, desbloqueo y corrección que importen para la integridad deben poder validarse en el backend.
6. **Modular y reutilizable.** Componentes y funciones con responsabilidad única y nombres descriptivos.
7. **Preparado para crecer.** Arquitectura abierta a multiusuario, premium y nuevos tipos de ejercicio sin reescrituras.
8. **Determinismo y testabilidad.** La lógica de repetición espaciada y desbloqueo debe ser pura y testeable de forma aislada.

---

## 4. Restricciones del agente IA (CRÍTICAS — no negociables)

El agente IA **debe** cumplir obligatoriamente:

1. **No modificar las Edge Functions existentes de login y registro.**
2. **No añadir, eliminar ni alterar configuración CORS** en las Edge Functions de login y registro (son compartidas por otras aplicaciones).
3. **No ejecutar comandos de consola relacionados con Supabase.**
4. **No hacer deploy de Edge Functions.**
5. **No ejecutar migraciones directamente contra Supabase.**
6. **No usar la Supabase CLI para aplicar cambios.**
7. **No conectarse a la base de datos de Supabase.**
8. **No intentar acceder, modificar o desplegar recursos reales de Supabase.**

**El agente únicamente puede generar:**

- Código fuente de la aplicación.
- Documentación.
- Edge Functions **nuevas** en TypeScript/Deno, como archivos.
- Scripts SQL versionados, como archivos.
- Instrucciones para que el propietario aplique manualmente los cambios.

**Responsabilidades exclusivas del propietario** (el agente nunca las realiza):

- Revisar y ejecutar scripts SQL.
- Desplegar Edge Functions.
- Configurar variables de entorno.
- Validar cambios en Supabase.
- Aplicar cambios de infraestructura.

> Cualquier acción del agente que roce estas restricciones debe detenerse y convertirse en una **instrucción manual** para el propietario.

---

## 5. Reglas sobre Supabase

1. Supabase es el backend: base de datos PostgreSQL, autenticación, Edge Functions y RLS.
2. El agente trata Supabase como **infraestructura de solo-archivos**: produce SQL y funciones como ficheros, nunca toca el entorno real.
3. La autenticación de login/registro **ya existe** y es compartida; se consume, no se modifica.
4. Se mantiene separación entre:
   - **Contenido educativo** (cursos, etapas, temas, lecciones, preguntas) — mayormente público/lectura.
   - **Progreso del usuario** (avance, intentos, repetición espaciada) — privado, protegido por RLS.
5. Toda tabla con datos de usuario debe llevar RLS que impida ver o modificar datos de otro usuario.
6. Las claves sensibles (service role, etc.) nunca se incrustan en el frontend ni en el repositorio.

---

## 6. Reglas sobre Edge Functions

1. Las Edge Functions **nuevas** se crean como archivos en `supabase/functions/certdeck-<nombre-funcion>/index.ts` (prefijo obligatorio `certdeck-`; ver §12.2). Las preexistentes de login/registro no se renombran ni se tocan.
2. Se escriben en **TypeScript sobre Deno**.
3. **Prohibido** tocar, mover o reconfigurar las funciones existentes de login/registro y su CORS.
4. El agente **no despliega** ni ejecuta funciones; solo entrega el código.
5. Cada función nueva debe documentar:
   - Propósito.
   - Variables de entorno necesarias.
   - Payload de entrada (esquema y ejemplo).
   - Respuesta esperada (esquema y ejemplo).
   - Errores posibles y códigos.
   - Instrucciones manuales de despliegue para el propietario.
6. Validación de entrada obligatoria; no asumir que el cliente envía datos correctos.
7. La lógica crítica (p. ej. cálculo de repetición espaciada o validación de respuestas de examen) que deba ser fiable se ubica en Edge Functions y/o SQL, no solo en el cliente.

---

## 7. Reglas sobre SQL

1. **Separación de SQL en dos carpetas** (no mezclar contenido y estructura):
   - `supabase/sql/` → **SQL estructural** de la aplicación (creación de tablas, columnas, constraints, índices, RLS, triggers, funciones). Numeración incremental `script-NNN.sql`.
   - `supabase/sql_contenido/` → **SQL de contenido** de los cursos (sentencias `INSERT`/`UPDATE` de cursos, etapas, temas, lecciones, pantallas y preguntas). El contenido de un curso se divide en **fragmentos** (un curso es demasiado grande para un solo archivo). Nomenclatura: **`YYYYMMDD_NN_<slug>.sql`** (fecha invertida + contador de 2 dígitos + `slug`), de forma que el **orden alfabético coincide con el orden de ejecución** en serie. No altera el esquema.
2. **Todas las tablas llevan el prefijo obligatorio `certdeck_`** (ver §12.2), para aislar el esquema de CertDeck de otras apps que comparten la base de datos Supabase.
3. **Nunca** se sobrescribe un script estructural anterior, salvo petición explícita del propietario. Los archivos de contenido sí pueden actualizarse (son datos del curso) y deben ser **idempotentes** (`on conflict … do update/nothing`).
3. Cada nueva iteración con cambios de esquema crea un **archivo nuevo**.
4. Cada script debe:
   - Empezar con un comentario de cabecera (qué hace, fecha, fase, dependencias de scripts previos).
   - Ser idempotente cuando sea razonable (`IF NOT EXISTS`, etc.).
   - Incluir `created_at` y `updated_at` cuando proceda.
   - Definir claves foráneas explícitas.
   - Incluir índices razonables sobre columnas de búsqueda y FKs.
   - Incluir constraints (NOT NULL, CHECK, UNIQUE) cuando proceda.
   - Incluir políticas **RLS** en tablas de progreso/usuario.
5. El agente **no ejecuta** SQL; entrega el archivo y explica cómo revisarlo y aplicarlo manualmente.
6. Los cambios destructivos (DROP, ALTER que pierdan datos) se marcan de forma destacada y requieren confirmación del propietario.

---

## 8. Reglas de arquitectura — Frontend

1. **Stack:** React + Next.js + Capacitor, diseño mobile-first, preparado para app híbrida.
2. **Lenguaje:** TypeScript estricto.
3. **Organización por features** dentro de `app/`:
   - `app/src/` — entrada y rutas (App Router de Next.js).
   - `app/components/` — componentes UI reutilizables y sin lógica de negocio.
   - `app/features/` — módulos por dominio (cursos, lecciones, ejercicios, progreso…).
   - `app/lib/` — clientes (Supabase), utilidades, lógica pura (p. ej. repetición espaciada).
   - `app/hooks/` — hooks reutilizables.
   - `app/styles/` — estilos y tokens de diseño (paleta azul/celeste/blanco).
4. La **lógica de negocio pura** (algoritmo de repaso, reglas de desbloqueo en cliente) vive en `app/lib/` y es testeable de forma aislada.
5. Sin llamadas directas a Supabase dispersas por la UI: se centralizan en `app/lib/` y se consumen vía hooks/servicios.
6. Componentes pensados para **sesiones cortas**: carga rápida, estados de carga y error claros.
7. Capacitor: no asumir APIs de navegador no disponibles en móvil; aislar accesos nativos.

---

## 9. Reglas de arquitectura — Backend

1. **Persistencia:** PostgreSQL en Supabase, definido por scripts SQL versionados.
2. **Modelo normalizado** que refleje la jerarquía Curso → Etapa → Tema → Lección → (pantallas, preguntas).
3. Separación de dominios de datos:
   - **Contenido:** `courses`, `stages`, `topics`, `lessons`, `lesson_screens`, `flashcard_questions`, `exam_questions`.
   - **Progreso de usuario:** `user_lesson_progress`, `user_question_attempts`, `user_spaced_repetition`.
4. La **reutilización de preguntas** se modela mediante la relación jerárquica `Pregunta → Lección → Tema → Etapa → Curso`, sin duplicar contenido.
5. Reglas de negocio sensibles (desbloqueo, cálculo de repaso, validación de respuestas de examen) se implementan en SQL/Edge Functions cuando su integridad importe.
6. RLS obligatoria en todas las tablas `user_*`.
7. Convención de respuestas de examen: la correcta se almacena internamente como `answer_1` (y en múltiple, las primeras `correct_answers_count`); **el frontend siempre desordena** antes de mostrar y nunca revela el orden interno.

---

## 10. Reglas de UX mobile-first

1. Diseño primero para pantallas pequeñas; escalado progresivo a mayores.
2. **Paleta:** azules, celestes y blancos; estética limpia y motivadora.
3. **Iconos grandes** y **botones grandes** con área táctil cómoda.
4. **Contraste suficiente** para legibilidad (objetivo WCAG AA en texto y controles).
5. Navegación clara y consistente: el usuario siempre sabe dónde está y cuál es la siguiente acción.
6. **Feedback inmediato** tras responder (correcto/incorrecto + explicación).
7. Botones de tarjeta ANKI claramente diferenciados: **Incorrecto / Correcto / Muy fácil**.
8. Respuestas de test y examen **siempre en orden aleatorio**.
9. Pantallas de resultado motivadoras: porcentaje de aciertos/fallos y felicitación.
10. Tiempos de carga percibidos mínimos; estados de carga y error siempre visibles.
11. Soporte de interacción táctil; nada que dependa exclusivamente de hover.

---

## 11. Reglas de documentación

1. Toda la documentación de Spec Driven Development vive en `docs/`:
   - `docs/01-constitution.md`
   - `docs/02-requirements.md`
   - `docs/03-roadmap.md`
   - `docs/04-tasks.md`
   - `docs/05-implementation.md`
   - `docs/decisions/` — registro de decisiones (ADR), una por archivo.
2. Cada documento indica **estado, versión, fecha y fase**.
3. Las decisiones técnicas relevantes se registran como ADR en `docs/decisions/` (contexto, decisión, alternativas, consecuencias).
4. La documentación se actualiza **antes** o **junto** con el código que describe, nunca después de forma diferida.
5. Cada iteración produce un bloque de entrega en `docs/05-implementation.md` con: resumen, archivos creados/modificados, SQL generado, Edge Functions generadas, decisiones, supuestos, riesgos, instrucciones manuales y checklist de validación.
6. El idioma de la documentación es **español**; el código (identificadores) puede usar inglés siguiendo convenciones del stack.

---

## 12. Convenciones de carpetas y nombres

### 12.1 Estructura del repositorio (adaptada al repo existente)

```txt
/
├── app/                      # Aplicación React + Next.js + Capacitor
│   ├── src/
│   ├── components/
│   ├── features/
│   ├── lib/
│   ├── hooks/
│   ├── styles/
│   └── ...
│
├── docs/                     # Documentación Spec Driven Development
│   ├── 01-constitution.md
│   ├── 02-requirements.md
│   ├── 03-roadmap.md
│   ├── 04-tasks.md
│   ├── 05-implementation.md
│   └── decisions/
│
├── supabase/
│   ├── functions/            # SOLO Edge Functions NUEVAS (nunca login/registro)
│   │   └── <function-name>/
│   │       └── index.ts
│   ├── sql/                  # SQL ESTRUCTURAL de la app (esquema, RLS, índices…)
│   │   ├── script-001.sql    # versionado incremental: script-NNN.sql
│   │   ├── script-002.sql
│   │   └── ...
│   └── sql_contenido/        # SQL de CONTENIDO de cursos (INSERTs de datos)
│       ├── 20260515_01_aws-saa-c03.sql   # fragmentos: YYYYMMDD_NN_<slug>.sql
│       ├── 20260515_02_aws-saa-c03.sql   # (orden alfabético = orden de ejecución)
│       └── ...
│
└── README.md
```

> **Nota de decisión:** el prompt maestro proponía `specs/` y `supabase-artifacts/`. Se adopta `docs/` y `supabase/` por decisión del propietario, alineándose con el scaffold existente y con `.gitignore`. Se registrará como ADR en `docs/decisions/`.

### 12.2 Convenciones de nombres

- **Documentos de specs:** `NN-nombre.md` (numeración con dos dígitos).
- **Scripts SQL estructurales** (`supabase/sql/`): `script-NNN.sql` (tres dígitos, incremental, nunca reutilizado).
- **Archivos SQL de contenido** (`supabase/sql_contenido/`): fragmentos nombrados **`YYYYMMDD_NN_<slug>.sql`** (fecha invertida `AAAAMMDD` + contador `NN` de 2 dígitos + `slug` en `kebab-case`; p. ej. `20260515_01_aws-saa-c03.sql`). El orden alfabético = orden de ejecución. Solo datos (`INSERT`/`UPDATE`), idempotentes, nunca cambios de esquema.
- **Edge Functions (nuevas):** carpeta `certdeck-<kebab-case>` con `index.ts` dentro (p. ej. `certdeck-progress-complete-lesson`). **Excepción:** las Edge Functions **preexistentes y compartidas** de login/registro (`auth-login`, `auth-register`, `_shared/`) **NO se renombran** ni se tocan (Constitución §4).
- **Tablas SQL:** **todas con prefijo obligatorio `certdeck_`**, en `snake_case` y plural para entidades (p. ej. `certdeck_courses`, `certdeck_lessons`). Las tablas de progreso de usuario usan `certdeck_user_<algo>` (p. ej. `certdeck_user_lesson_progress`). El prefijo aísla el esquema de CertDeck de otras apps que comparten la misma base de datos Supabase.
- **Columnas SQL:** `snake_case`; timestamps `created_at` / `updated_at`; claves foráneas `<entidad>_id` (referida a la tabla `certdeck_<entidad>s`).
- **Componentes React:** `PascalCase`.
- **Hooks:** `useCamelCase`.
- **Archivos de utilidades/lógica:** `camelCase.ts` o `kebab-case.ts` consistente por carpeta.
- **Variables y funciones TS:** `camelCase`; constantes globales `UPPER_SNAKE_CASE`.
- **ADR:** `docs/decisions/NNNN-titulo-kebab.md`.

---

## 13. Criterios de calidad

1. **Tipado:** sin errores de TypeScript; `any` solo justificado por comentario.
2. **Lint/formato:** código conforme a la configuración de lint/formato del proyecto.
3. **Lógica crítica testeada:** algoritmo de repetición espaciada y reglas de desbloqueo con pruebas unitarias.
4. **Sin duplicación de lógica crítica.**
5. **Accesibilidad:** contraste AA, foco visible, controles con etiquetas.
6. **Rendimiento móvil:** carga inicial ligera; sin bloqueos perceptibles en interacción.
7. **SQL seguro:** FKs, constraints, índices y RLS donde proceda.
8. **Documentación al día:** cada cambio acompañado de su entrada en specs.
9. **Trazabilidad:** cada cambio enlaza con una tarea de `docs/04-tasks.md`.

---

## 14. Definición de terminado (Definition of Done)

Una unidad de trabajo (tarea/iteración) está **terminada** cuando:

1. Cumple la Constitución y la fase de specs correspondiente.
2. El código es claro, tipado, modular y con nombres descriptivos.
3. La lógica crítica tiene pruebas y pasan.
4. No hay errores de tipado ni de lint.
5. La UX cumple mobile-first, contraste y feedback inmediato (si aplica a UI).
6. El SQL nuevo está en un archivo numerado nuevo, con comentarios, FKs, índices, constraints y RLS donde proceda — **sin ejecutarse**.
7. Las Edge Functions nuevas están documentadas (env, payload, respuesta, errores, despliegue) — **sin desplegarse**.
8. La documentación (`docs/`) está actualizada, incluida la entrada de implementación.
9. Se entregan las **instrucciones manuales** para el propietario y un **checklist de validación**.
10. Ninguna restricción crítica del agente (sección 4) ha sido vulnerada.

---

## 15. Criterios de aceptación de la Constitución

Esta Constitución se considera **aprobada** cuando el propietario confirma que:

1. La visión y los principios reflejan el producto deseado.
2. Las restricciones del agente IA están correctamente recogidas y son completas.
3. Las reglas de Supabase, Edge Functions y SQL son aceptables.
4. La estructura de carpetas y convenciones de nombres son las definitivas.
5. Los criterios de calidad y la Definición de terminado son adecuados.

> Hasta la aprobación explícita, **no se avanza a la Fase 2 (Requisitos)** y **no se genera código, SQL ni Edge Functions**.

---

## 16. Qué puede y qué no puede hacer el agente (resumen operativo)

| El agente **SÍ** puede | El agente **NO** puede |
|---|---|
| Generar código fuente de `app/` | Modificar Edge Functions de login/registro |
| Escribir documentación en `docs/` | Tocar/alterar CORS de funciones existentes |
| Crear Edge Functions nuevas como archivos | Ejecutar comandos de Supabase / CLI |
| Crear scripts SQL numerados nuevos | Hacer deploy de Edge Functions |
| Proponer modelo de datos y migraciones | Ejecutar migraciones contra Supabase |
| Dar instrucciones manuales al propietario | Conectarse a la base de datos real |
| Registrar decisiones (ADR) | Acceder/modificar/desplegar recursos reales de Supabase |
| Proponer tests y criterios de validación | Sobrescribir scripts SQL previos sin permiso explícito |

---

## 17. Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-14 | Versión inicial de la Constitución (Fase 1). **Aprobada** por el propietario el 2026-06-14. |
| 1.1.0 | 2026-06-15 | Prefijo obligatorio `certdeck_` en todas las tablas y `certdeck-` en Edge Functions nuevas (§6, §7, §12.2). Motivo: base de datos Supabase compartida con otras apps. |
| 1.2.0 | 2026-06-15 | Separación de SQL en `supabase/sql/` (estructural) y `supabase/sql_contenido/` (contenido de cursos) (§7, §12.1, §12.2). |
| 1.3.0 | 2026-06-15 | Nomenclatura de fragmentos de contenido `YYYYMMDD_NN_<slug>.sql` (orden alfabético = orden de ejecución); el contenido de un curso se divide en fragmentos (§7, §12.1, §12.2). |
