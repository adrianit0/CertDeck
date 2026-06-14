/**
 * Tipos de dominio de CertDeck, alineados con el esquema SQL (`certdeck_*`).
 * Ver supabase/sql/script-001.sql y script-002.sql.
 */

export type LessonType = "normal" | "review" | "error_correction" | "expansion" | "final";

export type ExerciseType = "anki_card" | "multiple_choice" | "true_false";

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
  estimated_minutes: number | null;
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
  position: number;
  question: string;
  correct_answer: string;
  incorrect_answer_1: string | null;
  incorrect_answer_2: string | null;
  explanation: string | null;
  difficulty: number;
}

/** Una etapa con sus temas (para la pantalla de detalle de curso). */
export interface StageWithTopics extends Stage {
  topics: Topic[];
}

/** Lección lista para reproducir: pantallas + preguntas. */
export interface PlayableLesson {
  lesson: Lesson;
  screens: LessonScreen[];
  questions: FlashcardQuestion[];
}
