import { BigButton, Card, MobileLayout, ScreenHeader } from "@/components/ui";

/**
 * Pantalla de Inicio (v0 — esqueleto).
 *
 * En v1 enlazará con el catálogo de cursos y el progreso del usuario.
 * Es un Server Component estático sin acceso a datos (ADR 0003): la lógica
 * de sesión/datos se añadirá en componentes cliente en iteraciones siguientes.
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
      footer={<BigButton variant="primary">Empezar a estudiar</BigButton>}
    >
      <Card icon="📚" accentColor="var(--cd-blue-500)">
        <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Catálogo de cursos</h2>
        <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
          Próximamente: elige una certificación y empieza.
        </p>
      </Card>

      <Card icon="🧠" accentColor="var(--cd-celeste-300)">
        <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Repaso inteligente</h2>
        <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
          Tarjetas y preguntas que vuelven justo cuando toca recordarlas.
        </p>
      </Card>

      <Card icon="📈" accentColor="var(--cd-success)">
        <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>Tu progreso</h2>
        <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
          Sigue tu avance lección a lección.
        </p>
      </Card>
    </MobileLayout>
  );
}
