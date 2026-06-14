import type { ReactNode } from "react";
import styles from "./MobileLayout.module.css";

interface MobileLayoutProps {
  header?: ReactNode;
  footer?: ReactNode;
  children: ReactNode;
}

/**
 * Contenedor mobile-first: ancho máximo legible, centrado, con zonas para
 * cabecera fija y pie (acciones). Pensado para una sola mano (RM-02).
 */
export function MobileLayout({ header, footer, children }: MobileLayoutProps) {
  return (
    <div className={styles.shell}>
      {header ? <header className={styles.header}>{header}</header> : null}
      <main className={styles.content}>{children}</main>
      {footer ? <footer className={styles.footer}>{footer}</footer> : null}
    </div>
  );
}
