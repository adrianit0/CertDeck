"use client";

import { Zap, TrendingUp, Star, Clock, AlarmClock, GraduationCap, Layers } from "lucide-react";
import type { UserStats, LessonWithStatus, Topic, Stage } from "@/lib/types";
import type { SrsSummary, ExamSummary } from "@/lib/progress/progressState";

interface ProgresosTabProps {
  stats: UserStats;
  lessons: LessonWithStatus[];
  topics: Topic[];
  activeStage: Stage;
  srs: SrsSummary;
  exam: ExamSummary;
}

export default function ProgresosTab({ stats, lessons, topics, activeStage, srs, exam }: ProgresosTabProps) {
  const courseLessons = lessons;
  const completedCourseLessons = lessons.filter((l) => l.status === "completed").length;
  const coursePercent = Math.round((completedCourseLessons / Math.max(courseLessons.length, 1)) * 100);

  const stageTopics = topics
    .filter((t) => t.stage_id === activeStage.id)
    .sort((a, b) => a.position - b.position);
  const stageLessons = lessons.filter((l) => stageTopics.some((t) => t.id === l.topic_id));
  const completedStageLessons = stageLessons.filter((l) => l.status === "completed").length;
  const stagePercent = Math.round((completedStageLessons / Math.max(stageLessons.length, 1)) * 100);

  // Avance por tema (RF-34 ampliado): % de lecciones completadas en cada tema.
  const topicProgress = stageTopics.map((t) => {
    const tLessons = lessons.filter((l) => l.topic_id === t.id);
    const done = tLessons.filter((l) => l.status === "completed").length;
    return {
      id: t.id,
      title: t.title,
      done,
      total: tLessons.length,
      percent: Math.round((done / Math.max(tLessons.length, 1)) * 100),
    };
  });

  const successRate =
    stats.totalAnswers > 0 ? Math.round((stats.correctAnswers / stats.totalAnswers) * 100) : 0;
  const examAccuracy = exam.attempts > 0 ? Math.round((exam.correct / exam.attempts) * 100) : 0;

  const xpForNextLevel = 1000;
  const currentXp = stats.xp % xpForNextLevel;
  const level = Math.floor(stats.xp / xpForNextLevel) + 1;
  const xpPercent = Math.round((currentXp / xpForNextLevel) * 100);

  const renderCircularProgress = (
    percent: number,
    size = 80,
    strokeWidth = 8,
    colorClass = "text-brand-primary",
  ) => {
    const radius = (size - strokeWidth) / 2;
    const circumference = radius * 2 * Math.PI;
    const strokeDashoffset = circumference - (percent / 100) * circumference;

    return (
      <div className="relative flex items-center justify-center shrink-0" style={{ width: size, height: size }}>
        <svg className="w-full h-full rotate-[-90deg]">
          <circle
            className="text-slate-100"
            strokeWidth={strokeWidth}
            stroke="currentColor"
            fill="transparent"
            r={radius}
            cx={size / 2}
            cy={size / 2}
          />
          <circle
            className={`${colorClass} transition-all duration-500 ease-out`}
            strokeWidth={strokeWidth}
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            stroke="currentColor"
            fill="transparent"
            r={radius}
            cx={size / 2}
            cy={size / 2}
          />
        </svg>
        <span className="absolute text-xs font-black text-slate-800">{percent}%</span>
      </div>
    );
  };

  return (
    <div className="pb-24 pt-4 px-4 space-y-6">
      {/* Nivel / XP */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <div className="flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-50 border border-amber-100 flex items-center justify-center text-amber-500">
              <Star className="w-5.5 h-5.5 fill-amber-400 stroke-amber-500" />
            </div>
            <div>
              <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider block">Nivel de Rango</span>
              <h3 className="font-extrabold text-slate-800 text-sm">Arquitecto Nivel {level}</h3>
            </div>
          </div>
          <span className="text-xs font-black text-slate-500 bg-slate-100 px-2.5 py-1 rounded-full">{stats.xp} XP Totales</span>
        </div>

        <div className="space-y-1.5">
          <div className="flex justify-between text-xs text-slate-400">
            <span>Progreso de nivel</span>
            <span className="font-bold text-slate-600">{currentXp} / {xpForNextLevel} XP</span>
          </div>
          <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden">
            <div className="h-full bg-gradient-to-r from-amber-400 to-amber-500 rounded-full transition-all duration-500" style={{ width: `${xpPercent}%` }} />
          </div>
        </div>
      </div>

      {/* Métricas grandes */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white border border-slate-100 rounded-3xl p-5 space-y-2 shadow-[0_4px_15px_rgba(0,0,0,0.01)] flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Racha Activa</span>
            <Zap className="w-5 h-5 text-amber-500 fill-amber-500" />
          </div>
          <div className="py-2">
            <span className="text-[34px] font-black text-slate-800 tracking-tight leading-none">{stats.streak}</span>
            <span className="text-xs font-semibold text-slate-500 ml-1.5">días</span>
          </div>
          <p className="text-[10px] text-emerald-600 font-semibold bg-emerald-50 py-1 rounded-full text-center border border-emerald-100/50">
            ¡Sigue así mañana!
          </p>
        </div>

        <div className="bg-white border border-slate-100 rounded-3xl p-5 space-y-2 shadow-[0_4px_15px_rgba(0,0,0,0.01)] flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Acierto Promedio</span>
            <TrendingUp className="w-5 h-5 text-emerald-500" />
          </div>
          <div className="py-2">
            <span className="text-[34px] font-black text-slate-800 tracking-tight leading-none">{successRate}%</span>
            <span className="text-xs font-semibold text-slate-500 ml-1.5">ratio</span>
          </div>
          <p className="text-[10px] text-blue-600 font-semibold bg-blue-50 py-1 rounded-full text-center border border-blue-100/50">
            Meta: mantener &gt;80%
          </p>
        </div>
      </div>

      {/* Anillos de cobertura */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Métricas de Cobertura</h3>

        <div className="space-y-4">
          <div className="flex items-center justify-between bg-slate-50/50 p-4 rounded-2xl border border-slate-100/50">
            <div className="space-y-1 pr-2">
              <h4 className="font-extrabold text-[14px] text-slate-800">Curso Completo</h4>
              <p className="text-[11px] text-slate-400 leading-relaxed">
                Lecciones completadas sobre el total del plan de estudio de AWS SAA-C03.
              </p>
              <span className="inline-block text-[10px] bg-blue-50 text-blue-600 font-semibold px-2 py-0.5 rounded-md mt-1">
                {completedCourseLessons} de {courseLessons.length} Temas
              </span>
            </div>
            {renderCircularProgress(coursePercent, 72, 7, "text-brand-primary")}
          </div>

          <div className="flex items-center justify-between bg-slate-50/50 p-4 rounded-2xl border border-slate-100/50">
            <div className="space-y-1 pr-2">
              <h4 className="font-extrabold text-[14px] text-slate-800">Etapa Activa</h4>
              <p className="text-[11px] text-slate-400 leading-relaxed">Avance en subtemas de {activeStage.title}.</p>
              <span className="inline-block text-[10px] bg-sky-50 text-sky-600 font-semibold px-2 py-0.5 rounded-md mt-1">
                {completedStageLessons} de {stageLessons.length} Bloques
              </span>
            </div>
            {renderCircularProgress(stagePercent, 72, 7, "text-brand-accent")}
          </div>
        </div>
      </div>

      {/* Repaso espaciado: tarjetas vencidas / por venir (RF-34) */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Repaso Espaciado</h3>
        <div className="grid grid-cols-3 gap-2.5">
          <div className="bg-rose-50/60 border border-rose-100 rounded-2xl p-3 text-center">
            <AlarmClock className="w-4 h-4 text-rose-500 mx-auto mb-1" />
            <span className="text-lg font-black text-rose-600 block leading-none">{srs.due}</span>
            <span className="text-[9px] text-slate-500 font-bold uppercase block mt-1">Vencidas</span>
          </div>
          <div className="bg-blue-50/60 border border-blue-100 rounded-2xl p-3 text-center">
            <Clock className="w-4 h-4 text-blue-500 mx-auto mb-1" />
            <span className="text-lg font-black text-blue-600 block leading-none">{srs.upcoming}</span>
            <span className="text-[9px] text-slate-500 font-bold uppercase block mt-1">Por venir</span>
          </div>
          <div className="bg-slate-50 border border-slate-100 rounded-2xl p-3 text-center">
            <Layers className="w-4 h-4 text-slate-500 mx-auto mb-1" />
            <span className="text-lg font-black text-slate-700 block leading-none">{srs.tracked}</span>
            <span className="text-[9px] text-slate-500 font-bold uppercase block mt-1">En estudio</span>
          </div>
        </div>
        {srs.due > 0 && (
          <p className="text-[11px] text-rose-600 font-semibold bg-rose-50 py-1.5 rounded-full text-center border border-rose-100/50">
            Tienes {srs.due} {srs.due === 1 ? "tarjeta vencida" : "tarjetas vencidas"} para repasar
          </p>
        )}
      </div>

      {/* Avance por tema de la etapa activa (RF-34 ampliado) */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">
          Avance por Tema · {activeStage.title}
        </h3>
        {topicProgress.length === 0 ? (
          <p className="text-xs text-slate-400">No hay temas en esta etapa.</p>
        ) : (
          <div className="space-y-3.5">
            {topicProgress.map((t) => (
              <div key={t.id} className="space-y-1.5">
                <div className="flex justify-between items-center gap-2">
                  <span className="text-[12px] font-bold text-slate-700 line-clamp-1">{t.title}</span>
                  <span className="text-[10px] font-bold text-slate-400 shrink-0">
                    {t.done}/{t.total}
                  </span>
                </div>
                <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-blue-500 to-sky-400 rounded-full transition-all duration-500"
                    style={{ width: `${t.percent}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Histórico de práctica de examen (RF-34 ampliado) */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Histórico de Examen</h3>
        <div className="flex justify-around divide-x divide-slate-100 py-2">
          <div className="text-center px-4 flex-1">
            <GraduationCap className="w-4 h-4 text-indigo-500 mx-auto mb-1" />
            <span className="font-extrabold text-slate-700 text-lg block">{exam.attempts}</span>
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Intentos</span>
          </div>
          <div className="text-center px-4 flex-1">
            <span className="font-extrabold text-emerald-500 text-lg block mt-5">{exam.correct}</span>
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Aciertos</span>
          </div>
          <div className="text-center px-4 flex-1">
            <span className="font-extrabold text-slate-700 text-lg block mt-5">{examAccuracy}%</span>
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Precisión</span>
          </div>
        </div>
      </div>

      {/* Estadísticas ANKI */}
      <div className="bg-white border border-slate-100 rounded-3xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.015)] space-y-4">
        <h3 className="text-xs font-semibold tracking-wider text-slate-400 uppercase">Estadísticas ANKI</h3>
        <div className="flex justify-around divide-x divide-slate-100 py-2">
          <div className="text-center px-4 flex-1">
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Lecciones</span>
            <span className="font-extrabold text-slate-700 text-lg block mt-0.5">{stats.lessonsCompleted}</span>
          </div>
          <div className="text-center px-4 flex-1">
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Tarjetas ANKI</span>
            <span className="font-extrabold text-slate-700 text-lg block mt-0.5">{stats.ankiCardsStudied}</span>
          </div>
          <div className="text-center px-4 flex-1">
            <span className="text-[10px] text-slate-400 font-semibold block uppercase">Respuestas</span>
            <span className="font-extrabold text-slate-700 text-lg block mt-0.5">{stats.totalAnswers}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
