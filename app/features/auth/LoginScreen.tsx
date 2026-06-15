"use client";

import { useState, type FormEvent } from "react";
import { Trophy, Mail, Lock, Loader2, AlertCircle, ArrowRight } from "lucide-react";
import { login } from "@/lib/auth/login";

/**
 * Pantalla de inicio de sesión. Autentica vía la Edge Function `auth-login` y
 * persiste la sesión (ver `lib/auth/login`). Al persistirla, `useSession`
 * detecta SIGNED_IN y el `AuthGate` muestra la app automáticamente.
 */
export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (submitting) return;
    setSubmitting(true);
    setError(null);

    const result = await login(email, password);
    if (!result.ok) {
      setError(result.error ?? "No se pudo iniciar sesión.");
      setSubmitting(false);
    }
    // En éxito no hay que hacer nada: SIGNED_IN provoca el cambio de pantalla.
  };

  return (
    <div className="h-full sm:h-auto sm:min-h-screen w-full bg-slate-100 flex justify-center items-center py-0 sm:py-6 px-0 sm:px-4">
      <div className="w-full max-w-md h-full sm:h-auto sm:min-h-[850px] sm:max-h-[880px] bg-slate-50 relative flex flex-col rounded-none sm:rounded-[40px] shadow-none sm:shadow-2xl border border-transparent sm:border-slate-100 overflow-hidden">
        <div className="flex-1 flex flex-col justify-center px-7 py-10">
          {/* Marca */}
          <div className="flex flex-col items-center gap-3 mb-10">
            <div className="w-16 h-16 rounded-3xl bg-brand-primary flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
              <Trophy className="w-8 h-8 text-amber-300 fill-amber-300 stroke-[1.5]" />
            </div>
            <div className="text-center">
              <h1 className="font-black text-slate-800 text-2xl tracking-tight">CertDeck</h1>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Smart ANKI Engine</p>
            </div>
          </div>

          <div className="space-y-1 mb-6">
            <h2 className="font-black text-slate-800 text-xl tracking-tight">Inicia sesión</h2>
            <p className="text-sm text-slate-500">Accede para continuar con tus certificaciones.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Email */}
            <div className="space-y-1.5">
              <label htmlFor="login-email" className="text-xs font-bold text-slate-500 ml-1">
                Email
              </label>
              <div className="relative">
                <Mail className="w-4.5 h-4.5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
                <input
                  id="login-email"
                  type="email"
                  autoComplete="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  disabled={submitting}
                  placeholder="tu@email.com"
                  className="w-full bg-white pl-11 pr-4 py-3.5 rounded-2xl border border-slate-100 focus:outline-none focus:ring-2 focus:ring-brand-primary placeholder-slate-300 shadow-sm text-sm disabled:opacity-60"
                />
              </div>
            </div>

            {/* Contraseña */}
            <div className="space-y-1.5">
              <label htmlFor="login-password" className="text-xs font-bold text-slate-500 ml-1">
                Contraseña
              </label>
              <div className="relative">
                <Lock className="w-4.5 h-4.5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
                <input
                  id="login-password"
                  type="password"
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={submitting}
                  placeholder="••••••••"
                  className="w-full bg-white pl-11 pr-4 py-3.5 rounded-2xl border border-slate-100 focus:outline-none focus:ring-2 focus:ring-brand-primary placeholder-slate-300 shadow-sm text-sm disabled:opacity-60"
                />
              </div>
            </div>

            {error && (
              <div className="flex items-center gap-2 text-[12px] font-semibold text-rose-600 bg-rose-50 rounded-xl p-3 border border-rose-100">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <button
              id="btn-login"
              type="submit"
              disabled={submitting}
              className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg shadow-blue-500/10 flex items-center justify-center gap-2 active:scale-[0.99] transition-all disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {submitting ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" /> Entrando…
                </>
              ) : (
                <>
                  Entrar <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          <p className="text-[11px] text-slate-400 text-center leading-relaxed mt-8 px-4">
            La autenticación se realiza de forma segura en el servidor (Edge Function) y tu sesión se guarda en este dispositivo.
          </p>
        </div>
      </div>
    </div>
  );
}
