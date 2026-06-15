import AuthGate from "@/features/auth/AuthGate";

/**
 * Punto de entrada de CertDeck: puerta de autenticación (login vía Edge
 * Function `auth-login`) que, con sesión válida, muestra el shell con barra de
 * navegación inferior y reproductor de lección. Export estático (ADR 0003).
 */
export default function HomePage() {
  return <AuthGate />;
}
