"use client";

import { useMemo, useState } from "react";
import {
  X,
  ArrowRight,
  CheckCircle,
  XCircle,
  Info,
  Trophy,
  Check,
  GraduationCap,
} from "lucide-react";
import type { ExamAttempt, ExamQuestion } from "@/lib/types";
import { gradeExamAnswer } from "@/lib/exam";
import { sessionXp } from "@/lib/xp";
import ReportControl from "@/components/ReportControl";

interface ExamPlayerProps {
  questions: ExamQuestion[];
  courseTitle: string;
  /** Devuelve los intentos del usuario para corrección/registro autoritativos. */
  onClose: (completed: boolean, attempts: ExamAttempt[]) => void;
}

/**
 * Reproductor de PRÁCTICA DE EXAMEN a pantalla completa (v3 · RF-26…29).
 * Una pasada: cada pregunta se responde (única o múltiple), se comprueba con la
 * regla de conjunto exacto (RF-29), se muestra el feedback y la `extra_information`,
 * y al final se devuelven los intentos al shell para la corrección autoritativa.
 */
export default function ExamPlayer({ questions, courseTitle, onClose }: ExamPlayerProps) {
  const [index, setIndex] = useState(0);
  const [selected, setSelected] = useState<string[]>([]);
  const [checked, setChecked] = useState(false);
  const [attempts, setAttempts] = useState<ExamAttempt[]>([]);
  const [finished, setFinished] = useState(false);

  const total = questions.length;
  const current = questions[index];
  const isMultiple = current?.typeId === 2;

  const localCorrect = useMemo(() => {
    if (!current) return false;
    return gradeExamAnswer(selected, current.options);
  }, [current, selected]);

  const correctSoFar = attempts.filter((a) => {
    const q = questions.find((x) => x.id === a.questionId);
    return q ? gradeExamAnswer(a.selectedAnswers, q.options) : false;
  }).length;

  if (!current) {
    return (
      <div className="fixed inset-0 z-50 bg-slate-50 flex flex-col items-center justify-center md:max-w-md mx-auto shadow-2xl p-8 text-center gap-5">
        <div className="w-16 h-16 rounded-3xl bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-400">
          <GraduationCap className="w-8 h-8" />
        </div>
        <div className="space-y-1">
          <h2 className="font-black text-slate-800 text-lg tracking-tight">Sin preguntas de examen</h2>
          <p className="text-sm text-slate-500 leading-relaxed max-w-[280px]">
            No hay preguntas para los filtros elegidos. Prueba con otro tema o dificultad.
          </p>
        </div>
        <button
          onClick={() => onClose(false, [])}
          className="px-6 py-3 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg"
        >
          Volver
        </button>
      </div>
    );
  }

  const toggleOption = (text: string) => {
    if (checked) return;
    if (isMultiple) {
      setSelected((prev) => (prev.includes(text) ? prev.filter((t) => t !== text) : [...prev, text]));
    } else {
      setSelected([text]);
    }
  };

  const handleCheck = () => {
    if (selected.length === 0 || checked) return;
    setChecked(true);
    setAttempts((prev) => [...prev, { questionId: current.id, selectedAnswers: selected }]);
  };

  const handleNext = () => {
    if (index < total - 1) {
      setIndex(index + 1);
      setSelected([]);
      setChecked(false);
    } else {
      setFinished(true);
    }
  };

  const progressPercent = Math.min(((index + (checked ? 1 : 0)) / total) * 100, 100);
  const finalScore = total > 0 ? Math.round((correctSoFar / total) * 100) : 0;

  return (
    <div className="fixed inset-0 z-50 bg-slate-50 flex flex-col md:max-w-md mx-auto shadow-2xl select-none">
      {/* Cabecera */}
      <header className="h-14 shrink-0 bg-white border-b border-slate-100 px-4 flex items-center justify-between gap-4">
        <button
          onClick={() => {
            if (finished || window.confirm("¿Salir de la práctica de examen? Perderás el progreso de esta tanda.")) {
              onClose(false, []);
            }
          }}
          className="w-10 h-10 -ml-1 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-50/50 transition"
          aria-label="Cerrar examen"
        >
          <X className="w-5.5 h-5.5 stroke-[2.2]" />
        </button>
        <div className="flex-1 text-center">
          <span className="text-[10px] font-black uppercase text-slate-400 tracking-wider">Práctica de Examen</span>
          <h2 className="text-xs font-bold text-slate-700 leading-tight truncate">{courseTitle}</h2>
        </div>
        {!finished ? (
          <ReportControl
            questionId={current.id}
            questionSource="exam"
            questionText={current.question}
            lessonId={current.lessonId}
            courseId={current.courseId}
          />
        ) : (
          <div className="w-10 h-10" />
        )}
      </header>

      {!finished && (
        <div className="w-full h-1 bg-slate-100 shrink-0">
          <div className="h-full bg-brand-primary transition-all duration-300 ease-out" style={{ width: `${progressPercent}%` }} />
        </div>
      )}

      <main className="flex-1 overflow-y-auto no-scrollbar p-5 flex flex-col justify-between">
        {!finished ? (
          <div className="flex flex-col h-full justify-between gap-6 py-2">
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <span className="text-[10px] font-bold text-slate-400 tracking-wider uppercase bg-slate-100 px-2.5 py-1 rounded-md">
                  Pregunta {index + 1} de {total}
                </span>
                <span className="text-[10px] text-brand-accent font-black">
                  {isMultiple ? "RESPUESTA MÚLTIPLE" : "RESPUESTA ÚNICA"}
                </span>
              </div>

              <h3 className="font-extrabold text-slate-800 text-[18px] leading-snug tracking-tight">{current.question}</h3>

              {isMultiple && !checked && (
                <p className="text-[11px] font-semibold text-slate-400">
                  Marca todas las correctas. Solo cuenta si el conjunto es exacto.
                </p>
              )}
            </div>

            <div className="flex-1 flex flex-col justify-center py-2">
              <div className="space-y-3 w-full">
                {current.options.map((option, idx) => {
                  const isSelected = selected.includes(option.text);
                  let bgClass = isSelected
                    ? "bg-brand-primary-light border-brand-primary text-slate-800 font-bold"
                    : "bg-white hover:bg-slate-50 border-slate-100 text-slate-700";
                  let icon = null;

                  if (checked) {
                    if (option.isCorrect) {
                      bgClass = "bg-emerald-50 border-emerald-300 text-emerald-800 font-bold shadow-sm";
                      icon = <CheckCircle className="w-4.5 h-4.5 text-emerald-600 shrink-0" />;
                    } else if (isSelected) {
                      bgClass = "bg-rose-50 border-rose-200 text-rose-800";
                      icon = <XCircle className="w-4.5 h-4.5 text-rose-600 shrink-0" />;
                    } else {
                      bgClass = "bg-white border-slate-100 text-slate-400 opacity-60";
                    }
                  }

                  return (
                    <button
                      key={idx}
                      id={`btn-exam-opt-${idx}`}
                      disabled={checked}
                      onClick={() => toggleOption(option.text)}
                      className={`w-full p-4 rounded-2xl border text-left flex items-center justify-between text-xs font-semibold leading-relaxed focus:outline-none transition-all active:scale-[0.99] ${bgClass}`}
                    >
                      <span className="mr-3 flex items-center gap-2.5">
                        {!checked && isMultiple && (
                          <span
                            className={`w-4 h-4 rounded-md border flex items-center justify-center shrink-0 ${
                              isSelected ? "bg-brand-primary border-brand-primary text-white" : "border-slate-300 text-transparent"
                            }`}
                          >
                            <Check className="w-3 h-3 stroke-[3]" />
                          </span>
                        )}
                        {option.text}
                      </span>
                      {icon}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="pt-4 shrink-0 space-y-4">
              {checked && (
                <div
                  className={`rounded-2xl p-4 text-[11px] leading-relaxed border ${
                    localCorrect
                      ? "bg-emerald-50/50 border-emerald-100 text-emerald-800"
                      : "bg-rose-50/40 border-rose-100 text-rose-800"
                  }`}
                >
                  <span className="font-extrabold uppercase tracking-wider block mb-1 flex items-center gap-1.5">
                    {localCorrect ? <CheckCircle className="w-3.5 h-3.5" /> : <XCircle className="w-3.5 h-3.5" />}
                    {localCorrect ? "¡Correcto!" : "Respuesta incorrecta"}
                  </span>
                  {current.extraInformation && (
                    <span className="flex gap-1.5 text-slate-600 mt-1.5">
                      <Info className="w-3.5 h-3.5 text-blue-500 shrink-0 mt-0.5" />
                      {current.extraInformation}
                    </span>
                  )}
                </div>
              )}

              {!checked ? (
                <button
                  id="btn-exam-check"
                  disabled={selected.length === 0}
                  onClick={handleCheck}
                  className={`w-full py-4 rounded-2xl font-extrabold text-sm shadow flex items-center justify-center gap-2 transition-all ${
                    selected.length > 0
                      ? "bg-brand-primary text-white hover:bg-brand-primary-hover cursor-pointer"
                      : "bg-slate-200 text-slate-400 cursor-not-allowed"
                  }`}
                >
                  Comprobar Respuesta
                </button>
              ) : (
                <button
                  id="btn-exam-next"
                  onClick={handleNext}
                  className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow flex items-center justify-center gap-2 active:scale-95 transition"
                >
                  {index < total - 1 ? "Siguiente Pregunta" : "Ver Resultados"} <ArrowRight className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        ) : (
          <div className="flex flex-col h-full justify-between gap-6 py-4 text-center">
            <div className="space-y-6 pt-5 flex-1 flex flex-col justify-center">
              <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-blue-500 to-sky-400 flex items-center justify-center text-white mx-auto shadow-lg shadow-blue-400/20">
                <Trophy className="w-10 h-10 stroke-[1.8]" />
              </div>
              <div className="space-y-2">
                <span className="text-[10px] bg-blue-100 text-blue-700 font-extrabold px-3.5 py-1 rounded-full uppercase tracking-wider">
                  Simulacro Finalizado
                </span>
                <h2 className="font-black text-slate-800 text-[22px] tracking-tight">Resultado del Examen</h2>
              </div>
              <div className="grid grid-cols-3 gap-2.5 py-2">
                <div className="bg-white border border-slate-100 rounded-2xl p-4 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">Aciertos</span>
                  <span className="text-lg font-black text-emerald-500 block mt-0.5">{correctSoFar} / {total}</span>
                </div>
                <div className="bg-white border border-slate-100 rounded-2xl p-4 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">Nota</span>
                  <span className="text-lg font-black text-slate-700 block mt-0.5">{finalScore}%</span>
                </div>
                <div className="bg-white border border-slate-100 rounded-2xl p-4 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">XP</span>
                  <span className="text-lg font-black text-amber-500 block mt-0.5">+{sessionXp(finalScore)}</span>
                </div>
              </div>
              <div className="p-4 bg-slate-100/50 border border-slate-100 rounded-2xl text-[12px] text-slate-600 leading-relaxed max-w-[320px] mx-auto">
                {finalScore >= 72
                  ? "Por encima del umbral típico de aprobado (72%). ¡Buen nivel de preparación!"
                  : "Aún por debajo del umbral de aprobado (72%). Repasa los temas con más fallos y vuelve a intentarlo."}
              </div>
            </div>
            <div className="pt-6 shrink-0">
              <button
                id="btn-exam-finalize"
                onClick={() => onClose(true, attempts)}
                className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg flex items-center justify-center gap-2 active:scale-95 transition-all"
              >
                Volver al Menú Central
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
