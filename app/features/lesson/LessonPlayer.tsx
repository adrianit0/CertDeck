"use client";

import { useState } from "react";
import { BigButton } from "@/components/ui";
import { AnkiCard, type AnkiGrade } from "./exercises/AnkiCard";
import { ChoiceQuestion } from "./exercises/ChoiceQuestion";
import type { FlashcardQuestion, PlayableLesson } from "@/lib/types";
import styles from "./lesson.module.css";

export interface LessonResult {
  correctCount: number;
  incorrectCount: number;
  scorePercentage: number;
}

interface LessonPlayerProps {
  data: PlayableLesson;
  onFinish: (result: LessonResult) => void;
}

type Phase = "content" | "exercises" | "result";

function initialPhase(data: PlayableLesson): Phase {
  if (data.screens.length > 0) return "content";
  if (data.questions.length > 0) return "exercises";
  return "result";
}

export function LessonPlayer({ data, onFinish }: LessonPlayerProps) {
  const { screens, questions } = data;

  const [phase, setPhase] = useState<Phase>(() => initialPhase(data));
  const [screenIndex, setScreenIndex] = useState(0);

  const [queue, setQueue] = useState<FlashcardQuestion[]>(questions);
  const [queueIndex, setQueueIndex] = useState(0);
  const [counted, setCounted] = useState<Set<string>>(new Set());
  const [correctCount, setCorrectCount] = useState(0);
  const [incorrectCount, setIncorrectCount] = useState(0);

  // --- Fase: pantallas de contenido ---
  if (phase === "content") {
    const screen = screens[screenIndex];
    if (!screen) return null;
    const isLast = screenIndex === screens.length - 1;
    const progress = ((screenIndex + 1) / screens.length) * 100;
    return (
      <div>
        <div className={styles.progressBar}>
          <div className={styles.progressFill} style={{ width: `${progress}%` }} />
        </div>
        {screen.title ? <h2>{screen.title}</h2> : null}
        <p className={styles.screenBody}>{screen.body}</p>
        <div style={{ marginTop: "var(--cd-space-6)" }}>
          <BigButton
            onClick={() => {
              if (isLast) {
                setPhase(questions.length > 0 ? "exercises" : "result");
              } else {
                setScreenIndex((i) => i + 1);
              }
            }}
          >
            {isLast ? (questions.length > 0 ? "Empezar ejercicios" : "Finalizar") : "Continuar"}
          </BigButton>
        </div>
      </div>
    );
  }

  // --- Fase: resultado ---
  if (phase === "result") {
    const total = correctCount + incorrectCount;
    const score = total === 0 ? 100 : Math.round((correctCount / total) * 100);
    return (
      <div style={{ textAlign: "center" }}>
        <p style={{ fontSize: "3rem", margin: 0 }}>{score >= 60 ? "🎉" : "💪"}</p>
        <h2>{score >= 60 ? "¡Lección completada!" : "¡Buen intento!"}</h2>
        <p style={{ fontSize: "var(--cd-text-2xl)", fontWeight: 700, color: "var(--cd-primary)" }}>
          {score}%
        </p>
        <p style={{ color: "var(--cd-ink-600)" }}>
          Aciertos: {correctCount} · Fallos: {incorrectCount}
        </p>
        <div style={{ marginTop: "var(--cd-space-6)" }}>
          <BigButton onClick={() => onFinish({ correctCount, incorrectCount, scorePercentage: score })}>
            Volver al tema
          </BigButton>
        </div>
      </div>
    );
  }

  // --- Fase: ejercicios ---
  const current = queue[queueIndex];
  if (!current) return null;

  const progress = (queueIndex / queue.length) * 100;

  function countOnce(question: FlashcardQuestion, correct: boolean) {
    if (counted.has(question.id)) return;
    setCounted((prev) => new Set(prev).add(question.id));
    if (correct) setCorrectCount((n) => n + 1);
    else setIncorrectCount((n) => n + 1);
  }

  function goNext(extraEnqueued: boolean) {
    const nextIndex = queueIndex + 1;
    // Si reencolamos, la cola crece y siempre hay siguiente.
    if (!extraEnqueued && nextIndex >= queue.length) {
      setPhase("result");
    } else {
      setQueueIndex(nextIndex);
    }
  }

  function handleAnki(grade: AnkiGrade) {
    const correct = grade !== "incorrect";
    countOnce(current!, correct);
    if (grade === "incorrect") {
      setQueue((q) => [...q, current!]); // reencolar al final (RF-15)
      goNext(true);
    } else {
      goNext(false);
    }
  }

  function handleChoice(correct: boolean) {
    countOnce(current!, correct);
    goNext(false);
  }

  return (
    <div>
      <div className={styles.progressBar}>
        <div className={styles.progressFill} style={{ width: `${progress}%` }} />
      </div>
      {current.exercise_type === "anki_card" ? (
        <AnkiCard key={`${current.id}-${queueIndex}`} question={current} onGrade={handleAnki} />
      ) : (
        <ChoiceQuestion
          key={`${current.id}-${queueIndex}`}
          question={current}
          onAnswered={handleChoice}
        />
      )}
    </div>
  );
}
