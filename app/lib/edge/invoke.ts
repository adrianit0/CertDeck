"use client";

import { getSupabaseClient } from "@/lib/supabase/client";
import { env } from "@/lib/env";

/**
 * Punto único de acceso al backend desde el cliente: TODA llamada a datos pasa
 * por una Edge Function (nunca se consulta a las tablas directamente). Cada
 * recurso tiene su propia función; el método HTTP distingue la operación
 * (GET = lectura, POST/PUT/PATCH/DELETE = escritura) cuando el recurso lo
 * necesite.
 *
 * Adjunta el JWT del usuario (para que RLS y `auth.uid()` apliquen en la
 * función) y la `apikey` pública que exige el gateway de Supabase.
 */

type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

interface InvokeOptions {
  method?: HttpMethod;
  /** Parámetros de query (los arrays se repiten: `?id=a&id=b`). */
  query?: Record<string, string | string[] | undefined>;
  /** Cuerpo JSON para escrituras. */
  body?: unknown;
}

function buildUrl(fn: string, query?: InvokeOptions["query"]): string {
  const url = new URL(`${env.supabaseUrl}/functions/v1/${fn}`);
  if (query) {
    for (const [key, value] of Object.entries(query)) {
      if (value === undefined) continue;
      if (Array.isArray(value)) value.forEach((v) => url.searchParams.append(key, v));
      else url.searchParams.set(key, value);
    }
  }
  return url.toString();
}

export async function invokeEdge<T>(fn: string, options: InvokeOptions = {}): Promise<T> {
  const { method = "GET", query, body } = options;

  const {
    data: { session },
  } = await getSupabaseClient().auth.getSession();
  const token = session?.access_token ?? env.supabasePublishableKey;

  const headers: Record<string, string> = {
    apikey: env.supabasePublishableKey,
    Authorization: `Bearer ${token}`,
  };
  if (body !== undefined) headers["Content-Type"] = "application/json";

  const response = await fetch(buildUrl(fn, query), {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  const payload = (await response.json().catch(() => null)) as { data?: T; error?: string } | null;

  if (!response.ok) {
    throw new Error(payload?.error ?? `La función ${fn} falló (HTTP ${response.status}).`);
  }

  return (payload?.data ?? null) as T;
}
