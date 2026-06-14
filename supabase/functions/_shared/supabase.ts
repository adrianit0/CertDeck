// Shared Supabase client helpers for Gessalud edge functions (T-09).

import { createClient } from "npm:@supabase/supabase-js@2";

export function getRequiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`${name} is not configured.`);
  }
  return value;
}

/** Client bound to the anon key: used for auth operations on behalf of the user. */
export function getAnonClient() {
  return createClient(getRequiredEnv("SUPABASE_URL"), getRequiredEnv("SUPABASE_ANON_KEY"));
}

/**
 * Client bound to the service role key: bypasses RLS. Only for privileged
 * server-side steps (profile upsert, role assignment); never expose its output
 * without filtering.
 */
export function getAdminClient() {
  return createClient(
    getRequiredEnv("SUPABASE_URL"),
    getRequiredEnv("SUPABASE_SERVICE_ROLE_KEY"),
  );
}

/**
 * Client scoped to the caller's JWT (the `Authorization` header that
 * supabase-js attaches to `functions.invoke`). All queries run as that user,
 * so Row Level Security enforces ownership exactly as a direct client would —
 * the function adds a single audited entry point and server-side validation,
 * without bypassing RLS (ADR-006).
 */
export function getUserClient(request: Request) {
  const authorization = request.headers.get("Authorization") ?? "";
  return createClient(getRequiredEnv("SUPABASE_URL"), getRequiredEnv("SUPABASE_ANON_KEY"), {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
