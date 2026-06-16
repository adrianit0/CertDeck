"use client";

import { useState, useEffect, Fragment, type ReactNode } from "react";
import {
  X,
  ArrowRight,
  RotateCw,
  CheckCircle,
  XCircle,
  AlertCircle,
  HelpCircle,
  Trophy,
  Check,
  Zap,
  Loader2,
} from "lucide-react";
import type { LessonScreen, FlashcardQuestion, SessionResult } from "@/lib/types";
import { getPlayableLesson } from "@/lib/queries/content";
import ReportControl from "@/components/ReportControl";

interface LessonPlayerProps {
  lessonId: string;
  isReviewSession?: boolean;
  reviewType?: string;
  /** Preguntas ya cargadas de BD para las sesiones de repaso. */
  reviewQuestions?: FlashcardQuestion[];
  onClose: (completed: boolean, result: SessionResult | null) => void;
  activeCourseTitle: string;
  activeCourseId?: string | null;
}

type PlayerStep = "content" | "exercises" | "correction_intro" | "corrections" | "results";

interface AnswerRecord {
  primaryCorrect: boolean;
  finalCorrect: boolean;
  userChoice?: string;
  ankiDifficulty?: "fail" | "correct" | "easy";
  neededPista?: boolean;
}

export default function LessonPlayer({
  lessonId,
  isReviewSession = false,
  reviewQuestions = [],
  onClose,
  activeCourseTitle,
  activeCourseId = null,
}: LessonPlayerProps) {
  const [screens, setScreens] = useState<LessonScreen[]>([]);
  const [questions, setQuestions] = useState<FlashcardQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);

  useEffect(() => {
    let active = true;

    // Repaso: las preguntas ya vienen cargadas desde BD por el shell.
    if (isReviewSession) {
      setScreens([]);
      setQuestions(reviewQuestions);
      setLoadError(false);
      setLoading(false);
      return;
    }

    // Lección normal: contenido real (pantallas + preguntas) desde Supabase.
    setLoading(true);
    setLoadError(false);
    getPlayableLesson(lessonId)
      .then((data) => {
        if (!active) return;
        setScreens(data?.screens ?? []);
        setQuestions(data?.questions ?? []);
        setLoading(false);
      })
      .catch(() => {
        if (!active) return;
        setLoadError(true);
        setLoading(false);
      });

    return () => {
      active = false;
    };
  }, [lessonId, isReviewSession, reviewQuestions]);

  const [playerStep, setPlayerStep] = useState<PlayerStep>("content");

  const [contentIndex, setContentIndex] = useState(0);
  const [exerciseIndex, setExerciseIndex] = useState(0);
  const [correctionIndex, setCorrectionIndex] = useState(0);

  const [activeOptions, setActiveOptions] = useState<string[]>([]);
  const [isAnswered, setIsAnswered] = useState(false);
  const [selectedOptionIndex, setSelectedOptionIndex] = useState<number | null>(null);

  const [ankiFlipped, setAnkiFlipped] = useState(false);
  const [ankiEvaluation, setAnkiEvaluation] = useState<"fail" | "correct" | "easy" | null>(null);

  const [textInputValue, setTextInputValue] = useState("");
  const [pistaUnlocked, setPistaUnlocked] = useState(false);

  const [answersLog, setAnswersLog] = useState<Record<string, AnswerRecord>>({});
  const [failedList, setFailedList] = useState<FlashcardQuestion[]>([]);
  const [, setRecoveredCount] = useState(0);

  // Empezar directamente con ejercicios SOLO si, ya cargado el contenido, no
  // hay pantallas de teoría (p. ej. repasos). Mientras carga no se salta, para
  // no perder las tarjetas de teoría que llegan de forma asíncrona.
  useEffect(() => {
    if (!loading && screens.length === 0 && playerStep === "content") {
      setPlayerStep("exercises");
    }
  }, [loading, screens, playerStep]);

  const activeQuestion: FlashcardQuestion | null =
    playerStep === "exercises"
      ? questions[exerciseIndex] ?? null
      : playerStep === "corrections"
        ? failedList[correctionIndex] ?? null
        : null;

  const currentScreen: LessonScreen | undefined = playerStep === "content" ? screens[contentIndex] : undefined;

  // Estabiliza las alternativas para no rebarajar en cada render.
  useEffect(() => {
    if (!activeQuestion) return;

    setIsAnswered(false);
    setSelectedOptionIndex(null);
    setAnkiFlipped(false);
    setAnkiEvaluation(null);
    setTextInputValue("");
    setPistaUnlocked(answersLog[activeQuestion.id]?.neededPista || false);

    if (activeQuestion.exercise_type === "multiple_choice") {
      const options = [activeQuestion.correct_answer, activeQuestion.incorrect_answer_1, activeQuestion.incorrect_answer_2].filter(
        (x): x is string => x !== null && x !== undefined,
      );
      const shuffled = [...options];
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const a = shuffled[i] as string;
        const b = shuffled[j] as string;
        shuffled[i] = b;
        shuffled[j] = a;
      }
      setActiveOptions(shuffled);
    } else if (activeQuestion.exercise_type === "true_false") {
      setActiveOptions(["Verdadero", "Falso"]);
    } else {
      setActiveOptions([]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [exerciseIndex, correctionIndex, playerStep, activeQuestion]);

  // Normaliza para comparar (tolera mayúsculas, espacios y tildes).
  const getCleanStr = (str: string) =>
    str.trim().toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");

  // Renderiza **negrita** Markdown.
  const formatMarkdownText = (text: string): ReactNode => {
    if (!text) return "";
    const segments = text.split(/\*\*([^*]+)\*\*/g);
    return segments.map((seg, i) =>
      i % 2 === 1 ? (
        <strong key={i} className="font-extrabold text-brand-primary underline decoration-sky-100 decoration-wavy decoration-2">
          {seg}
        </strong>
      ) : (
        seg
      ),
    );
  };

  const handleMultipleChoiceSelect = (index: number) => {
    if (isAnswered || !activeQuestion) return;
    setSelectedOptionIndex(index);
    setIsAnswered(true);

    const chosen = activeOptions[index];
    const isCorrect = chosen === activeQuestion.correct_answer;
    const isPrimary = playerStep === "exercises";
    setAnswersLog((prev) => ({
      ...prev,
      [activeQuestion.id]: {
        primaryCorrect: isPrimary ? isCorrect : prev[activeQuestion.id]?.primaryCorrect || false,
        finalCorrect: isCorrect,
        userChoice: chosen,
      },
    }));
  };

  const handleTrueFalseSelect = (answer: string) => {
    if (isAnswered || !activeQuestion) return;
    setIsAnswered(true);
    setSelectedOptionIndex(answer === "Verdadero" ? 0 : 1);

    const isCorrect = getCleanStr(answer) === getCleanStr(activeQuestion.correct_answer);
    const isPrimary = playerStep === "exercises";
    setAnswersLog((prev) => ({
      ...prev,
      [activeQuestion.id]: {
        primaryCorrect: isPrimary ? isCorrect : prev[activeQuestion.id]?.primaryCorrect || false,
        finalCorrect: isCorrect,
        userChoice: answer,
      },
    }));
  };

  const handleTextInputVerify = () => {
    if (isAnswered || !activeQuestion) return;

    const isCorrect = getCleanStr(textInputValue) === getCleanStr(activeQuestion.correct_answer);
    const isPrimary = playerStep === "exercises";

    if (isCorrect) {
      setIsAnswered(true);
      setAnswersLog((prev) => ({
        ...prev,
        [activeQuestion.id]: {
          primaryCorrect: isPrimary ? true : prev[activeQuestion.id]?.primaryCorrect || false,
          finalCorrect: true,
          userChoice: textInputValue,
          neededPista: pistaUnlocked,
        },
      }));
    } else if (isPrimary) {
      setIsAnswered(true);
      setAnswersLog((prev) => ({
        ...prev,
        [activeQuestion.id]: { primaryCorrect: false, finalCorrect: false, userChoice: textInputValue },
      }));
    } else if (!pistaUnlocked) {
      // Ronda de corrección: una pista + 1 reintento.
      setPistaUnlocked(true);
      setAnswersLog((prev) => ({
        ...prev,
        [activeQuestion.id]: { ...prev[activeQuestion.id], primaryCorrect: false, finalCorrect: false, neededPista: true },
      }));
      setTextInputValue("");
    } else {
      setIsAnswered(true);
      setAnswersLog((prev) => ({
        ...prev,
        [activeQuestion.id]: { ...prev[activeQuestion.id], primaryCorrect: false, finalCorrect: false },
      }));
    }
  };

  const handleAnkiEvaluation = (val: "fail" | "correct" | "easy") => {
    if (ankiEvaluation || !activeQuestion) return;
    setAnkiEvaluation(val);

    const isCorrect = val === "correct" || val === "easy";
    const isPrimary = playerStep === "exercises";
    setAnswersLog((prev) => ({
      ...prev,
      [activeQuestion.id]: {
        primaryCorrect: isPrimary ? isCorrect : prev[activeQuestion.id]?.primaryCorrect || false,
        finalCorrect: isCorrect,
        ankiDifficulty: val,
      },
    }));

    setTimeout(() => advanceFlowAfterAnswer(), 900);
  };

  // Progreso.
  const totalScreens = screens.length;
  const totalExercises = questions.length;
  const currentStepNum =
    playerStep === "content"
      ? contentIndex + 1
      : playerStep === "results"
        ? totalScreens + totalExercises + 1
        : totalScreens + exerciseIndex + 1;
  const totalOverallSteps = totalScreens + totalExercises;
  const overallPercent = Math.min((currentStepNum / Math.max(totalOverallSteps, 1)) * 100, 100);

  const advanceFlowAfterAnswer = () => {
    if (playerStep === "exercises") {
      if (exerciseIndex < questions.length - 1) {
        setExerciseIndex(exerciseIndex + 1);
      } else {
        const failed: FlashcardQuestion[] = [];
        questions.forEach((q) => {
          const log = answersLog[q.id];
          if (!log || !log.primaryCorrect) failed.push(q);
        });
        if (failed.length > 0) {
          setFailedList(failed);
          setPlayerStep("correction_intro");
        } else {
          setPlayerStep("results");
        }
      }
    } else if (playerStep === "corrections") {
      const activeQ = failedList[correctionIndex];
      if (activeQ && answersLog[activeQ.id]?.finalCorrect) {
        setRecoveredCount((p) => p + 1);
      }
      if (correctionIndex < failedList.length - 1) {
        setCorrectionIndex(correctionIndex + 1);
      } else {
        setPlayerStep("results");
      }
    }
  };

  const primaryCorrectCount = Object.values(answersLog).filter((l) => l.primaryCorrect).length;
  const finalCorrectCount = Object.values(answersLog).filter((l) => l.finalCorrect).length;
  const totalCorrectToReport = Math.max(primaryCorrectCount, finalCorrectCount);
  const correctRate = Math.round((totalCorrectToReport / Math.max(totalExercises, 1)) * 100);
  const xpGained = totalCorrectToReport * 50 + (isReviewSession ? 100 : 250);

  // Empaqueta el resultado real de la sesión para persistir progreso y métricas.
  const buildSessionResult = (): SessionResult => ({
    correctCount: totalCorrectToReport,
    incorrectCount: Math.max(totalExercises - totalCorrectToReport, 0),
    scorePercentage: correctRate,
    ankiCount: questions.filter((q) => q.exercise_type === "anki_card").length,
    xpGained,
    failedQuestions: questions
      .filter((q) => !answersLog[q.id]?.finalCorrect)
      .map((q) => ({ id: q.id, lessonId: q.lesson_id })),
    passedQuestionIds: questions.filter((q) => answersLog[q.id]?.finalCorrect).map((q) => q.id),
    // Grade por tarjeta para SM-2: en ANKI se usa la autoevaluación; en el resto
    // de tipos se deriva del acierto final (correcto/fallo).
    cardReviews: questions
      .filter((q) => answersLog[q.id])
      .map((q) => {
        const log = answersLog[q.id]!;
        const grade =
          q.exercise_type === "anki_card"
            ? (log.ankiDifficulty ?? (log.finalCorrect ? "correct" : "fail"))
            : log.finalCorrect
              ? "correct"
              : "fail";
        return { questionId: q.id, grade };
      }),
  });

  const renderTextInputBlanks = () => {
    if (!activeQuestion) return null;
    const characters = activeQuestion.correct_answer.split("");

    return (
      <div className="flex flex-wrap justify-center gap-2 py-4">
        {characters.map((char, index) => {
          if (char === " ") return <div key={index} className="w-5" />;
          const shouldRevealClue = pistaUnlocked && index === 1;
          const typed = textInputValue[index];

          return (
            <div
              key={index}
              className={`w-9 h-11 border-2 rounded-xl flex items-center justify-center font-black text-lg transition-all ${
                shouldRevealClue
                  ? "bg-amber-50 border-amber-300 text-amber-600 shadow-sm scale-105"
                  : isAnswered
                    ? "bg-slate-100 border-slate-200 text-slate-700"
                    : "bg-white border-slate-200 text-slate-800"
              }`}
            >
              {shouldRevealClue ? char.toUpperCase() : isAnswered ? (typed ? typed.toUpperCase() : "_") : "_"}
            </div>
          );
        })}
      </div>
    );
  };

  // Estados de carga / error / sin contenido (datos reales de BD).
  if (loading || loadError || (screens.length === 0 && questions.length === 0)) {
    return (
      <div className="fixed inset-0 z-50 bg-slate-50 flex flex-col items-center justify-center md:max-w-md mx-auto shadow-2xl p-8 text-center gap-5">
        {loading ? (
          <>
            <Loader2 className="w-10 h-10 text-brand-primary animate-spin" />
            <p className="text-sm font-bold text-slate-500">Cargando sesión…</p>
          </>
        ) : (
          <>
            <div className="w-16 h-16 rounded-3xl bg-rose-50 border border-rose-100 flex items-center justify-center text-rose-500">
              <AlertCircle className="w-8 h-8" />
            </div>
            <div className="space-y-1">
              <h2 className="font-black text-slate-800 text-lg tracking-tight">
                {loadError ? "No se pudo cargar la sesión" : "Sin contenido disponible"}
              </h2>
              <p className="text-sm text-slate-500 leading-relaxed max-w-[280px]">
                {loadError
                  ? "Revisa tu conexión o inicia sesión e inténtalo de nuevo."
                  : "Esta sesión todavía no tiene preguntas ni teoría cargadas."}
              </p>
            </div>
            <button
              onClick={() => onClose(false, null)}
              className="px-6 py-3 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg"
            >
              Volver
            </button>
          </>
        )}
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 bg-slate-50 flex flex-col md:max-w-md mx-auto shadow-2xl select-none">
      {/* Cabecera */}
      <header className="h-14 shrink-0 bg-white border-b border-slate-100 px-4 flex items-center justify-between gap-4">
        <button
          id="btn-close-session"
          onClick={() => {
            if (window.confirm("¿Seguro que quieres salir de la lección? Perderás el progreso de esta tanda.")) {
              onClose(false, null);
            }
          }}
          className="w-10 h-10 -ml-1 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-50/50 transition"
          aria-label="Cerrar lección"
        >
          <X className="w-5.5 h-5.5 stroke-[2.2]" />
        </button>

        <div className="flex-1 text-center min-w-0 px-2">
          <span className="block truncate text-[10px] font-black uppercase text-slate-400 tracking-wider">
            {isReviewSession ? "Sesión de Repaso" : activeCourseTitle}
          </span>
          <h2 className="text-xs font-bold text-slate-700 leading-tight truncate">
            {playerStep === "content" ? `Teoría (${contentIndex + 1}/${screens.length})` : "Sesión Interactiva"}
          </h2>
        </div>

        {(playerStep === "exercises" || playerStep === "corrections") && activeQuestion ? (
          <ReportControl
            questionId={activeQuestion.id}
            questionSource="flashcard"
            questionText={activeQuestion.question}
            lessonId={activeQuestion.lesson_id}
            courseId={activeCourseId}
          />
        ) : (
          <div className="w-10 h-10" />
        )}
      </header>

      {/* Barra de progreso */}
      {playerStep !== "results" && (
        <div className="w-full h-1 bg-slate-100 shrink-0">
          <div className="h-full bg-brand-primary transition-all duration-300 ease-out" style={{ width: `${overallPercent}%` }} />
        </div>
      )}

      <main className="flex-1 overflow-y-auto no-scrollbar p-5 flex flex-col justify-between">
        {/* CASO 1: TEORÍA */}
        {playerStep === "content" && currentScreen && (
          <div className="flex flex-col h-full justify-between gap-6 py-4">
            <div className="space-y-6 pt-3">
              {currentScreen.title && (
                <span className="text-xs bg-brand-primary-light text-brand-primary font-black px-3.5 py-1.5 rounded-2xl border border-blue-100">
                  {currentScreen.title}
                </span>
              )}

              <div className="text-[16px] leading-relaxed text-slate-700 space-y-4 pt-4 font-medium tracking-wide">
                {currentScreen.body.split("\n\n").map((para, pIdx) => {
                  const lines = para.split("\n");
                  return (
                    <p key={pIdx}>
                      {lines.map((line, lIdx) => (
                        <Fragment key={lIdx}>
                          {formatMarkdownText(line)}
                          {lIdx < lines.length - 1 && <br />}
                        </Fragment>
                      ))}
                    </p>
                  );
                })}
              </div>
            </div>

            <div className="pt-6 shrink-0">
              <button
                id="btn-content-next"
                onClick={() => {
                  if (contentIndex < screens.length - 1) setContentIndex(contentIndex + 1);
                  else setPlayerStep("exercises");
                }}
                className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg shadow-blue-500/10 flex items-center justify-center gap-2 active:scale-[0.99] transition-all"
              >
                Continuar <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* CASO 2: MOTOR DE EJERCICIOS */}
        {(playerStep === "exercises" || playerStep === "corrections") && activeQuestion && (
          <div className="flex flex-col h-full justify-between gap-6 py-2">
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <span className="text-[10px] font-bold text-slate-400 tracking-wider uppercase bg-slate-100 px-2.5 py-1 rounded-md">
                  {playerStep === "corrections" ? "Ronda de Corrección" : `Pregunta ${exerciseIndex + 1} de ${totalExercises}`}
                </span>
                <span className="text-[10px] text-brand-accent font-black">
                  {activeQuestion.exercise_type === "anki_card" && "TARJETA ANKI"}
                  {activeQuestion.exercise_type === "multiple_choice" && "OPCIÓN MÚLTIPLE"}
                  {activeQuestion.exercise_type === "true_false" && "VERDADERO o FALSO"}
                  {activeQuestion.exercise_type === "text_input" && "EJERCICIO DE ESCRITURA"}
                </span>
              </div>

              <h3 className="font-extrabold text-slate-800 text-[18px] leading-snug tracking-tight">{activeQuestion.question}</h3>
            </div>

            <div className="flex-1 flex flex-col justify-center py-4">
              {/* ANKI con volteo 3D */}
              {activeQuestion.exercise_type === "anki_card" && (
                <div className="w-full py-2 flex flex-col items-center">
                  <div
                    onClick={() => setAnkiFlipped(!ankiFlipped)}
                    id="anki-flippable-card"
                    className={`w-full h-64 cursor-pointer perspective-1000 ${ankiFlipped ? "rotate-y-180" : ""} duration-500 preserve-3d transition-transform relative`}
                  >
                    <div className="absolute inset-0 bg-white border-2 border-dashed border-sky-200 rounded-3xl p-6 flex flex-col justify-between items-center text-center shadow-sm backface-hidden">
                      <div className="w-12 h-12 rounded-full bg-sky-50 flex items-center justify-center text-brand-accent mb-2">
                        <HelpCircle className="w-6 h-6 animate-bounce" />
                      </div>
                      <p className="text-sm font-bold text-slate-400">Toca este naipe para revelar la respuesta y evaluar tu memoria</p>
                      <span className="text-[10px] text-brand-primary font-bold uppercase tracking-wider bg-brand-primary-light px-3 py-1 rounded-full">Ver reverso</span>
                    </div>

                    <div className="absolute inset-0 bg-white border border-brand-primary rounded-3xl p-6 flex flex-col justify-between items-center text-center shadow-lg rotate-y-180 backface-hidden">
                      <div className="w-10 h-10 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500">
                        <Check className="w-5 h-5 stroke-[2.5]" />
                      </div>
                      <div className="space-y-1 overflow-y-auto max-h-[120px] px-1">
                        <span className="text-[10px] text-slate-400 font-extrabold uppercase">Respuesta Correcta</span>
                        <p className="text-slate-800 font-black text-sm leading-relaxed">{activeQuestion.correct_answer}</p>
                      </div>
                      <span className="text-[11px] font-bold text-emerald-600 bg-emerald-50/50 px-2.5 py-0.5 rounded-md">Puntuación Espaciada</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Opción múltiple */}
              {activeQuestion.exercise_type === "multiple_choice" && (
                <div className="space-y-3 w-full">
                  {activeOptions.map((option, idx) => {
                    const isSelected = selectedOptionIndex === idx;
                    const isCorrectOption = option === activeQuestion.correct_answer;

                    let bgClass = "bg-white hover:bg-slate-50 border-slate-100 text-slate-700";
                    let checkIcon: ReactNode = null;
                    if (isAnswered) {
                      if (isCorrectOption) {
                        bgClass = "bg-emerald-50 border-emerald-300 text-emerald-800 font-bold shadow-sm";
                        checkIcon = <CheckCircle className="w-4.5 h-4.5 text-emerald-600 shrink-0" />;
                      } else if (isSelected) {
                        bgClass = "bg-rose-50 border-rose-200 text-rose-800";
                        checkIcon = <XCircle className="w-4.5 h-4.5 text-rose-600 shrink-0" />;
                      } else {
                        bgClass = "bg-white border-slate-100 text-slate-400 opacity-60";
                      }
                    }

                    return (
                      <button
                        key={idx}
                        id={`btn-alt-${idx}`}
                        disabled={isAnswered}
                        onClick={() => handleMultipleChoiceSelect(idx)}
                        className={`w-full p-4 rounded-2xl border text-left flex items-center justify-between text-xs font-semibold leading-relaxed focus:outline-none transition-all active:scale-[0.99] ${bgClass}`}
                      >
                        <span className="mr-3">{option}</span>
                        {checkIcon}
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Verdadero / Falso */}
              {activeQuestion.exercise_type === "true_false" && (
                <div className="grid grid-cols-2 gap-3.5 w-full">
                  {["Verdadero", "Falso"].map((optText, idx) => {
                    const isSelected = selectedOptionIndex === idx;
                    const isCorrectOption = optText === activeQuestion.correct_answer;

                    let bgClass = "bg-white hover:bg-slate-50 border-slate-100 text-slate-700";
                    if (isAnswered) {
                      if (isCorrectOption) bgClass = "bg-emerald-50 border-emerald-300 text-emerald-800 font-black shadow-sm text-center";
                      else if (isSelected) bgClass = "bg-rose-50 border-rose-200 text-rose-800 text-center";
                      else bgClass = "bg-white border-slate-100 text-slate-400 opacity-60 text-center";
                    }

                    return (
                      <button
                        key={idx}
                        id={`btn-tf-${idx}`}
                        disabled={isAnswered}
                        onClick={() => handleTrueFalseSelect(optText)}
                        className={`py-6 px-4 rounded-2xl border font-extrabold text-[15px] focus:outline-none transition-all active:scale-[0.98] ${bgClass}`}
                      >
                        <span>{optText}</span>
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Respuesta escrita */}
              {activeQuestion.exercise_type === "text_input" && (
                <div className="space-y-4 w-full">
                  {renderTextInputBlanks()}

                  <div className="relative">
                    <input
                      type="text"
                      id="text-input-field"
                      placeholder={pistaUnlocked ? "Sugerencia activada. Escribe la palabra..." : "Escribe tu respuesta aquí"}
                      value={textInputValue}
                      onChange={(e) => setTextInputValue(e.target.value)}
                      disabled={isAnswered}
                      className="w-full bg-white px-5 py-3.5 rounded-2xl border border-slate-100 focus:outline-none focus:ring-2 focus:ring-brand-primary placeholder-slate-300 shadow-sm text-sm"
                    />
                  </div>

                  {pistaUnlocked && !isAnswered && (
                    <div className="flex items-center gap-1.5 justify-center text-[11px] font-bold text-amber-600 bg-amber-50 rounded-xl p-2.5 border border-amber-100">
                      <AlertCircle className="w-4 h-4 text-amber-500 shrink-0" />
                      <span>Se ha revelado la segunda letra como pista. ¡Tienes 1 intento más!</span>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Botones inferiores */}
            <div className="pt-4 shrink-0 space-y-4 bg-slate-50/50">
              {isAnswered && activeQuestion.explanation && (
                <div className="bg-blue-50/40 border border-blue-50 rounded-2xl p-4 text-[11px] leading-relaxed text-slate-600">
                  <span className="font-extrabold text-blue-600 uppercase tracking-wider block mb-1">Fundamento</span>
                  {activeQuestion.explanation}
                </div>
              )}

              {activeQuestion.exercise_type === "anki_card" && ankiFlipped ? (
                <div className="flex gap-2 w-full">
                  <button id="anki-btn-fail" onClick={() => handleAnkiEvaluation("fail")} className="flex-1 py-3.5 rounded-2xl bg-rose-500 text-white font-black text-xs hover:bg-rose-600 cursor-pointer shadow-lg shadow-rose-500/10 transition active:scale-95 text-center">
                    Incorrecto
                  </button>
                  <button id="anki-btn-correct" onClick={() => handleAnkiEvaluation("correct")} className="flex-1 py-3.5 rounded-2xl bg-brand-primary text-white font-black text-xs hover:bg-brand-primary-hover cursor-pointer shadow-lg shadow-blue-500/10 transition active:scale-95 text-center">
                    Correcto
                  </button>
                  <button id="anki-btn-easy" onClick={() => handleAnkiEvaluation("easy")} className="flex-1 py-3.5 rounded-2xl bg-sky-400 text-white font-black text-xs hover:bg-sky-500 cursor-pointer shadow-lg shadow-sky-500/10 transition active:scale-95 text-center">
                    Muy fácil
                  </button>
                </div>
              ) : activeQuestion.exercise_type === "anki_card" && !ankiFlipped ? (
                <button id="btn-reveal-card" onClick={() => setAnkiFlipped(true)} className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow">
                  Revelar Reverso
                </button>
              ) : null}

              {activeQuestion.exercise_type === "text_input" && !isAnswered && (
                <button
                  id="btn-verify-text"
                  disabled={!textInputValue.trim()}
                  onClick={handleTextInputVerify}
                  className={`w-full py-4 rounded-2xl font-extrabold text-sm shadow flex items-center justify-center gap-2 transition-all ${
                    textInputValue.trim() ? "bg-brand-primary text-white hover:bg-brand-primary-hover cursor-pointer duration-300" : "bg-slate-200 text-slate-400 cursor-not-allowed"
                  }`}
                >
                  Verificar Respuesta
                </button>
              )}

              {isAnswered && activeQuestion.exercise_type !== "anki_card" && (
                <button id="btn-next-exercise" onClick={advanceFlowAfterAnswer} className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow flex items-center justify-center gap-2 active:scale-95 transition">
                  Continuar Ejercicio <ArrowRight className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        )}

        {/* CASO 3: INTRO RONDA DE CORRECCIÓN */}
        {playerStep === "correction_intro" && (
          <div className="flex flex-col h-full justify-between gap-6 py-6 text-center">
            <div className="space-y-6 pt-8 flex-1 flex flex-col justify-center">
              <div className="w-20 h-20 rounded-3xl bg-amber-50 border border-amber-100 flex items-center justify-center text-amber-500 mx-auto shadow-md">
                <RotateCw className="w-10 h-10 stroke-[2] animate-spin" />
              </div>

              <div className="space-y-3 px-4">
                <h2 className="font-black text-slate-800 text-xl tracking-tight">Consolidación de Memoria</h2>
                <p className="text-slate-500 text-sm leading-relaxed">
                  Tienes {failedList.length} {failedList.length === 1 ? "pregunta con respuestas incorrectas o imprecisas" : "preguntas falladas"}. Vamos a
                  repasar cada una ahora mismo para fijar el conocimiento.
                </p>
                <p className="text-xs text-amber-600 font-semibold bg-amber-50 py-1.5 px-3 rounded-full inline-block border border-amber-100">
                  Acierto ahora = Recuperada • Segundo fallo = Registrada
                </p>
              </div>
            </div>

            <div className="pt-6 shrink-0">
              <button id="btn-start-corrections" onClick={() => setPlayerStep("corrections")} className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg flex items-center justify-center gap-2">
                Comenzar Correcciones <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* CASO 4: RESULTADOS */}
        {playerStep === "results" && (
          <div className="flex flex-col h-full justify-between gap-6 py-4 text-center">
            <div className="space-y-6 pt-5 flex-1 flex flex-col justify-center">
              <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-yellow-400 to-amber-500 flex items-center justify-center text-white mx-auto shadow-lg shadow-amber-400/20">
                <Trophy className="w-10 h-10 stroke-[1.8] animate-[bounce_2s_infinite]" />
              </div>

              <div className="space-y-2">
                <span className="text-[10px] bg-emerald-100 text-emerald-700 font-extrabold px-3.5 py-1 rounded-full uppercase tracking-wider">
                  {correctRate >= 70 ? "¡Entrenamiento Completado!" : "Sesión Finalizada"}
                </span>
                <h2 className="font-black text-slate-800 text-[22px] tracking-tight">Resultados de Sesión</h2>
                <p className="text-xs text-slate-400">Conceptos consolidados con éxito en la memoria a largo plazo.</p>
              </div>

              <div className="grid grid-cols-3 gap-2.5 py-2">
                <div className="bg-white border border-slate-100 rounded-2xl p-3 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">Aciertos</span>
                  <span className="text-lg font-black text-emerald-500 block mt-0.5">{totalCorrectToReport} / {totalExercises}</span>
                </div>
                <div className="bg-white border border-slate-100 rounded-2xl p-3 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">Precisión</span>
                  <span className="text-lg font-black text-slate-700 block mt-0.5">{correctRate}%</span>
                </div>
                <div className="bg-white border border-slate-100 rounded-2xl p-3 shadow-sm">
                  <span className="text-[9px] block text-slate-400 font-bold uppercase">Recompensa</span>
                  <span className="text-lg font-black text-amber-500 block mt-0.5 flex items-center justify-center gap-0.5">
                    +{xpGained}
                    <Zap className="w-4 h-4 fill-amber-300 stroke-amber-500 text-transparent shrink-0" />
                  </span>
                </div>
              </div>

              <div className="p-4 bg-slate-100/50 border border-slate-100 rounded-2xl text-[12px] text-slate-600 leading-relaxed max-w-[320px] mx-auto">
                {correctRate >= 100
                  ? "¡Desempeño Perfecto! Has respondido a todas las tarjetas de manera impecable a la primera. La curva de olvido se ha actualizado."
                  : correctRate >= 70
                    ? "Excelente avance. La ronda de corrección permitió subsanar los errores iniciales de forma correcta."
                    : "¡Es un buen esfuerzo! Repasa de nuevo las explicaciones teóricas en tus temas activos para afianzar conceptos."}
              </div>
            </div>

            <div className="pt-6 shrink-0">
              <button id="btn-finalize-lesson" onClick={() => onClose(true, buildSessionResult())} className="w-full py-4 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg shadow-blue-500/10 flex items-center justify-center gap-2 active:scale-95 transition-all">
                Volver al Menú Central
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
