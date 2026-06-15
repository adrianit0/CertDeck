"use client";

import { getSupabaseClient } from "@/lib/supabase/client";
import { env } from "@/lib/env";

/**
 * Login contra la Edge Function compartida `auth-login` y PERSISTENCIA de la
 * sesión en el cliente.
 *
 * La función autentica en servidor (`signInWithPassword`) y devuelve la sesión;
 * aquí la guardamos con `auth.setSession`, de modo que el JWT queda persistido
 * (localStorage, `persistSession`) y todas las llamadas posteriores a las Edge
 * Functions de datos viajan autenticadas (RLS / `auth.uid()`).
 */

interface LoginResult {
  ok: boolean;
  error?: string;
}

interface AuthLoginResponse {
  session?: { access_token?: string; refresh_token?: string } | null;
  error?: string;
}

export async function login(email: string, password: string): Promise<LoginResult> {
  const trimmedEmail = email.trim();
  if (!trimmedEmail || !password) {
    return { ok: false, error: "Introduce tu email y contraseña." };
  }

  let body: AuthLoginResponse | null;
  try {
    const response = await fetch(`${env.supabaseUrl}/functions/v1/auth-login`, {
      method: "POST",
      headers: {
        apikey: env.supabasePublishableKey,
        Authorization: `Bearer ${env.supabasePublishableKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email: trimmedEmail, password }),
    });
    body = (await response.json().catch(() => null)) as AuthLoginResponse | null;

    if (!response.ok) {
      return { ok: false, error: body?.error ?? "Email o contraseña incorrectos." };
    }
  } catch {
    return { ok: false, error: "No se pudo conectar con el servidor. Inténtalo de nuevo." };
  }

  const session = body?.session;
  if (!session?.access_token || !session?.refresh_token) {
    return { ok: false, error: "La respuesta de login no incluyó una sesión válida." };
  }

  // Persiste la sesión: dispara SIGNED_IN y guarda el JWT para futuras llamadas.
  const { error } = await getSupabaseClient().auth.setSession({
    access_token: session.access_token,
    refresh_token: session.refresh_token,
  });
  if (error) return { ok: false, error: error.message };

  return { ok: true };
}

export async function logout(): Promise<void> {
  await getSupabaseClient().auth.signOut();
}
