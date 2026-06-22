import { describe, it, expect } from "vitest";
import { xpForLevel, levelForXp, levelProgress, MAX_LEVEL, MAX_XP } from "@/lib/level";

describe("xpForLevel", () => {
  it("nivel 1 no requiere XP", () => {
    expect(xpForLevel(1)).toBe(0);
  });

  it("nivel 99 requiere ~1.000.000 XP", () => {
    expect(xpForLevel(MAX_LEVEL)).toBe(MAX_XP);
  });

  it("es estrictamente creciente", () => {
    for (let n = 1; n < MAX_LEVEL; n++) {
      expect(xpForLevel(n + 1)).toBeGreaterThan(xpForLevel(n));
    }
  });

  it("los primeros niveles cuestan poca XP", () => {
    expect(xpForLevel(2)).toBeLessThan(100);
    expect(xpForLevel(5)).toBeLessThan(2000);
  });

  it("el coste por nivel se acelera con el rango", () => {
    const early = xpForLevel(11) - xpForLevel(10);
    const late = xpForLevel(99) - xpForLevel(98);
    expect(late).toBeGreaterThan(early);
  });
});

describe("levelForXp", () => {
  it("0 XP = nivel 1", () => {
    expect(levelForXp(0)).toBe(1);
  });

  it(">= 1.000.000 XP = nivel 99 (cap)", () => {
    expect(levelForXp(MAX_XP)).toBe(MAX_LEVEL);
    expect(levelForXp(MAX_XP * 2)).toBe(MAX_LEVEL);
  });

  it("es la inversa consistente de xpForLevel", () => {
    for (let n = 1; n <= MAX_LEVEL; n++) {
      const xp = xpForLevel(n);
      expect(levelForXp(xp)).toBe(n);
      if (n < MAX_LEVEL) expect(levelForXp(xpForLevel(n + 1) - 1)).toBe(n);
    }
  });
});

describe("levelProgress", () => {
  it("en el límite inferior de un nivel el avance es 0%", () => {
    const p = levelProgress(xpForLevel(10));
    expect(p.level).toBe(10);
    expect(p.percent).toBe(0);
  });

  it("a mitad de tramo el avance ronda el 50%", () => {
    const mid = Math.round((xpForLevel(10) + xpForLevel(11)) / 2);
    const p = levelProgress(mid);
    expect(p.level).toBe(10);
    expect(p.percent).toBeGreaterThanOrEqual(49);
    expect(p.percent).toBeLessThanOrEqual(51);
  });

  it("en el nivel máximo marca isMax y 100%", () => {
    const p = levelProgress(MAX_XP);
    expect(p.isMax).toBe(true);
    expect(p.level).toBe(MAX_LEVEL);
    expect(p.percent).toBe(100);
  });
});
