"use client";

import { useState } from "react";
import {
  ChevronDown,
  Lock,
  Play,
  CheckCircle2,
  Compass,
  Trophy,
  RotateCw,
  AlertCircle,
  FileText,
  Sparkles,
  Zap,
  Flame,
  Check,
  X,
} from "lucide-react";
import type { Course, Stage, Topic, LessonWithStatus, LessonStatus, LessonType } from "@/lib/types";

interface CoursesTabProps {
  courses: Course[];
  stages: Stage[];
  topics: Topic[];
  lessons: LessonWithStatus[];
  activeCourse: Course;
  activeStage: Stage;
  setActiveCourseId: (id: string) => void;
  setActiveStageId: (id: string) => void;
  onStartLesson: (lessonId: string) => void;
}

export default function CoursesTab({
  courses,
  stages,
  topics,
  lessons,
  activeCourse,
  activeStage,
  setActiveCourseId,
  setActiveStageId,
  onStartLesson,
}: CoursesTabProps) {
  const [selectorOpen, setSelectorOpen] = useState(false);

  const filteredStages = stages.filter((s) => s.course_id === activeCourse.id);
  const filteredTopics = topics.filter((t) => t.stage_id === activeStage.id);

  const stageLessonsTotal = lessons.filter((l) =>
    topics.some((t) => t.id === l.topic_id && t.stage_id === activeStage.id),
  ).length;
  const stageLessonsDone = lessons.filter(
    (l) =>
      l.status === "completed" &&
      topics.some((t) => t.id === l.topic_id && t.stage_id === activeStage.id),
  ).length;
  const stagePercent = (stageLessonsDone / Math.max(stageLessonsTotal, 1)) * 100;

  const getLessonTypeIcon = (type: LessonType, status: LessonStatus) => {
    const color = status === "locked" ? "text-slate-400" : "text-brand-primary";
    switch (type) {
      case "review":
        return <RotateCw className={`w-4 h-4 ${color}`} />;
      case "error_correction":
        return <AlertCircle className={`w-4 h-4 ${status === "locked" ? "text-slate-400" : "text-amber-500"}`} />;
      case "expansion":
        return <Compass className={`w-4 h-4 ${color}`} />;
      case "final":
        return <Trophy className={`w-4 h-4 ${status === "locked" ? "text-slate-400" : "text-purple-500 font-bold"}`} />;
      default:
        return <FileText className={`w-4 h-4 ${color}`} />;
    }
  };

  const getLessonTypeLabel = (type: LessonType) => {
    switch (type) {
      case "review":
        return "Repaso Espaciado";
      case "error_correction":
        return "Consolidación de Errores";
      case "expansion":
        return "Tema de Expansión";
      case "final":
        return "Evaluación Final";
      default:
        return "Lección Teórica";
    }
  };

  const getLessonStatusBadge = (status: LessonStatus) => {
    switch (status) {
      case "completed":
        return (
          <span className="flex items-center gap-1 text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-100">
            <CheckCircle2 className="w-3.5 h-3.5" /> Completado
          </span>
        );
      case "in_progress":
        return (
          <span className="flex items-center gap-1 text-[11px] font-semibold text-amber-600 bg-amber-50 px-2.5 py-1 rounded-full border border-amber-100">
            <Flame className="w-3.5 h-3.5 animate-pulse" /> En progreso
          </span>
        );
      case "available":
        return (
          <span className="flex items-center gap-1 text-[11px] font-semibold text-blue-600 bg-blue-50 px-2.5 py-1 rounded-full border border-blue-100">
            <Sparkles className="w-3.5 h-3.5" /> Disponible
          </span>
        );
      case "locked":
      default:
        return (
          <span className="flex items-center gap-1 text-[11px] font-semibold text-slate-400 bg-slate-100 px-2.5 py-1 rounded-full">
            <Lock className="w-3 h-3" /> Bloqueado
          </span>
        );
    }
  };

  return (
    <div className="pb-24 pt-4 px-4 space-y-6">
      {/* Selector fusionado curso + etapa (un único botón compacto) */}
      <button
        id="course-stage-selector-btn"
        onClick={() => setSelectorOpen(true)}
        className="w-full flex items-center justify-between bg-white px-4 py-3 rounded-2xl border border-slate-100 shadow-[0_4px_12px_rgba(0,0,0,0.02)] text-left focus:outline-none focus:ring-2 focus:ring-brand-primary/20 active:scale-[0.99] transition-all"
      >
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-2.5 h-9 rounded-full bg-brand-primary shrink-0" />
          <div className="min-w-0">
            <h3 className="font-bold text-[14px] text-slate-800 line-clamp-1 leading-tight">{activeCourse.title}</h3>
            <p className="text-[12px] text-slate-500 line-clamp-1 mt-0.5">{activeStage.title}</p>
          </div>
        </div>
        <ChevronDown className="w-5 h-5 text-slate-400 shrink-0" />
      </button>

      {/* Tarjeta de progreso de la etapa */}
      <div className="bg-gradient-to-r from-blue-600 to-sky-500 rounded-3xl p-5 text-white shadow-xl flex items-center justify-between relative overflow-hidden">
        <div className="absolute -right-6 -bottom-6 w-24 h-24 bg-white/10 rounded-full blur-xl" />
        <div className="space-y-1 relative z-10">
          <h3 className="font-bold text-lg">Progreso de la Etapa</h3>
          <p className="text-white/80 text-xs">
            {stageLessonsDone} de {stageLessonsTotal} lecciones completadas
          </p>
          <div className="w-48 h-2 bg-white/20 rounded-full mt-3 overflow-hidden">
            <div className="h-full bg-white transition-all duration-500" style={{ width: `${stagePercent}%` }} />
          </div>
        </div>
        <div className="bg-white/15 p-3 rounded-2xl relative z-10 backdrop-blur-md">
          <Zap className="w-6 h-6 text-yellow-300 fill-yellow-300" />
        </div>
      </div>

      {/* Contenido completo de la etapa (todo desplegado, sin acordeones) */}
      {filteredTopics.length === 0 ? (
        <div className="bg-white rounded-2xl p-8 border border-slate-100 text-center space-y-2">
          <p className="text-sm font-medium text-slate-500">No hay temas cargados en esta etapa.</p>
        </div>
      ) : (
        <div className="space-y-5">
          {filteredTopics.map((topic) => {
            const topicLessons = lessons.filter((l) => l.topic_id === topic.id);

            return (
              <div key={topic.id} className="space-y-3">
                {/* Cabecera del tema [TÍTULO] */}
                <div className="px-1 space-y-1">
                  <h4 className="font-black text-slate-800 text-sm tracking-tight">[{topic.title.toUpperCase()}]</h4>
                  <p className="text-xs text-slate-400">{topic.description}</p>
                </div>

                {/* Sinopsis del tema */}
                {topic.summary && (
                  <div className="bg-blue-50/30 border border-blue-50 rounded-2xl p-3.5 text-xs text-slate-600 font-medium leading-relaxed">
                    <span className="font-bold text-brand-primary block text-[10px] uppercase tracking-wider mb-1">Sinopsis del Tema</span>
                    {topic.summary}
                  </div>
                )}

                {/* Lecciones del tema */}
                <div className="space-y-3">
                  {topicLessons.map((lesson) => {
                    const isLocked = lesson.status === "locked";
                    const inProgress = lesson.status === "in_progress";

                    return (
                      <div
                        key={lesson.id}
                        className={`rounded-2xl border p-4 transition-all duration-300 relative overflow-hidden ${
                          isLocked
                            ? "bg-slate-50/70 border-slate-100 opacity-60"
                            : "bg-white border-slate-100 shadow-[0_2px_8px_rgba(0,0,0,0.01)] hover:border-slate-200"
                        }`}
                      >
                        <div className="flex justify-between items-start gap-3">
                          <div className="space-y-1 flex-1">
                            <div className="flex items-center gap-2 flex-wrap">
                              {getLessonStatusBadge(lesson.status)}
                              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wide flex items-center gap-1.5 bg-slate-100 px-2 py-0.5 rounded-full">
                                {getLessonTypeIcon(lesson.lesson_type, lesson.status)}
                                {getLessonTypeLabel(lesson.lesson_type)}
                              </span>
                            </div>

                            <h5 className="font-bold text-slate-800 text-[14px] pt-1.5">{lesson.title}</h5>
                            {lesson.description && <p className="text-xs text-slate-500 line-clamp-2">{lesson.description}</p>}
                          </div>

                          <div>
                            <button
                              id={`btn-start-${lesson.id}`}
                              disabled={isLocked}
                              onClick={() => onStartLesson(lesson.id)}
                              className={`w-11 h-11 rounded-2xl flex items-center justify-center transition-all focus:outline-none ${
                                isLocked
                                  ? "bg-slate-100 text-slate-300 cursor-not-allowed"
                                  : lesson.status === "completed"
                                    ? "bg-emerald-50 text-emerald-600 hover:bg-emerald-100"
                                    : "bg-brand-primary text-white hover:bg-brand-primary-hover shadow-lg shadow-blue-500/20 active:scale-95"
                              }`}
                              aria-label="Comenzar lección"
                            >
                              {lesson.status === "completed" ? (
                                <RotateCw className="w-5 h-5 stroke-[2.2]" />
                              ) : (
                                <Play className="w-5 h-5 fill-current stroke-[1.5] translate-x-0.5" />
                              )}
                            </button>
                          </div>
                        </div>

                        {inProgress && (
                          <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                            <span className="text-slate-400 font-medium">Completado parcial</span>
                            <span className="font-bold text-amber-500 animate-pulse">Retomar ahora</span>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Popup selector de curso + etapa */}
      {selectorOpen && (
        <div className="fixed inset-0 z-50 flex flex-col justify-end md:items-center md:justify-center md:max-w-md mx-auto">
          {/* Backdrop */}
          <button
            aria-label="Cerrar selector"
            onClick={() => setSelectorOpen(false)}
            className="absolute inset-0 bg-slate-900/40 backdrop-blur-[1px]"
          />

          {/* Panel */}
          <div className="relative bg-slate-50 rounded-t-3xl md:rounded-3xl border border-slate-100 shadow-2xl max-h-[80%] flex flex-col w-full overflow-hidden">
            <div className="flex items-center justify-between px-5 py-4 bg-white border-b border-slate-100 shrink-0">
              <h3 className="font-extrabold text-slate-800 text-sm">Curso y etapa de estudio</h3>
              <button
                onClick={() => setSelectorOpen(false)}
                className="w-9 h-9 -mr-1 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition"
                aria-label="Cerrar"
              >
                <X className="w-5 h-5 stroke-[2.2]" />
              </button>
            </div>

            <div className="overflow-y-auto no-scrollbar p-5 space-y-6">
              {/* Curso activo */}
              <div className="space-y-2">
                <span className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase ml-1">Curso Activo</span>
                <div className="bg-white border border-slate-100 rounded-2xl overflow-hidden divide-y divide-slate-50">
                  {courses.map((course) => {
                    const isSelected = activeCourse.id === course.id;
                    return (
                      <button
                        key={course.id}
                        onClick={() => {
                          setActiveCourseId(course.id);
                          const firstStage = stages.find((s) => s.course_id === course.id);
                          if (firstStage) setActiveStageId(firstStage.id);
                        }}
                        className={`w-full text-left px-4 py-3.5 flex items-center justify-between gap-3 hover:bg-slate-50 focus:outline-none transition-colors ${
                          isSelected ? "bg-brand-primary-light/50" : ""
                        }`}
                      >
                        <div className="min-w-0">
                          <h4 className="font-bold text-sm text-slate-800 line-clamp-1">{course.title}</h4>
                          <p className="text-xs text-slate-400 mt-0.5 line-clamp-1">{course.description}</p>
                        </div>
                        <div
                          className={`w-5 h-5 rounded-full flex items-center justify-center shrink-0 border ${
                            isSelected ? "bg-brand-primary border-brand-primary text-white" : "border-slate-200 text-transparent"
                          }`}
                        >
                          {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Etapa de estudio */}
              <div className="space-y-2">
                <span className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase ml-1">Etapa de Estudio</span>
                <div className="bg-white border border-slate-100 rounded-2xl overflow-hidden divide-y divide-slate-50">
                  {filteredStages.map((stage) => {
                    const isSelected = activeStage.id === stage.id;
                    return (
                      <button
                        key={stage.id}
                        onClick={() => {
                          setActiveStageId(stage.id);
                          setSelectorOpen(false);
                        }}
                        className={`w-full text-left px-4 py-3.5 flex items-center justify-between gap-3 hover:bg-slate-50 focus:outline-none transition-colors ${
                          isSelected ? "bg-sky-50/50" : ""
                        }`}
                      >
                        <div className="min-w-0">
                          <h5 className="font-bold text-xs text-slate-700 line-clamp-1">{stage.title}</h5>
                          <p className="text-[11px] text-slate-400 mt-0.5 line-clamp-1">{stage.description}</p>
                        </div>
                        <div
                          className={`w-5 h-5 rounded-full flex items-center justify-center shrink-0 border ${
                            isSelected ? "bg-brand-accent border-brand-accent text-white" : "border-slate-200 text-transparent"
                          }`}
                        >
                          {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
