"use client";

import { useMemo, useState } from "react";
import { BigButton } from "@/components/ui";
import { isTextAnswerCorrect, pickHintIndex } from "@/features/lesson/engine/textAnswer";
import type { FlashcardQuestion } from "@/lib/types";
import styles from "../lesson.module.css";

interface TextInputQuestionProps {
  question: FlashcardQuestion;
  onAnswered: (correct: boolean) => void;
}

type Outcome = null | "first" | "second";

/**
 * Ejercicio de respuesta escrita (`text_input`): el usuario escribe la
 * respuesta (pensado para 1 palabra o 1 número). Se muestra el número de
 * letras como huecos. Si falla a la primera, se revela UNA letra como pista
 * y puede reintentar una vez. La comparación es tolerante (mayúsculas,
 * espacios y tildes) — ver engine/textAnswer.
 */
export function TextInputQuestion({ question, onAnswered }: TextInputQuestionProps) {
  const answer = question.correct_answer;
  const chars = useMemo(() => [...answer], [answer]);

  const [value, setValue] = useState("");
  const [hintIndex, setHintIndex] = useState<number | null>(null);
  const [outcome, setOutcome] = useState<Outcome>(null);

  const finished = outcome !== null;
  const finalCorrect = finished && isTextAnswerCorrect(answer, value);

  function handleSubmit() {
    if (finished) return;
    const correct = isTextAnswerCorrect(answer, value);
    if (hintIndex === null) {
      // Primer intento.
      if (correct) setOutcome("first");
      else setHintIndex(pickHintIndex(chars));
    } else {
      // Segundo intento (ya con pista): se cierra sea cual sea el resultado.
      setOutcome("second");
    }
  }

  return (
    <div>
      <p className={styles.prompt}>{question.question}</p>

      <div className={styles.answerPattern} aria-hidden>
        {chars.map((char, i) => {
          if (/\s/.test(char)) return <span key={i} className={styles.slotSpace} />;
          const revealed = i === hintIndex || finished;
          return (
            <span key={i} className={styles.slot}>
              {revealed ? char : ""}
            </span>
          );
        })}
      </div>

      <input
        type="text"
        className={styles.textInput}
        value={value}
        autoComplete="off"
        autoCapitalize="none"
        spellCheck={false}
        disabled={finished}
        placeholder="Escribe tu respuesta"
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter") handleSubmit();
        }}
      />

      {!finished ? (
        <div style={{ marginTop: "var(--cd-space-4)" }}>
          {hintIndex !== null ? (
            <p className={styles.feedbackKo}>❌ Casi. Te dejo una pista en los huecos.</p>
          ) : null}
          <BigButton onClick={handleSubmit} disabled={value.trim().length === 0}>
            Comprobar
          </BigButton>
        </div>
      ) : (
        <div className={styles.feedback}>
          <p className={finalCorrect ? styles.feedbackOk : styles.feedbackKo}>
            {outcome === "first"
              ? "✅ ¡Correcto!"
              : finalCorrect
                ? "✅ ¡Esta vez sí!"
                : "❌ Incorrecto"}
          </p>
          {outcome !== "first" ? (
            <p style={{ margin: 0 }}>
              Respuesta correcta: <strong>{answer}</strong>
            </p>
          ) : null}
          {question.explanation ? (
            <p className={styles.explanation}>{question.explanation}</p>
          ) : null}
          <div style={{ marginTop: "var(--cd-space-4)" }}>
            <BigButton onClick={() => onAnswered(outcome === "first")}>Continuar</BigButton>
          </div>
        </div>
      )}
    </div>
  );
}
