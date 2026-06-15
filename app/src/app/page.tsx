import AppShell from "@/features/shell/AppShell";

/**
 * Punto de entrada de CertDeck: shell con barra de navegación inferior
 * (Cursos / Repasos / Progresos / Perfil) y reproductor de lección a pantalla
 * completa, fiel al mockup de diseño. Export estático (ADR 0003).
 */
export default function HomePage() {
  return <AppShell />;
}
