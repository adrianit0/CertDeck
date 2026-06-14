// Deno tests for the shared HTTP helpers (T-11).
// Run from the repo root:  deno test supabase/functions/_shared/
// No registry imports on purpose: tiny inline asserts keep the test offline.

import { handlePreflight, HttpError, jsonResponse, readBody } from "./http.ts";

function assertEquals<T>(actual: T, expected: T, label: string) {
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) {
    throw new Error(`${label}: expected ${b}, got ${a}`);
  }
}

Deno.test("jsonResponse sets status, CORS and content-type", async () => {
  const response = jsonResponse({ ok: true }, 201);
  assertEquals(response.status, 201, "status");
  assertEquals(response.headers.get("Content-Type"), "application/json", "content-type");
  assertEquals(response.headers.get("Access-Control-Allow-Origin"), "*", "cors origin");
  assertEquals(await response.json(), { ok: true }, "body");
});

Deno.test("readBody returns {} for an empty body", async () => {
  const request = new Request("http://localhost/", { method: "POST" });
  assertEquals(await readBody(request), {}, "empty body");
});

Deno.test("readBody parses a JSON body", async () => {
  const request = new Request("http://localhost/", {
    method: "POST",
    body: JSON.stringify({ email: "persona@ejemplo.com" }),
  });
  assertEquals(await readBody(request), { email: "persona@ejemplo.com" }, "json body");
});

Deno.test("readBody throws HttpError(400) for malformed JSON", async () => {
  const request = new Request("http://localhost/", { method: "POST", body: "{roto" });
  try {
    await readBody(request);
    throw new Error("expected HttpError");
  } catch (error) {
    if (!(error instanceof HttpError)) {
      throw new Error(`expected HttpError, got ${String(error)}`);
    }
    assertEquals(error.status, 400, "http error status");
  }
});

Deno.test("handlePreflight answers OPTIONS with 204", () => {
  const response = handlePreflight(new Request("http://localhost/", { method: "OPTIONS" }));
  assertEquals(response?.status, 204, "options status");
});

Deno.test("handlePreflight rejects unexpected methods with 405", async () => {
  const response = handlePreflight(new Request("http://localhost/", { method: "GET" }));
  assertEquals(response?.status, 405, "get status");
  assertEquals(await response?.json(), { error: "Method not allowed" }, "get body");
});

Deno.test("handlePreflight lets the allowed method through", () => {
  const response = handlePreflight(new Request("http://localhost/", { method: "POST" }));
  assertEquals(response, null, "post passthrough");
});
