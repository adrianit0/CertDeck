"use client";

import { useState } from "react";
import { User, Moon, Bell, HelpCircle, BookOpen, Check } from "lucide-react";
import type { Course, UserStats } from "@/lib/types";

interface PerfilTabProps {
  stats: UserStats;
  courses: Course[];
  activeCourse: Course;
  setActiveCourseId: (id: string) => void;
  onResetProgress: () => void;
  userName: string;
  userEmail: string | null;
}

export default function PerfilTab({
  stats,
  courses,
  activeCourse,
  setActiveCourseId,
  onResetProgress,
  userName,
  userEmail,
}: PerfilTabProps) {
  const [detailedExplanations, setDetailedExplanations] = useState(true);
  const [dailyReminder, setDailyReminder] = useState(true);
  const [darkMode, setDarkMode] = useState(false);

  return (
    <div className="pb-24 pt-4 px-4 space-y-6">
      {/* Cabecera de perfil */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] text-center space-y-3 relative overflow-hidden">
        <div className="absolute right-0 top-0 w-20 h-20 bg-brand-primary/5 rounded-full blur-xl" />

        <div className="relative inline-block mt-2">
          <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-blue-600 to-sky-400 p-0.5 shadow-lg mx-auto">
            <div className="w-full h-full bg-white rounded-full flex items-center justify-center text-blue-600">
              <User className="w-8 h-8 stroke-[1.8]" />
            </div>
          </div>
          <div className="absolute -bottom-1 -right-1 bg-amber-400 border border-white text-[10px] text-white font-extrabold px-1.5 py-0.5 rounded-full shadow">
            LVL {Math.floor(stats.xp / 1000) + 1}
          </div>
        </div>

        <div>
          <h2 className="font-extrabold text-slate-800 text-lg capitalize">{userName}</h2>
          <p className="text-xs text-slate-400 font-medium">{userEmail ?? "Sesión no iniciada"}</p>
        </div>

        <div className="bg-slate-50/70 border border-slate-100 rounded-2xl py-3 px-2 flex justify-around text-xs mt-1">
          <div>
            <span className="text-slate-400 block text-[9px] uppercase tracking-wider font-semibold">streak activo</span>
            <span className="font-extrabold text-slate-700 text-sm">{stats.streak} días🔥</span>
          </div>
          <div className="w-px bg-slate-200" />
          <div>
            <span className="text-slate-400 block text-[9px] uppercase tracking-wider font-semibold">xp acumuladas</span>
            <span className="font-extrabold text-slate-700 text-sm">{stats.xp} pts⭐</span>
          </div>
          <div className="w-px bg-slate-200" />
          <div>
            <span className="text-slate-400 block text-[9px] uppercase tracking-wider font-semibold">ANKI studied</span>
            <span className="font-extrabold text-slate-700 text-sm">{stats.ankiCardsStudied}</span>
          </div>
        </div>
      </div>

      {/* Cambiar curso activo */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Cambiar Curso Activo</h3>
          <span className="text-[10px] text-blue-600 font-bold bg-blue-50 px-2 py-0.5 rounded-full">{courses.length} Disponibles</span>
        </div>

        <div className="space-y-2.5">
          {courses.map((course) => {
            const isSelected = activeCourse.id === course.id;
            return (
              <button
                key={course.id}
                id={`btn-course-opt-${course.id}`}
                onClick={() => setActiveCourseId(course.id)}
                className={`w-full text-left p-4 rounded-2xl border transition-all duration-300 flex items-center justify-between ${
                  isSelected
                    ? "bg-brand-primary-light border-brand-primary shadow-sm"
                    : "bg-slate-50/50 border-slate-100 hover:bg-slate-50 hover:border-slate-200"
                }`}
              >
                <div className="flex items-start gap-3.5 pr-2">
                  <div className={`p-2.5 rounded-xl shrink-0 ${isSelected ? "bg-brand-primary text-white" : "bg-white border border-slate-100 text-slate-400"}`}>
                    <BookOpen className="w-4.5 h-4.5" />
                  </div>
                  <div>
                    <h4 className="font-extrabold text-[13px] text-slate-800 leading-tight">{course.title}</h4>
                    <p className="text-[10px] text-slate-400 mt-1 line-clamp-1">{course.description}</p>
                  </div>
                </div>

                <div className={`w-5 h-5 rounded-full flex items-center justify-center shrink-0 border ${isSelected ? "bg-brand-primary border-brand-primary text-white" : "border-slate-200 text-transparent"}`}>
                  {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Preferencias */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Ajustes & Preferencias</h3>

        <div className="divide-y divide-slate-100">
          {[
            {
              id: "opt-toggle-explanations",
              icon: HelpCircle,
              title: "Explicaciones de anki",
              subtitle: "Ver explicaciones en aciertos",
              value: detailedExplanations,
              onToggle: () => setDetailedExplanations((v) => !v),
            },
            {
              id: "opt-toggle-notifications",
              icon: Bell,
              title: "Recordatorio de Estudio",
              subtitle: "Notificación push todos los días",
              value: dailyReminder,
              onToggle: () => setDailyReminder((v) => !v),
            },
            {
              id: "opt-toggle-darkmode",
              icon: Moon,
              title: "Modo Oscuro",
              subtitle: "Disponible próximamente",
              value: darkMode,
              onToggle: () => setDarkMode((v) => !v),
            },
          ].map((pref) => {
            const Icon = pref.icon;
            return (
              <div key={pref.id} className="flex items-center justify-between py-3">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-slate-100 text-slate-500">
                    <Icon className="w-4 h-4" />
                  </div>
                  <div>
                    <span className="font-bold text-slate-700 text-xs block">{pref.title}</span>
                    <span className="text-[10px] text-slate-400">{pref.subtitle}</span>
                  </div>
                </div>
                <button
                  id={pref.id}
                  onClick={pref.onToggle}
                  className={`w-11 h-6 rounded-full transition-colors relative flex items-center p-0.5 focus:outline-none ${pref.value ? "bg-brand-primary" : "bg-slate-200"}`}
                  aria-pressed={pref.value}
                >
                  <div className={`w-5 h-5 bg-white rounded-full shadow transition-transform ${pref.value ? "translate-x-5" : "translate-x-0"}`} />
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Reset */}
      <div className="space-y-2">
        <button
          id="btn-reset-data"
          onClick={() => {
            if (window.confirm("¿Seguro que deseas reiniciar tu progreso de estudio? Volverás al inicio.")) {
              onResetProgress();
            }
          }}
          className="w-full text-center py-4 rounded-2xl border border-red-100 text-xs font-bold text-red-500 hover:bg-neutral-50 active:scale-[0.99] transition-all"
        >
          Reiniciar Todo el Progreso
        </button>
        <p className="text-[10px] text-slate-400 text-center leading-relaxed px-5">
          CertDeck • Tu progreso se guarda en este dispositivo y se sincroniza con tu cuenta.
        </p>
      </div>
    </div>
  );
}
