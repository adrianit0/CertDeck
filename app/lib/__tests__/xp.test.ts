import { describe, it, expect } from "vitest";
import { sessionXp, XP_BASE, XP_MAX } from "@/lib/xp";

describe("sessionXp", () => {
  it("da la base con 0% de acierto", () => {
    expect(sessionXp(0)).toBe(XP_BASE);
  });

  it("da el máximo (100) con 100% de acierto", () => {
    expect(sessionXp(100)).toBe(XP_MAX);
  });

  it("suma 1 XP por cada 2% de acierto", () => {
    expect(sessionXp(50)).toBe(75); // 50 + floor(50/2)
    expect(sessionXp(80)).toBe(90); // 50 + 40
    expect(sessionXp(2)).toBe(51); // 50 + 1
    expect(sessionXp(3)).toBe(51); // 50 + floor(1.5)
  });

  it("no depende del número de preguntas (solo del porcentaje)", () => {
    expect(sessionXp(60)).toBe(80);
    expect(sessionXp(60)).toBe(sessionXp(60));
  });

  it("nunca supera 100 ni baja de 50 dentro del rango válido", () => {
    expect(sessionXp(100)).toBeLessThanOrEqual(100);
    expect(sessionXp(0)).toBeGreaterThanOrEqual(50);
  });

  it("clampa porcentajes fuera de rango", () => {
    expect(sessionXp(-20)).toBe(50);
    expect(sessionXp(150)).toBe(100);
  });

  it("repetir una lección da el 20% del total (80% menos)", () => {
    expect(sessionXp(100, true)).toBe(20); // round(100 * 0.2)
    expect(sessionXp(0, true)).toBe(10); // round(50 * 0.2)
    expect(sessionXp(50, true)).toBe(15); // round(75 * 0.2)
  });
});
