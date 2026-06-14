import { describe, it, expect } from "vitest";
import { cn, clamp } from "@/lib/utils";

describe("cn", () => {
  it("une clases válidas", () => {
    expect(cn("a", "b")).toBe("a b");
  });

  it("ignora valores falsy", () => {
    expect(cn("a", false, null, undefined, "", "b")).toBe("a b");
  });
});

describe("clamp", () => {
  it("respeta el rango", () => {
    expect(clamp(5, 0, 10)).toBe(5);
    expect(clamp(-3, 0, 10)).toBe(0);
    expect(clamp(99, 0, 10)).toBe(10);
  });
});
