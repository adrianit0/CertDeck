import { describe, it, expect } from "vitest";
import {
  normalizeAnswer,
  isTextAnswerCorrect,
  letterIndices,
} from "@/features/lesson/engine/textAnswer";

describe("normalizeAnswer", () => {
  it("quita tildes, mayúsculas y espacios sobrantes", () => {
    expect(normalizeAnswer(" éspanA ")).toBe("espana");
    expect(normalizeAnswer("España")).toBe("espana");
  });

  it("trata la 'ñ' como 'n'", () => {
    expect(normalizeAnswer("Niño")).toBe(normalizeAnswer("nino"));
  });

  it("colapsa espacios internos", () => {
    expect(normalizeAnswer("Object   Storage")).toBe("object storage");
  });
});

describe("isTextAnswerCorrect", () => {
  it("acepta 'éspanA' como 'España'", () => {
    expect(isTextAnswerCorrect("España", " éspanA")).toBe(true);
  });

  it("acepta diferencias de mayúsculas y números", () => {
    expect(isTextAnswerCorrect("Metadata", "metadata")).toBe(true);
    expect(isTextAnswerCorrect("5", " 5 ")).toBe(true);
  });

  it("rechaza respuestas distintas", () => {
    expect(isTextAnswerCorrect("Metadata", "Key")).toBe(false);
  });
});

describe("letterIndices", () => {
  it("excluye los espacios", () => {
    expect(letterIndices([..."ab c"])).toEqual([0, 1, 3]);
  });
});
