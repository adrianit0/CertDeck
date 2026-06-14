// Shared REST plumbing for the per-resource Gessalud data functions (ADR-006).
//
// Each resource is its own edge function (its own URI). Operations on that
// resource are distinguished by HTTP method: GET = list/read, POST = create,
// PUT = full update, PATCH = partial update, DELETE = delete. A function only
// ever serves one resource; two related entities (e.g. sleep logs vs sleep
// tags) are separate functions.

import { corsHeaders, errorResponse, HttpError, jsonResponse, readBody } from "./http.ts";
import { getUserClient } from "./supabase.ts";

// deno-lint-ignore no-explicit-any
type Client = any;
// deno-lint-ignore no-explicit-any
export type Body = Record<string, any>;

export interface MethodContext {
  client: Client;
  userId: string;
  body: Body;
}

export type MethodHandler = (ctx: MethodContext) => Promise<unknown>;

/** Throws HttpError(400) on a PostgREST error, otherwise returns the rows. */
// deno-lint-ignore no-explicit-any
export function unwrap<T>(result: { data: T; error: any }): T {
  if (result.error) {
    throw new HttpError(400, result.error.message ?? "Database error");
  }
  return result.data;
}

/** For writes without a returning select: throws on error, returns null. */
// deno-lint-ignore no-explicit-any
export function expectError(result: { error: any }) {
  if (result.error) {
    throw new HttpError(400, result.error.message ?? "Database error");
  }
  return null;
}

/**
 * Serves one resource: verifies the caller's JWT (RLS-scoped client), then
 * dispatches by HTTP method to the matching handler. `user_id` always comes
 * from the verified token, never the body.
 */
export function serveResource(handlers: Partial<Record<string, MethodHandler>>) {
  Deno.serve(async (request) => {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    try {
      const handler = handlers[request.method];
      if (!handler) {
        return jsonResponse({ error: "Method not allowed" }, 405);
      }

      const token = (request.headers.get("Authorization") ?? "").replace("Bearer ", "");
      if (!token) {
        throw new HttpError(401, "Missing authorization token");
      }
      const client = getUserClient(request);
      const { data: userData, error: userError } = await client.auth.getUser(token);
      if (userError || !userData?.user) {
        throw new HttpError(401, "No authenticated user");
      }

      const body = request.method === "GET" ? {} : await readBody(request);
      const result = await handler({ client, userId: userData.user.id, body });
      return jsonResponse({ data: result ?? null });
    } catch (error) {
      return errorResponse(error);
    }
  });
}
