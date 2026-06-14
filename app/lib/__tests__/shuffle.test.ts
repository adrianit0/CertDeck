import { describe, it, expect } from "vitest";
import { shuffle } from "@/lib/shuffle";

describe("shuffle", () => {
  it("no muta el array original", () => {
    const original = [1, 2, 3, 4, 5];
    const copy = [...original];
    shuffle(original);
    expect(original).toEqual(copy);
  });

  it("conserva los mismos elementos", () => {
    const result = shuffle([1, 2, 3, 4, 5]);
    expect([...result].sort((a, b) => a - b)).toEqual([1, 2, 3, 4, 5]);
  });

  it("devuelve un array del mismo tamaño", () => {
    expect(shuffle(["a", "b", "c"])).toHaveLength(3);
  });
});
