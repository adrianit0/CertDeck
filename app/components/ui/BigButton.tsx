import type { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";
import styles from "./BigButton.module.css";

type Variant = "primary" | "secondary" | "success" | "danger";

interface BigButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  fullWidth?: boolean;
  icon?: ReactNode;
}

/**
 * Botón grande con área táctil cómoda (RA-02). Base de la UI mobile-first.
 */
export function BigButton({
  variant = "primary",
  fullWidth = true,
  icon,
  children,
  className,
  type = "button",
  ...rest
}: BigButtonProps) {
  return (
    <button
      type={type}
      className={cn(
        styles.btn,
        styles[variant],
        fullWidth && styles.fullWidth,
        className,
      )}
      {...rest}
    >
      {icon ? <span className={styles.icon}>{icon}</span> : null}
      <span>{children}</span>
    </button>
  );
}
