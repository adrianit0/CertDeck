import { shuffle } from "@/lib/shuffle";
import type { FlashcardQuestion } from "@/lib/types";

/**
 * Devuelve las opciones a mostrar para una pregunta de test o V/F,
 * SIEMPRE en orden aleatorio (RN-09). Para anki_card no aplica (no hay opciones).
 */
export function getOptions(question: FlashcardQuestion): string[] {
  if (question.exercise_type === "true_false") {
    return shuffle(["Verdadero", "Falso"]);
  }
  if (question.exercise_type === "multiple_choice") {
    const options = [question.correct_answer];
    if (question.incorrect_answer_1) options.push(question.incorrect_answer_1);
    if (question.incorrect_answer_2) options.push(question.incorrect_answer_2);
    return shuffle(options);
  }
  return [];
}

/** Comprueba si la respuesta seleccionada es la correcta. */
export function isCorrect(question: FlashcardQuestion, selected: string): boolean {
  return selected === question.correct_answer;
}
