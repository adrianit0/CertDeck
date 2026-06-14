import type { Session, User } from "@supabase/supabase-js";
import { getSupabaseClient } from "@/lib/supabase/client";

/**
 * Helpers de sesión sin React (para usar fuera de componentes).
 * Login/registro son externos (Edge Functions compartidas); aquí solo se LEE.
 */

export async function getCurrentSession(): Promise<Session | null> {
  const { data } = await getSupabaseClient().auth.getSession();
  return data.session;
}

export async function getCurrentUser(): Promise<User | null> {
  const { data } = await getSupabaseClient().auth.getUser();
  return data.user;
}
