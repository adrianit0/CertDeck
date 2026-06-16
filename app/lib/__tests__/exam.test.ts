import { describe, it, expect } from "vitest";
import {
  isExactSetMatch,
  correctTexts,
  gradeExamAnswer,
  examExerciseType,
} from "@/lib/exam";
import type { ExamAnswerOption } from "@/lib/types";

const opt = (text: string, isCorrect: boolean): ExamAnswerOption => ({ text, isCorrect });

describe("isExactSetMatch", () => {
  it("acepta el mismo conjunto sin importar el orden", () => {
    expect(isExactSetMatch(["b", "a"], ["a", "b"])).toBe(true);
  });

  it("rechaza si falta alguna correcta", () => {
    expect(isExactSetMatch(["a"], ["a", "b"])).toBe(false);
  });

  it("rechaza si sobra alguna (selección de más)", () => {
    expect(isExactSetMatch(["a", "b", "c"], ["a", "b"])).toBe(false);
  });

  it("tolera mayúsculas, espacios y tildes", () => {
    expect(isExactSetMatch([" Acción ", "ROL"], ["accion", "rol"])).toBe(true);
  });

  it("ignora duplicados en la selección", () => {
    expect(isExactSetMatch(["a", "a"], ["a"])).toBe(true);
  });
});

describe("correctTexts", () => {
  it("extrae solo las opciones marcadas como correctas", () => {
    const options = [opt("a", true), opt("b", false), opt("c", true)];
    expect(correctTexts(options)).toEqual(["a", "c"]);
  });
});

describe("gradeExamAnswer (respuesta única, type 1)", () => {
  const options = [opt("Correcta", true), opt("Mala 1", false), opt("Mala 2", false)];

  it("acierta al marcar solo la correcta", () => {
    expect(gradeExamAnswer(["Correcta"], options)).toBe(true);
  });

  it("falla al marcar una incorrecta", () => {
    expect(gradeExamAnswer(["Mala 1"], options)).toBe(false);
  });

  it("falla al marcar la correcta y otra de más", () => {
    expect(gradeExamAnswer(["Correcta", "Mala 1"], options)).toBe(false);
  });

  it("falla sin selección", () => {
    expect(gradeExamAnswer([], options)).toBe(false);
  });
});

describe("gradeExamAnswer (respuesta múltiple, type 2) — conjunto exacto (RF-29)", () => {
  const options = [
    opt("A", true),
    opt("B", true),
    opt("C", false),
    opt("D", false),
  ];

  it("acierta solo con el conjunto exacto", () => {
    expect(gradeExamAnswer(["B", "A"], options)).toBe(true);
  });

  it("falla si selecciona un subconjunto", () => {
    expect(gradeExamAnswer(["A"], options)).toBe(false);
  });

  it("falla si añade una incorrecta", () => {
    expect(gradeExamAnswer(["A", "B", "C"], options)).toBe(false);
  });
});

describe("examExerciseType", () => {
  it("mapea el type_id al tipo de ejercicio del intento", () => {
    expect(examExerciseType(1)).toBe("exam_single");
    expect(examExerciseType(2)).toBe("exam_multiple");
  });
});
