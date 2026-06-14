import type { ReactNode } from "react";
import { BigButton } from "./BigButton";
import styles from "./States.module.css";

/** Estado de carga (RNF-02: estados de carga siempre visibles). */
export function LoadingState({ label = "Cargando…" }: { label?: string }) {
  return (
    <div className={styles.wrap} role="status" aria-live="polite">
      <div className={styles.spinner} aria-hidden="true" />
      <p className={styles.text}>{label}</p>
    </div>
  );
}

/** Estado de error con reintento opcional. */
export function ErrorState({
  message = "Algo ha ido mal.",
  onRetry,
}: {
  message?: string;
  onRetry?: () => void;
}) {
  return (
    <div className={styles.wrap} role="alert">
      <p className={styles.errorIcon} aria-hidden="true">
        ⚠️
      </p>
      <p className={styles.text}>{message}</p>
      {onRetry ? (
        <BigButton variant="secondary" fullWidth={false} onClick={onRetry}>
          Reintentar
        </BigButton>
      ) : null}
    </div>
  );
}

/** Estado vacío (sin resultados). */
export function EmptyState({ title, children }: { title: string; children?: ReactNode }) {
  return (
    <div className={styles.wrap}>
      <p className={styles.text}>{title}</p>
      {children}
    </div>
  );
}
