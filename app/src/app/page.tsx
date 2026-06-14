import Link from "next/link";
import { BigButton, Card, MobileLayout, ScreenHeader } from "@/components/ui";

/**
 * Pantalla de Inicio. Enlaza con el catálogo de cursos y el progreso.
 * Server Component estático (ADR 0003); los datos se cargan en las pantallas
 * cliente correspondientes.
 */
export default function HomePage() {
  return (
    <MobileLayout
      header={
        <ScreenHeader
          title="CertDeck"
          subtitle="Aprende certificaciones con repaso espaciado"
        />
      }
      footer={
        <Link href="/courses" style={{ textDecoration: "none" }}>
          <BigButton variant="primary">Empezar a estudiar</BigButton>
        </Link>
      }
    >
      <Link href="/courses" style={{ textDecoration: "none", color: "inherit" }}>
        <Card icon="📚" accentColor="var(--cd-blue-500)">
          <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Catálogo de cursos</h2>
          <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
            Elige una certificación y empieza.
          </p>
        </Card>
      </Link>

      <Card icon="🧠" accentColor="var(--cd-celeste-300)">
        <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Repaso inteligente</h2>
        <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
          Tarjetas y preguntas que vuelven justo cuando toca recordarlas.
        </p>
      </Card>

      <Link href="/progress" style={{ textDecoration: "none", color: "inherit" }}>
        <Card icon="📈" accentColor="var(--cd-success)">
          <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Tu progreso</h2>
          <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
            Sigue tu avance lección a lección.
          </p>
        </Card>
      </Link>
    </MobileLayout>
  );
}
