// Shared HTTP helpers for Gessalud edge functions.
// Extracted from auth-login / auth-register (T-09); see
// docs/01-specs/revision-edge-functions.md for the rationale.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
};

export const jsonHeaders = {
  ...corsHeaders,
  "Content-Type": "application/json",
};

export class HttpError extends Error {
  constructor(readonly status: number, message: string) {
    super(message);
    this.name = "HttpError";
  }
}

export function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: jsonHeaders,
  });
}

/**
 * Handles the CORS preflight and the method check shared by every function.
 * Returns a Response to short-circuit with, or null to continue.
 */
export function handlePreflight(request: Request, allowedMethod = "POST"): Response | null {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (request.method !== allowedMethod) {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }
  return null;
}

/**
 * Reads the JSON body; an empty body yields {}. A malformed body throws
 * HttpError(400) (previously surfaced as 500 — agreed improvement in T-09).
 */
export async function readBody(request: Request): Promise<Record<string, unknown>> {
  const text = await request.text();
  if (!text) {
    return {};
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new HttpError(400, "Invalid JSON body");
  }
}

/** Maps an unknown error to the JSON error response contract. */
export function errorResponse(error: unknown) {
  if (error instanceof HttpError) {
    return jsonResponse({ error: error.message }, error.status);
  }
  return jsonResponse(
    { error: error instanceof Error ? error.message : "Unexpected error" },
    500,
  );
}
