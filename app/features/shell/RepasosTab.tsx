"use client";

import { RotateCw, Files, AlertTriangle, Layers, Calendar, Flame, type LucideIcon } from "lucide-react";

interface ReviewSession {
  id: string;
  title: string;
  description: string;
  icon: LucideIcon;
  badgeColor: string;
  /** Si requiere errores acumulados, se deshabilita cuando no hay ninguno. */
  needsErrors?: boolean;
}

interface RepasosTabProps {
  onStartReview: (reviewType: string) => void;
  pendingErrors: number;
  completedLessons: number;
}

export default function RepasosTab({ onStartReview, pendingErrors, completedLessons }: RepasosTabProps) {
  const sessions: ReviewSession[] = [
    {
      id: "topic-review",
      title: "Repaso de Tema",
      description: "Sesión corta sobre los temas de la etapa activa con algoritmo ANKI.",
      icon: Files,
      badgeColor: "bg-blue-100 text-blue-600",
    },
    {
      id: "general-review",
      title: "Repaso General",
      description: "Prueba aleatoria acumulativa de todos los temas del curso activo.",
      icon: Layers,
      badgeColor: "bg-sky-100 text-sky-600",
    },
    {
      id: "topic-errors",
      title: "Errores de Tema",
      description: "Corrige y re-intenta las preguntas falladas de la etapa activa.",
      icon: AlertTriangle,
      badgeColor: "bg-amber-100 text-amber-600",
      needsErrors: true,
    },
    {
      id: "general-errors",
      title: "Errores Generales",
      description: "Práctica enfocada en todos tus fallos acumulados del curso.",
      icon: Calendar,
      badgeColor: "bg-rose-100 text-rose-600",
      needsErrors: true,
    },
  ];

  return (
    <div className="pb-24 pt-4 px-4 space-y-6">
      {/* Banner informativo */}
      <div className="bg-slate-900 text-white rounded-3xl p-6 relative overflow-hidden shadow-xl">
        <div className="absolute right-0 bottom-0 translate-x-4 translate-y-4 opacity-10">
          <RotateCw className="w-40 h-40 animate-[spin_40s_linear_infinite]" />
        </div>

        <div className="space-y-2 relative z-10">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 border border-white/5 text-[10px] uppercase font-bold tracking-wider">
            <Flame className="w-3.5 h-3.5 text-amber-400 fill-amber-400" /> Algoritmo Spaced Repetition
          </div>
          <h2 className="font-extrabold text-xl tracking-tight">Estudio con Curva de Olvido</h2>
          <p className="text-slate-300 text-xs leading-relaxed max-w-[280px]">
            CertDeck calcula automáticamente el intervalo óptimo para repasar conceptos clave. Consolida tus fallos antes
            de que se venzan.
          </p>
        </div>
      </div>

      {/* Métricas reales */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white border border-slate-100 rounded-2xl p-4.5 space-y-1 text-center shadow-[0_4px_12px_rgba(0,0,0,0.015)]">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Lecciones Completadas</span>
          <span className="text-3xl font-extrabold text-blue-600 tracking-tight">{completedLessons}</span>
          <span className="text-[10px] text-emerald-600 font-semibold block bg-emerald-50 py-0.5 rounded-full mt-1.5 border border-emerald-100/50">
            Disponibles para repasar
          </span>
        </div>
        <div className="bg-white border border-slate-100 rounded-2xl p-4.5 space-y-1 text-center shadow-[0_4px_12px_rgba(0,0,0,0.015)]">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Errores Pendientes</span>
          <span className="text-3xl font-extrabold text-rose-500 tracking-tight">{pendingErrors}</span>
          <span className="text-[10px] text-rose-600 font-semibold block bg-rose-50 py-0.5 rounded-full mt-1.5 border border-rose-100/50">
            Por recuperar
          </span>
        </div>
      </div>

      {/* Sesiones bajo demanda */}
      <div className="space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase ml-1">Sesiones bajo Demanda</h3>

        <div className="space-y-4">
          {sessions.map((session) => {
            const Icon = session.icon;
            const disabled = session.needsErrors === true && pendingErrors === 0;
            return (
              <button
                key={session.id}
                id={`btn-review-${session.id}`}
                disabled={disabled}
                onClick={() => onStartReview(session.id)}
                className={`w-full text-left bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_5px_15px_rgba(0,0,0,0.02)] transition-all duration-300 flex items-center justify-between gap-4 group ${
                  disabled
                    ? "opacity-50 cursor-not-allowed"
                    : "hover:border-slate-200 hover:shadow-md active:scale-[0.98]"
                }`}
              >
                <div className="flex items-start gap-4 flex-1">
                  <div className={`p-3.5 rounded-2xl shrink-0 ${session.badgeColor}`}>
                    <Icon className="w-6 h-6 stroke-[2]" />
                  </div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <h4 className="font-extrabold text-[15px] text-slate-800">{session.title}</h4>
                      {session.needsErrors && (
                        <span className="text-[10px] bg-slate-100 text-slate-500 font-bold px-2 py-0.5 rounded-full">
                          {pendingErrors} {pendingErrors === 1 ? "error" : "errores"}
                        </span>
                      )}
                    </div>
                    <p className="text-slate-500 text-xs leading-relaxed pr-2">{session.description}</p>
                  </div>
                </div>

                <div className="w-9 h-9 rounded-full bg-slate-50 group-hover:bg-brand-primary-light text-slate-400 group-hover:text-brand-primary flex items-center justify-center shrink-0 transition-all">
                  <RotateCw className="w-4 h-4" />
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
