import { describe, it, expect } from "vitest";
import {
  initialCardState,
  reviewCard,
  isCardDue,
  DEFAULT_SRS_PARAMS,
  type SrsCardState,
} from "@/lib/srs";

const NOW = new Date("2026-06-16T10:00:00.000Z");

/** Diferencia en días enteros entre `dueAt` y `now`. */
function dueInDays(state: SrsCardState, now: Date = NOW): number {
  return Math.round((new Date(state.dueAt).getTime() - now.getTime()) / 86_400_000);
}

describe("initialCardState", () => {
  it("crea una tarjeta nueva con los valores por defecto y vencida de inmediato", () => {
    const s = initialCardState(NOW);
    expect(s.easeFactor).toBe(2.5);
    expect(s.intervalDays).toBe(0);
    expect(s.repetitions).toBe(0);
    expect(s.lapses).toBe(0);
    expect(s.isProblematic).toBe(false);
    expect(s.lastReviewedAt).toBeNull();
    expect(isCardDue(s, NOW)).toBe(true);
  });
});

describe("reviewCard — Correcto (RN-14)", () => {
  it("progresa por los pasos 1 → 3 → 7 días en aciertos consecutivos", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "correct", NOW);
    expect(s.repetitions).toBe(1);
    expect(s.intervalDays).toBe(1);
    expect(dueInDays(s)).toBe(1);

    s = reviewCard(s, "correct", NOW);
    expect(s.intervalDays).toBe(3);

    s = reviewCard(s, "correct", NOW);
    expect(s.intervalDays).toBe(7);
  });

  it("tras los pasos, multiplica el intervalo por el ease (7 × 2.5 = 18)", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "correct", NOW); // 1
    s = reviewCard(s, "correct", NOW); // 3
    s = reviewCard(s, "correct", NOW); // 7
    s = reviewCard(s, "correct", NOW); // 7 × 2.5 = 17.5 -> 18
    expect(s.intervalDays).toBe(18);
    expect(s.easeFactor).toBe(2.5); // "Correcto" no cambia el ease
  });
});

describe("reviewCard — Muy fácil (RN-15)", () => {
  it("usa los pasos 3 → 7 y sube el ease en cada 'Muy fácil'", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "easy", NOW);
    expect(s.intervalDays).toBe(3);
    expect(s.easeFactor).toBe(2.65);

    s = reviewCard(s, "easy", NOW);
    expect(s.intervalDays).toBe(7);
    expect(s.easeFactor).toBe(2.8);
  });

  it("tras los pasos crece más rápido (× ease × bonus 1.3)", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "easy", NOW); // 3, ease 2.65
    s = reviewCard(s, "easy", NOW); // 7, ease 2.8
    s = reviewCard(s, "easy", NOW); // 7 × 2.95 × 1.3 = 26.8 -> 27
    expect(s.easeFactor).toBe(2.95);
    expect(s.intervalDays).toBe(27);
  });
});

describe("reviewCard — Incorrecto (RN-13)", () => {
  it("reinicia el intervalo y las repeticiones, y baja el ease en 0.2", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "correct", NOW);
    s = reviewCard(s, "correct", NOW); // repetitions 2, interval 3
    s = reviewCard(s, "fail", NOW);
    expect(s.repetitions).toBe(0);
    expect(s.intervalDays).toBe(0);
    expect(s.lapses).toBe(1);
    expect(s.easeFactor).toBe(2.3);
    expect(isCardDue(s, NOW)).toBe(true); // vence de inmediato
  });

  it("no deja el ease por debajo del mínimo 1.3", () => {
    let s = initialCardState(NOW);
    for (let i = 0; i < 10; i++) s = reviewCard(s, "fail", NOW);
    expect(s.easeFactor).toBe(1.3);
  });

  it("marca la tarjeta como problemática a partir de 3 fallos (Q-02)", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "fail", NOW);
    expect(s.isProblematic).toBe(false);
    s = reviewCard(s, "fail", NOW);
    expect(s.isProblematic).toBe(false);
    s = reviewCard(s, "fail", NOW);
    expect(s.lapses).toBe(3);
    expect(s.isProblematic).toBe(true);
  });

  it("una vez problemática, sigue siéndolo aunque acierte después", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "fail", NOW);
    s = reviewCard(s, "fail", NOW);
    s = reviewCard(s, "fail", NOW);
    s = reviewCard(s, "correct", NOW);
    expect(s.isProblematic).toBe(true);
  });

  it("tras un fallo, el siguiente acierto vuelve a empezar en 1 día", () => {
    let s = initialCardState(NOW);
    s = reviewCard(s, "correct", NOW);
    s = reviewCard(s, "correct", NOW);
    s = reviewCard(s, "fail", NOW);
    s = reviewCard(s, "correct", NOW);
    expect(s.repetitions).toBe(1);
    expect(s.intervalDays).toBe(1);
  });
});

describe("isCardDue", () => {
  it("no está vencida antes de su dueAt y sí después", () => {
    const s = reviewCard(initialCardState(NOW), "correct", NOW); // +1 día
    const beforeDue = new Date(NOW.getTime() + 12 * 3_600_000); // +12h
    const afterDue = new Date(NOW.getTime() + 36 * 3_600_000); // +36h
    expect(isCardDue(s, beforeDue)).toBe(false);
    expect(isCardDue(s, afterDue)).toBe(true);
  });
});

describe("parámetros ajustables (RN-16)", () => {
  it("respeta parámetros personalizados sin reescribir la lógica", () => {
    const params = { ...DEFAULT_SRS_PARAMS, correctSteps: [2], minEase: 2.0, easePenalty: 1.0 };
    let s = initialCardState(NOW, params);
    s = reviewCard(s, "correct", NOW, params);
    expect(s.intervalDays).toBe(2);
    s = reviewCard(s, "fail", NOW, params);
    expect(s.easeFactor).toBe(2.0); // no baja del mínimo personalizado
  });
});
