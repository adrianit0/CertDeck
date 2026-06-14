"use client";

import { useEffect, useState } from "react";
import type { Session } from "@supabase/supabase-js";
import { getSupabaseClient } from "@/lib/supabase/client";

export interface SessionState {
  session: Session | null;
  /** true mientras se resuelve la sesión inicial. */
  loading: boolean;
}

/**
 * Lee la sesión actual de Supabase y se suscribe a sus cambios.
 *
 * IMPORTANTE: login y registro los gestionan Edge Functions COMPARTIDAS y
 * EXISTENTES (Constitución §4). Este hook SOLO consume la sesión resultante;
 * no inicia sesión ni la modifica.
 */
export function useSession(): SessionState {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const supabase = getSupabaseClient();
    let active = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!active) return;
      setSession(data.session);
      setLoading(false);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession);
    });

    return () => {
      active = false;
      subscription.unsubscribe();
    };
  }, []);

  return { session, loading };
}
