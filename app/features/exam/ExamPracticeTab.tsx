"use client";

import { useState, type ReactNode } from "react";
import { GraduationCap, Layers, BarChart2, Play, Loader2, Target } from "lucide-react";
import type { Course, ExamFilters, Topic } from "@/lib/types";

interface ExamPracticeTabProps {
  activeCourse: Course;
  topics: Topic[];
  onStartExam: (filters: ExamFilters) => void;
  examLoading: boolean;
  offline: boolean;
  examAttempts: number;
  examAccuracy: number;
}

const DIFFICULTIES: { value: number | null; label: string }[] = [
  { value: null, label: "Todas" },
  { value: 1, label: "Básica" },
  { value: 2, label: "Fácil" },
  { value: 3, label: "Media" },
  { value: 4, label: "Difícil" },
  { value: 5, label: "Experta" },
];

const SIZES = [5, 10, 20];

/**
 * Sección de PRÁCTICA DIRECTA DE EXAMEN (v3 · RF-26). Configura filtros (tema,
 * dificultad, nº de preguntas) y lanza el simulacro. Muestra el histórico de
 * práctica (intentos/acierto) que devuelve el progreso real.
 */
export default function ExamPracticeTab({
  activeCourse,
  topics,
  onStartExam,
  examLoading,
  offline,
  examAttempts,
  examAccuracy,
}: ExamPracticeTabProps) {
  const [topicId, setTopicId] = useState<string | null>(null);
  const [difficulty, setDifficulty] = useState<number | null>(null);
  const [size, setSize] = useState(10);

  const courseTopics = [...topics].sort((a, b) => a.position - b.position);

  return (
    <div className="pb-24 pt-4 px-4 space-y-6">
      {/* Banner */}
      <div className="bg-gradient-to-br from-indigo-600 to-blue-500 text-white rounded-3xl p-6 relative overflow-hidden shadow-xl">
        <div className="absolute right-0 bottom-0 translate-x-4 translate-y-4 opacity-10">
          <GraduationCap className="w-40 h-40" />
        </div>
        <div className="space-y-2 relative z-10">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 border border-white/5 text-[10px] uppercase font-bold tracking-wider">
            <Target className="w-3.5 h-3.5 text-amber-300" /> Modo Certificación
          </div>
          <h2 className="font-extrabold text-xl tracking-tight">Práctica de Examen</h2>
          <p className="text-white/80 text-xs leading-relaxed max-w-[280px]">
            Preguntas tipo examen de {activeCourse.title}, con respuesta única y múltiple. En las
            múltiples solo cuenta el conjunto exacto.
          </p>
        </div>
      </div>

      {/* Histórico */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white border border-slate-100 rounded-2xl p-4.5 space-y-1 text-center shadow-[0_4px_12px_rgba(0,0,0,0.015)]">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Intentos de Examen</span>
          <span className="text-3xl font-extrabold text-indigo-600 tracking-tight">{examAttempts}</span>
          <span className="text-[10px] text-slate-500 font-semibold block mt-1.5">preguntas respondidas</span>
        </div>
        <div className="bg-white border border-slate-100 rounded-2xl p-4.5 space-y-1 text-center shadow-[0_4px_12px_rgba(0,0,0,0.015)]">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Acierto en Examen</span>
          <span className="text-3xl font-extrabold text-emerald-500 tracking-tight">{examAccuracy}%</span>
          <span className="text-[10px] text-slate-500 font-semibold block mt-1.5">histórico acumulado</span>
        </div>
      </div>

      {/* Filtros */}
      <div className="space-y-5">
        {/* Tema */}
        <div className="space-y-2">
          <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase ml-1 flex items-center gap-1.5">
            <Layers className="w-3.5 h-3.5" /> Tema
          </h3>
          <div className="flex flex-wrap gap-2">
            <FilterChip active={topicId === null} onClick={() => setTopicId(null)}>
              Todos
            </FilterChip>
            {courseTopics.map((t) => (
              <FilterChip key={t.id} active={topicId === t.id} onClick={() => setTopicId(t.id)}>
                {t.title}
              </FilterChip>
            ))}
          </div>
        </div>

        {/* Dificultad */}
        <div className="space-y-2">
          <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase ml-1 flex items-center gap-1.5">
            <BarChart2 className="w-3.5 h-3.5" /> Dificultad
          </h3>
          <div className="flex flex-wrap gap-2">
            {DIFFICULTIES.map((d) => (
              <FilterChip key={d.label} active={difficulty === d.value} onClick={() => setDifficulty(d.value)}>
                {d.label}
              </FilterChip>
            ))}
          </div>
        </div>

        {/* Nº de preguntas */}
        <div className="space-y-2">
          <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase ml-1">Nº de Preguntas</h3>
          <div className="flex gap-2">
            {SIZES.map((s) => (
              <FilterChip key={s} active={size === s} onClick={() => setSize(s)}>
                {s}
              </FilterChip>
            ))}
          </div>
        </div>
      </div>

      {/* Lanzar */}
      <button
        id="btn-start-exam"
        disabled={examLoading || offline}
        onClick={() =>
          onStartExam({ courseId: activeCourse.id, topicId, difficulty, limit: size })
        }
        className={`w-full py-4 rounded-2xl font-extrabold text-sm shadow-lg flex items-center justify-center gap-2 transition-all ${
          examLoading || offline
            ? "bg-slate-200 text-slate-400 cursor-not-allowed"
            : "bg-brand-primary text-white hover:bg-brand-primary-hover active:scale-[0.99]"
        }`}
      >
        {examLoading ? (
          <>
            <Loader2 className="w-4 h-4 animate-spin" /> Preparando examen…
          </>
        ) : (
          <>
            <Play className="w-4 h-4 fill-current" /> Comenzar Práctica
          </>
        )}
      </button>
      {offline && (
        <p className="text-[11px] text-center text-rose-500 font-semibold -mt-3">
          Sin conexión no se puede iniciar la práctica.
        </p>
      )}
    </div>
  );
}

function FilterChip({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={`px-3.5 py-2 rounded-xl text-xs font-bold border transition-all active:scale-95 ${
        active
          ? "bg-brand-primary text-white border-brand-primary shadow-sm"
          : "bg-white text-slate-600 border-slate-200 hover:border-slate-300"
      }`}
    >
      {children}
    </button>
  );
}
