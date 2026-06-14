"use client";

import { useMemo, useState } from "react";
import { BigButton } from "@/components/ui";
import { getOptions, isCorrect } from "@/features/lesson/engine/options";
import { cn } from "@/lib/utils";
import type { FlashcardQuestion } from "@/lib/types";
import styles from "../lesson.module.css";

interface ChoiceQuestionProps {
  question: FlashcardQuestion;
  onAnswered: (correct: boolean) => void;
}

/**
 * Ejercicio de test (3 respuestas) y verdadero/falso (RF-19…RF-23).
 * Las opciones se barajan una vez y se muestra feedback + explicación.
 */
export function ChoiceQuestion({ question, onAnswered }: ChoiceQuestionProps) {
  const options = useMemo(() => getOptions(question), [question]);
  const [selected, setSelected] = useState<string | null>(null);

  const answered = selected !== null;
  const correct = answered && isCorrect(question, selected);

  return (
    <div>
      <p className={styles.prompt}>{question.question}</p>

      <div className={styles.options}>
        {options.map((option) => {
          const showCorrect = answered && option === question.correct_answer;
          const showWrong = answered && option === selected && !correct;
          return (
            <button
              key={option}
              type="button"
              className={cn(
                styles.option,
                showCorrect && styles.optionCorrect,
                showWrong && styles.optionWrong,
              )}
              disabled={answered}
              onClick={() => setSelected(option)}
            >
              {option}
            </button>
          );
        })}
      </div>

      {answered ? (
        <div className={styles.feedback}>
          <p className={correct ? styles.feedbackOk : styles.feedbackKo}>
            {correct ? "✅ ¡Correcto!" : "❌ Incorrecto"}
          </p>
          {!correct ? (
            <p style={{ margin: 0 }}>
              Respuesta correcta: <strong>{question.correct_answer}</strong>
            </p>
          ) : null}
          {question.explanation ? (
            <p className={styles.explanation}>{question.explanation}</p>
          ) : null}
          <div style={{ marginTop: "var(--cd-space-4)" }}>
            <BigButton onClick={() => onAnswered(correct)}>Continuar</BigButton>
          </div>
        </div>
      ) : null}
    </div>
  );
}
