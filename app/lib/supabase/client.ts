"use client";

import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";

/**
 * Cliente Supabase único para el navegador (singleton).
 *
 * Centraliza TODO el acceso a Supabase: ningún componente debe crear su
 * propio cliente ni llamar a Supabase directamente (Constitución §8.5).
 *
 * Usa la clave pública (publishable/anon); la seguridad real la aplica RLS
 * en la base de datos. Nunca se incrusta la service_role en el cliente.
 */
let browserClient: SupabaseClient | undefined;

export function getSupabaseClient(): SupabaseClient {
  if (!browserClient) {
    browserClient = createClient(env.supabaseUrl, env.supabasePublishableKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    });
  }
  return browserClient;
}
