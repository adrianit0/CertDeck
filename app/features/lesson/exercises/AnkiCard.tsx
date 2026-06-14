"use client";

import { useState } from "react";
import { BigButton } from "@/components/ui";
import type { FlashcardQuestion } from "@/lib/types";
import styles from "../lesson.module.css";

export type AnkiGrade = "incorrect" | "correct" | "easy";

interface AnkiCardProps {
  question: FlashcardQuestion;
  onGrade: (grade: AnkiGrade) => void;
}

/**
 * Tarjeta tipo ANKI (RF-13…RF-18): muestra el frontal, revela el reverso y
 * ofrece tres valoraciones. La gestión de reencolado/recuento la hace el
 * reproductor de la lección.
 */
export function AnkiCard({ question, onGrade }: AnkiCardProps) {
  const [revealed, setRevealed] = useState(false);

  return (
    <div>
      <div className={styles.card}>
        <p className={styles.cardLabel}>Pregunta</p>
        <p className={styles.cardText}>{question.question}</p>
        {revealed ? (
          <>
            <p className={styles.cardLabel}>Respuesta</p>
            <p className={styles.cardText}>{question.correct_answer}</p>
          </>
        ) : null}
      </div>

      {!revealed ? (
        <div style={{ marginTop: "var(--cd-space-4)" }}>
          <BigButton onClick={() => setRevealed(true)}>Mostrar respuesta</BigButton>
        </div>
      ) : (
        <div className={styles.ankiButtons}>
          <BigButton variant="danger" onClick={() => onGrade("incorrect")}>
            Incorrecto
          </BigButton>
          <BigButton variant="success" onClick={() => onGrade("correct")}>
            Correcto
          </BigButton>
          <BigButton variant="secondary" onClick={() => onGrade("easy")}>
            Muy fácil
          </BigButton>
        </div>
      )}
    </div>
  );
}
