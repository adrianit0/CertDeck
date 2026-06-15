"use client";

import { Loader2 } from "lucide-react";
import { useSession } from "@/hooks/useSession";
import AppShell from "@/features/shell/AppShell";
import LoginScreen from "./LoginScreen";

/**
 * Decide qué mostrar según la sesión:
 *  - mientras se resuelve la sesión inicial: spinner;
 *  - sin sesión: pantalla de login;
 *  - con sesión: la app.
 *
 * `useSession` se suscribe a los cambios de auth, así que al iniciar/cerrar
 * sesión el cambio de pantalla es automático.
 */
export default function AuthGate() {
  const { session, loading } = useSession();

  if (loading) {
    return (
      <div className="min-h-screen w-full bg-slate-100 flex flex-col items-center justify-center gap-4">
        <Loader2 className="w-9 h-9 text-brand-primary animate-spin" />
        <p className="text-sm font-bold text-slate-500">Cargando…</p>
      </div>
    );
  }

  if (!session) return <LoginScreen />;

  return <AppShell />;
}
