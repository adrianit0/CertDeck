import type { HTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";
import styles from "./Card.module.css";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  /** Si se pasa, la tarjeta es interactiva (rol button) con foco/teclado. */
  onActivate?: () => void;
  accentColor?: string;
  icon?: ReactNode;
}

/**
 * Superficie reutilizable. Si recibe `onActivate` se comporta como elemento
 * interactivo accesible (teclado + foco), no solo clic de ratón (RA-06).
 */
export function Card({
  onActivate,
  accentColor,
  icon,
  children,
  className,
  style,
  ...rest
}: CardProps) {
  const interactive = typeof onActivate === "function";
  return (
    <div
      className={cn(styles.card, interactive && styles.interactive, className)}
      style={{ ...style, ...(accentColor ? { borderLeftColor: accentColor } : {}) }}
      role={interactive ? "button" : undefined}
      tabIndex={interactive ? 0 : undefined}
      onClick={interactive ? onActivate : undefined}
      onKeyDown={
        interactive
          ? (e) => {
              if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                onActivate?.();
              }
            }
          : undefined
      }
      {...rest}
    >
      {icon ? <span className={styles.icon}>{icon}</span> : null}
      <div className={styles.body}>{children}</div>
    </div>
  );
}
