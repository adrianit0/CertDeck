/**
 * Tipos de dominio de CertDeck, alineados con el esquema SQL (`certdeck_*`).
 * Ver supabase/sql/script-001.sql y script-002.sql.
 */

export type LessonType = "normal" | "review" | "error_correction" | "expansion" | "final";

export type ExerciseType = "anki_card" | "multiple_choice" | "true_false" | "text_input";

export type LessonStatus = "locked" | "available" | "in_progress" | "completed";

export interface Course {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  icon: string | null;
  color: string | null;
  difficulty: number;
}

export interface Stage {
  id: string;
  course_id: string;
  title: string;
  description: string | null;
  position: number;
}

export interface Topic {
  id: string;
  stage_id: string;
  title: string;
  description: string | null;
  summary: string | null;
  position: number;
}

export interface Lesson {
  id: string;
  topic_id: string;
  title: string;
  description: string | null;
  lesson_type: LessonType;
  position: number;
}

export interface LessonScreen {
  id: string;
  lesson_id: string;
  title: string | null;
  body: string;
  position: number;
}

export interface FlashcardQuestion {
  id: string;
  lesson_id: string;
  exercise_type: ExerciseType;
  question: string;
  correct_answer: string;
  incorrect_answer_1: string | null;
  incorrect_answer_2: string | null;
  explanation: string | null;
}

/** Una etapa con sus temas (para la pantalla de detalle de curso). */
export interface StageWithTopics extends Stage {
  topics: Topic[];
}

/** Lección con su estado de desbloqueo (vista de catálogo / prototipo de UI). */
export interface LessonWithStatus extends Lesson {
  status: LessonStatus;
}

/** Resultado de completar una lección (conteos y porcentaje de acierto). */
export interface LessonResult {
  correctCount: number;
  incorrectCount: number;
  scorePercentage: number;
}

/** Pregunta fallada (id + lección a la que pertenece), para los repasos de errores. */
export interface FailedQuestionRef {
  id: string;
  lessonId: string;
}

/** Autoevaluación de una tarjeta, para el algoritmo de repetición espaciada. */
export type ReviewGrade = "fail" | "correct" | "easy";

/** Resultado de una tarjeta en la sesión, para actualizar su estado SM-2. */
export interface CardReview {
  questionId: string;
  grade: ReviewGrade;
}

/**
 * Resultado completo de una sesión del reproductor (lección o repaso).
 * Recoge lo necesario para persistir progreso real y alimentar las métricas.
 */
export interface SessionResult {
  correctCount: number;
  incorrectCount: number;
  scorePercentage: number;
  ankiCount: number;
  xpGained: number;
  /** Preguntas con respuesta final incorrecta (se acumulan para "errores"). */
  failedQuestions: FailedQuestionRef[];
  /** Preguntas resueltas correctamente (se retiran del set de errores). */
  passedQuestionIds: string[];
  /** Autoevaluación por tarjeta para el algoritmo de repetición espaciada (SM-2). */
  cardReviews: CardReview[];
}

/**
 * Métricas de usuario para la cabecera y la pestaña de Progresos.
 * Se derivan del progreso real persistido (capa optimista local + Edge
 * Functions / tablas `certdeck_user_*`).
 */
export interface UserStats {
  xp: number;
  streak: number;
  lessonsCompleted: number;
  totalAnswers: number;
  correctAnswers: number;
  ankiCardsStudied: number;
}

/** Lección lista para reproducir: pantallas + preguntas. */
export interface PlayableLesson {
  lesson: Lesson;
  screens: LessonScreen[];
  questions: FlashcardQuestion[];
}

// ---------------------------------------------------------------------------
// Examen (v3) — catálogo especial `certdeck_exam_questions`, independiente de
// las flashcards. type_id 1 = respuesta única, 2 = respuesta múltiple.
// ---------------------------------------------------------------------------

/** Tipo de examen: 1 = respuesta única, 2 = respuesta múltiple (RF-27). */
export type ExamTypeId = 1 | 2;

/**
 * Una opción de respuesta de examen, ya DESORDENADA por el backend (RF-28/RN-10:
 * el orden interno nunca se expone). `isCorrect` permite el feedback inmediato
 * en cliente (RNF-14); la corrección autoritativa se reconfirma en servidor
 * (`certdeck-exam-grade`, RF-29/RSP-03).
 */
export interface ExamAnswerOption {
  text: string;
  isCorrect: boolean;
}

/** Pregunta de examen lista para responder (respuestas ya barajadas). */
export interface ExamQuestion {
  id: string;
  courseId: string;
  topicId: string | null;
  lessonId: string | null;
  question: string;
  typeId: ExamTypeId;
  /** Opciones ya desordenadas. Para múltiple, varias `isCorrect`. */
  options: ExamAnswerOption[];
  /** Nº de respuestas correctas (en múltiple, > 1). */
  correctAnswersCount: number;
  extraInformation: string | null;
  difficulty: number;
}

/** Filtros de la práctica directa de examen (RF-26). */
export interface ExamFilters {
  courseId: string;
  topicId?: string | null;
  difficulty?: number | null;
  limit?: number;
}

/** Lo que el usuario envía a corregir: textos de las opciones marcadas. */
export interface ExamAttempt {
  questionId: string;
  selectedAnswers: string[];
}

/** Veredicto autoritativo por pregunta devuelto por `certdeck-exam-grade`. */
export interface ExamGradeResult {
  questionId: string;
  correct: boolean;
}

/** Resumen de corrección de un lote de preguntas de examen. */
export interface ExamGradeSummary {
  results: ExamGradeResult[];
  correctCount: number;
  total: number;
}
