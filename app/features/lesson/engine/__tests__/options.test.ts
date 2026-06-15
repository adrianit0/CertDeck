import { describe, it, expect } from "vitest";
import { getOptions, isCorrect } from "@/features/lesson/engine/options";
import type { FlashcardQuestion } from "@/lib/types";

function makeQuestion(overrides: Partial<FlashcardQuestion>): FlashcardQuestion {
  return {
    id: "q1",
    lesson_id: "l1",
    exercise_type: "multiple_choice",
    question: "¿Pregunta?",
    correct_answer: "Correcta",
    incorrect_answer_1: "Mal 1",
    incorrect_answer_2: "Mal 2",
    explanation: null,
    ...overrides,
  };
}

describe("getOptions", () => {
  it("multiple_choice devuelve las 3 opciones", () => {
    const opts = getOptions(makeQuestion({}));
    expect(opts).toHaveLength(3);
    expect(opts).toContain("Correcta");
    expect(opts).toContain("Mal 1");
    expect(opts).toContain("Mal 2");
  });

  it("true_false devuelve Verdadero y Falso", () => {
    const opts = getOptions(makeQuestion({ exercise_type: "true_false", correct_answer: "Verdadero" }));
    expect([...opts].sort()).toEqual(["Falso", "Verdadero"]);
  });

  it("anki_card no tiene opciones", () => {
    expect(getOptions(makeQuestion({ exercise_type: "anki_card" }))).toEqual([]);
  });
});

describe("isCorrect", () => {
  it("detecta la respuesta correcta", () => {
    const q = makeQuestion({});
    expect(isCorrect(q, "Correcta")).toBe(true);
    expect(isCorrect(q, "Mal 1")).toBe(false);
  });
});
