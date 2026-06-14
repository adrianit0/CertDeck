"use client";

import Link from "next/link";
import { Card, EmptyState, ErrorState, LoadingState, MobileLayout, ScreenHeader } from "@/components/ui";
import { useAsync } from "@/hooks/useAsync";
import { getCourses } from "@/lib/queries/content";

export function CatalogScreen() {
  const { data, loading, error, reload } = useAsync(getCourses, []);

  return (
    <MobileLayout header={<ScreenHeader title="Cursos" subtitle="Elige una certificación" />}>
      {loading ? <LoadingState /> : null}
      {error ? <ErrorState message="No se pudieron cargar los cursos." onRetry={reload} /> : null}
      {data && data.length === 0 ? (
        <EmptyState title="Aún no hay cursos disponibles." />
      ) : null}
      {data?.map((course) => (
        <Link
          key={course.id}
          href={{ pathname: "/course", query: { slug: course.slug } }}
          style={{ textDecoration: "none", color: "inherit" }}
        >
          <Card icon={course.icon ?? "📘"} accentColor={course.color ?? undefined}>
            <h2 style={{ margin: 0, fontSize: "var(--cd-text-lg)" }}>{course.title}</h2>
            {course.description ? (
              <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>{course.description}</p>
            ) : null}
            <p style={{ margin: "6px 0 0", fontSize: "var(--cd-text-sm)", color: "var(--cd-ink-600)" }}>
              Dificultad: {"★".repeat(course.difficulty)}
            </p>
          </Card>
        </Link>
      ))}
    </MobileLayout>
  );
}
