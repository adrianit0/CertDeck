# CertDeck — Hoja de ruta (Roadmap)

> Fase 3 del Spec Driven Development. Define **en qué orden** y **en qué versiones** se construye CertDeck, con entregables, dependencias, riesgos y criterios de aceptación por hito. Se rige por la [Constitución](../01-constitution/constitution.md) y desarrolla los [Requisitos](../02-requirements/requirements.md). Toda referencia a requisitos usa sus códigos (`RF-`, `RN-`, etc.).

- **Estado:** Aprobada
- **Versión:** 1.0.0
- **Fecha:** 2026-06-14 · **Aprobada:** 2026-06-15
- **Fase Spec Driven Development:** 3 — Hoja de ruta
- **Depende de:** Fase 1 (aprobada), Fase 2 (aprobada)
- **Decisiones Q-01…Q-06:** aprobadas (2026-06-15); trasladadas a `02-requirements.md` y ADR 0002.

---

> **Nomenclatura (Constitución §7/§12.2):** todas las tablas SQL llevan prefijo **`certdeck_`** y las Edge Functions nuevas el prefijo **`certdeck-`**. Algunos nombres de tabla se citan sin prefijo por brevedad.

> **Revisión de Requisitos 1.2.0 (2026-06-15) — impacto en el roadmap:**
> - **v1** incorpora: barra de navegación inferior + curso/etapa activos (ADR 0004), catálogo de etapa con tema solo-nombre, lección a pantalla completa (botones abajo, fuente mayor, Markdown negrita), **ronda de corrección** intra-lección, y base de **examen** (sin datos).
> - **v2** incorpora la **composición dinámica** de repaso/errores/finales reciclando preguntas ya vistas (ADR 0005); las lecciones `review`/`error_correction`/`final` dejan de llevar preguntas autoradas.
> - El contenido `sql_contenido/20260515_02_aws-saa-c03.sql` debe **revisarse** para quitar preguntas autoradas en sus lecciones de repaso (L4) y final (L5).

## 1. Estrategia general

La construcción es **incremental y vertical**: cada versión entrega una porción de valor de extremo a extremo (datos → backend → frontend) que el propietario puede validar. Se prioriza tener pronto un **camino jugable** (un curso de ejemplo recorrible) sobre completar todas las features a medias.

Orden macro:

1. **v0 — Fundaciones** (esqueleto técnico, sin features de aprendizaje).
2. **v1 — MVP** (recorrido completo de aprendizaje con los ejercicios base y desbloqueo).
3. **v2 — Repaso espaciado real + correcciones** (algoritmo y lecciones derivadas).
4. **v3 — Examen avanzado + progreso enriquecido**.
5. **v4+ — Pulido, accesibilidad avanzada y preparación premium/offline**.

> Cada versión termina con su entrada en `docs/05-implementation/implementation.md` (Fase 5) y un checklist de validación manual para el propietario.

---

## 2. Decisiones propuestas para las cuestiones abiertas (Q-01…Q-06)

Estas son **propuestas** para aprobación; al aprobarlas se trasladan a `02-requirements.md` (afinando RN) y, las arquitectónicas, a un ADR.

| Q | Tema | Propuesta por defecto | Versión donde se aplica |
|---|---|---|---|
| **Q-01** | Umbral de "bajo rendimiento" (RN-07) | Activar corrección de errores si `score_percentage < 60%` | v2 |
| **Q-02** | "Varios fallos" → tarjeta problemática (RN-13/17) | Marcar problemática a partir de **3 fallos** acumulados (en la misma lección o histórico) | v2 |
| **Q-03** | Parámetros del algoritmo espaciado (RN-16) | `ease_factor` inicial 2.5, mínimo 1.3; Correcto: ×`ease_factor`; pasos iniciales 1/3/7 días; Muy fácil: factor 1.3 extra y pasos 3/7; Incorrecto: `interval=0`, `ease -= 0.2` | v2 |
| **Q-04** | Cadencia de repasos (RN-06) | Repaso **cada 3 lecciones** + 1 repaso generalista al final de cada tema | v2 |
| **Q-05** | Dónde vive la lógica de desbloqueo/repaso (arquitectura) | **Híbrido:** cálculo en cliente para UX inmediata + **validación/persistencia autoritativa en Edge Functions + RLS** (la integridad no depende del cliente). Se registrará en ADR 0002 | definida en v1, reforzada en v2 |
| **Q-06** | ¿La práctica directa de examen afecta al repaso espaciado? | **No** en MVP: la práctica directa registra intentos (`user_question_attempts`) pero **no** altera `user_spaced_repetition`. Revisable en v3 | v1 (práctica), v3 (revisión) |

> Si el propietario prefiere otros valores, se ajustan aquí antes de pasar a Fase 4.

---

## 3. Versiones, entregables y alcance

### v0 — Fundaciones (esqueleto técnico)

**Objetivo:** que el proyecto arranque y se conecte a Supabase, sin lógica de aprendizaje.

**Entregables:**
- Scaffold de `app/` (Next.js + TypeScript, estructura por features de la Constitución §8).
- Integración Capacitor base (config para empaquetado móvil).
- Cliente Supabase centralizado en `app/lib/` leyendo `NEXT_PUBLIC_*`.
- Sistema de design tokens (paleta azul/celeste/blanco) y componentes UI base (botón grande, tarjeta, layout mobile).
- Consumo de la sesión de las Edge Functions de login/registro **existentes** (solo lectura de sesión; no se tocan).
- `script-001.sql`: esquema de **contenido** (`courses`, `stages`, `topics`, `lessons`, `lesson_screens`) + índices + constraints (sin RLS aún o RLS de solo lectura pública).

**Cubre:** base para RF-01…RF-06.
**No incluye:** ejercicios, progreso, desbloqueo.

---

### v1 — MVP (recorrido de aprendizaje)

**Objetivo:** un usuario recorre un curso de ejemplo de principio a fin, hace ejercicios y ve resultados, con desbloqueo lineal.

**Entregables:**
- **Datos:** `script-002.sql` con `flashcard_questions`, `exam_questions`, y tablas de progreso `user_lesson_progress`, `user_question_attempts` + **RLS** en tablas `user_*`. `script-003.sql` (seed de ejemplo: 1 curso, 1 etapa, 1–2 temas, varias lecciones y preguntas) — para que el propietario lo cargue.
- **Backend:** Edge Function nueva `certdeck-progress-complete-lesson` (valida y persiste fin de lección, calcula score, aplica desbloqueo lineal). Documentada, **sin desplegar**.
- **Frontend (pantallas MVP):** Inicio, Catálogo, Detalle curso, Etapas, Temas, Resumen de tema, Lecciones, Contenido de lección, Ejercicio ANKI, Test, Verdadero/Falso, Examen, Resultado de lección, Práctica directa de examen, Progreso (básico).
- **Lógica:** ejercicios base (RF-13…RF-29) con respuestas **siempre desordenadas**; reencolado de tarjeta "Incorrecto" al final de la lección; antifrustración (RN-17) básico.
- **Desbloqueo lineal:** primera lección disponible; siguiente al completar la anterior (RF-35, RF-36).

**Cubre:** RF-01…RF-12, RF-13…RF-34 (nivel base), RF-35/36, RN-01…RN-03, RN-09…RN-12, RN-18…RN-20, RSP-01/02/06.
**No incluye (todavía):** repaso espaciado real, correcciones automáticas, repasos generalistas, ampliación/final completas.

**Nota:** en v1 las tarjetas registran intentos, pero el cálculo fino de `user_spaced_repetition` llega en v2 (en v1 el reencolado es intra-lección).

---

### v2 — Repaso espaciado + correcciones

**Objetivo:** memorización espaciada real y lecciones derivadas del rendimiento.

**Entregables:**
- **Datos:** `script-004.sql` con `user_spaced_repetition` + RLS + índices por `due_at`/`user_id`.
- **Lógica pura testeada:** algoritmo SM-2 simplificado en `app/lib/` (parámetros de Q-03), con tests unitarios (RNF-09).
- **Backend:** Edge Function `certdeck-spaced-review-update` (actualiza estado de tarjeta tras Incorrecto/Correcto/Muy fácil de forma autoritativa) y `certdeck-review-build-lesson` (compone lecciones de repaso a partir de tarjetas vencidas y jerarquía Pregunta→Lección→Tema→Etapa→Curso).
- **Tipos de lección:** `review` (cada 3 lecciones + generalista por tema), `error_correction` (activación si score < 60%, Q-01) priorizando fallos (RF-43).
- **Desbloqueo avanzado:** RF-37…RF-41, RN-04…RN-08.
- **Tarjeta problemática:** marcado a 3 fallos (Q-02).

**Cubre:** RF-37…RF-45, RN-04…RN-08, RN-13…RN-17, Q-01…Q-04.

---

### v3 — Examen avanzado + progreso enriquecido

**Objetivo:** experiencia de examen completa y métricas de progreso útiles.

**Entregables:**
- Examen respuesta múltiple con validación de **conjunto exacto** (RF-29/RN-11) reforzada en backend.
- Sección de práctica de examen con filtros (por curso/tema/dificultad) y `extra_information`.
- Pantalla de progreso enriquecida: avance por curso/tema, tarjetas vencidas/pendientes, históricos (RF-34 ampliado).
- Lecciones `expansion` y `final` completas (RF-44, RF-45).
- Revisión de Q-06 (si la práctica de examen debe alimentar repaso).

**Cubre:** RF-24…RF-29 (completo), RF-44/45, RF-34 (ampliado).

---

### v4+ — Pulido y preparación de futuro

**Objetivo:** calidad de producto y bases para crecer.

**Entregables (candidatos):**
- Auditoría de accesibilidad (RA-01…RA-06) y rendimiento móvil.
- Empaquetado Capacitor probado en dispositivo (RM-03).
- Gamificación ligera (rachas) — opcional.
- Preparación premium/multiusuario (sin implementar pagos) (RSP-07).
- i18n base (RNF-16).
- Modo offline/sincronización — investigación.

---

## 4. Mapa versión ↔ requisitos (trazabilidad resumida)

| Requisitos | v0 | v1 | v2 | v3 | v4+ |
|---|:--:|:--:|:--:|:--:|:--:|
| RF-01…RF-06 (catálogo/navegación) | base | ✅ | | | |
| RF-07…RF-12 (lecciones) | | ✅ | | | |
| RF-13…RF-18 (ANKI) | | ✅ (intra-lección) | ✅ (espaciado) | | |
| RF-19…RF-23 (test/VF) | | ✅ | | | |
| RF-24…RF-29 (examen) | | base | | ✅ | |
| RF-30…RF-34 (resultado/progreso) | | ✅ (básico) | | ✅ (ampliado) | |
| RF-35…RF-41 (desbloqueo) | | lineal | ✅ (completo) | | |
| RF-42…RF-45 (repaso/corr./amp./final) | | | ✅ (repaso/corr.) | ✅ (amp./final) | |
| RNF/RSP/RA/RM | base | parcial | parcial | parcial | ✅ (auditoría) |

---

## 5. Dependencias

- **D-01** v1 depende de v0 (esquema de contenido y cliente Supabase).
- **D-02** El seed de contenido (`script-003.sql`) debe estar cargado por el propietario para validar v1.
- **D-03** v2 depende de las tablas de progreso e intentos de v1.
- **D-04** Las Edge Functions nuevas dependen de que el propietario las despliegue y configure env (responsabilidad del propietario, Constitución §4).
- **D-05** RLS (v1+) depende de que la sesión autenticada provea `auth.uid()` desde el login existente.
- **D-06** Capacitor en dispositivo (v4) depende de un build estable de Next.js export-compatible.

---

## 6. Riesgos

### 6.1 Riesgos técnicos
| ID | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| RT-01 | Next.js + Capacitor: rutas/SSR no compatibles con export estático móvil | Alto | Definir en v0 estrategia de renderizado (export estático / SPA) antes de construir pantallas; ADR. |
| RT-02 | Prefijos de env (`VITE_` vs `NEXT_PUBLIC_`) mal configurados | Medio | Ya añadidas ambas variantes; el frontend usa `NEXT_PUBLIC_`. Documentado. |
| RT-03 | Lógica de desbloqueo/repaso divergente entre cliente y backend | Alto | Backend autoritativo (Q-05); cliente solo optimista. Tests sobre la lógica pura. |
| RT-04 | RLS mal definida expone progreso ajeno | Crítico | Revisión obligatoria del propietario antes de aplicar SQL; pruebas de acceso cruzado. |
| RT-05 | El agente no puede probar Supabase real | Medio | Entregar checklist de validación manual y datos seed; el propietario valida. |

### 6.2 Riesgos de producto
| ID | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| RP-01 | Parámetros del algoritmo poco acertados (repasos molestos o escasos) | Medio | Parámetros ajustables (RN-16); recoger feedback tras v2. |
| RP-02 | Curva de creación de contenido alta (sin UI de admin en MVP) | Medio | Plantillas SQL claras de seed; futura UI de admin en v4+. |
| RP-03 | Antifrustración mal calibrada (dar por válido demasiado pronto/tarde) | Bajo | Umbral Q-02 configurable; revisar con datos reales. |
| RP-04 | Alcance del MVP demasiado amplio | Medio | Cortes claros por versión; v1 lineal antes que repaso espaciado. |

---

## 7. Orden recomendado de implementación

1. **v0.1** ADR de renderizado (RT-01) + scaffold `app/` + design tokens + cliente Supabase.
2. **v0.2** `script-001.sql` (contenido) + pantallas de navegación (catálogo → tema) con datos de prueba.
3. **v1.1** `script-002.sql` (preguntas + progreso + RLS) + ejercicios ANKI/test/VF.
4. **v1.2** Examen base + práctica directa + resultado de lección + progreso básico.
5. **v1.3** Edge Function `certdeck-progress-complete-lesson` + desbloqueo lineal + `script-003.sql` (seed).
6. **v2.1** Algoritmo espaciado puro + tests + `script-004.sql` (`user_spaced_repetition`).
7. **v2.2** Edge Functions `certdeck-spaced-review-update` y `certdeck-review-build-lesson` + lecciones `review`.
8. **v2.3** Corrección de errores + desbloqueo avanzado + tarjeta problemática.
9. **v3.x** Examen múltiple completo, progreso enriquecido, `expansion`/`final`.
10. **v4+** Accesibilidad, dispositivo, premium/i18n/offline.

---

## 8. Criterios de aceptación por hito

### v0
- El proyecto arranca en local y carga variables `NEXT_PUBLIC_*`.
- Se conecta a Supabase y lista cursos de prueba.
- `script-001.sql` revisado por el propietario (no es necesario aplicarlo aún para aceptar el hito de código).

### v1 (MVP)
- Un usuario autenticado recorre: catálogo → curso → etapa → tema → lección.
- Realiza ejercicios ANKI, test, V/F y examen con respuestas desordenadas.
- "Incorrecto" reencola la tarjeta al final de la lección.
- Al terminar ve % aciertos/fallos y se desbloquea la siguiente lección (lineal).
- El progreso persiste y es privado (RLS verificada por el propietario).
- Existe práctica directa de examen.

### v2
- Tras responder tarjetas, `due_at`/`interval_days`/`ease_factor` evolucionan según Q-03 (verificado con tests).
- Aparecen repasos cada 3 lecciones y un generalista por tema, con preguntas vencidas/previas.
- Score < 60% activa/ofrece corrección de errores centrada en fallos.
- Tarjeta marcada problemática a los 3 fallos.

### v3
- Examen múltiple solo cuenta acierto con conjunto exacto.
- Práctica de examen filtrable; progreso muestra vencidas/pendientes e históricos.
- Lecciones de ampliación y finales funcionando.

### v4+
- Auditoría de accesibilidad AA superada en pantallas clave.
- Build Capacitor ejecutándose en dispositivo.

---

## 9. Supuestos

- El propietario cargará y validará el SQL y desplegará las Edge Functions en su entorno.
- Habrá contenido seed disponible para validar cada versión.
- La autenticación existente provee `auth.uid()` utilizable por RLS.

---

## 10. Criterios de aceptación de la Hoja de ruta (Fase 3)

Aprobada cuando el propietario confirma:
1. El alcance y orden de versiones (v0…v4+) son adecuados.
2. Las decisiones Q-01…Q-06 son correctas (o las ajusta).
3. Dependencias y riesgos están bien identificados.
4. Los criterios de aceptación por hito son válidos.

> Tras la aprobación: trasladar Q-01…Q-06 a `02-requirements.md`, crear **ADR 0002** (lógica de desbloqueo/repaso, Q-05) y pasar a Fase 4 (Tareas).

---

## 11. Control de versiones del documento

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-14 | Versión inicial de la Hoja de ruta (Fase 3). **Aprobada** el 2026-06-15, incluidas las decisiones Q-01…Q-06. |
