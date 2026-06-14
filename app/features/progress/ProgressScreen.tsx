"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Card, EmptyState, MobileLayout, ScreenHeader } from "@/components/ui";
import { getProgressMap, type LessonProgress } from "@/lib/progress/localProgress";

export function ProgressScreen() {
  const router = useRouter();
  const [entries, setEntries] = useState<Array<[string, LessonProgress]>>([]);

  useEffect(() => {
    setEntries(Object.entries(getProgressMap()));
  }, []);

  const completed = entries.filter(([, p]) => p.status === "completed");
  const avg =
    completed.length === 0
      ? 0
      : Math.round(
          completed.reduce((sum, [, p]) => sum + p.scorePercentage, 0) / completed.length,
        );

  return (
    <MobileLayout
      header={
        <ScreenHeader title="Tu progreso" subtitle="Resumen local" onBack={() => router.push("/")} />
      }
    >
      {completed.length === 0 ? (
        <EmptyState title="Todavía no has completado lecciones." />
      ) : (
        <>
          <Card icon="✅">
            <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>
              {completed.length} lección(es) completada(s)
            </h2>
            <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
              Puntuación media: {avg}%
            </p>
          </Card>
          <p style={{ fontSize: "var(--cd-text-sm)", color: "var(--cd-ink-600)" }}>
            Nota: progreso almacenado localmente. La sincronización con tu cuenta llegará con la
            Edge Function de progreso.
          </p>
        </>
      )}
    </MobileLayout>
  );
}
