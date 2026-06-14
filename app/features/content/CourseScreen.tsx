"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import {
  Card,
  EmptyState,
  ErrorState,
  LoadingState,
  MobileLayout,
  ScreenHeader,
} from "@/components/ui";
import { useAsync } from "@/hooks/useAsync";
import { getCourseBySlug, getStagesWithTopics } from "@/lib/queries/content";

export function CourseScreen() {
  const router = useRouter();
  const slug = useSearchParams().get("slug") ?? "";

  const { data, loading, error, reload } = useAsync(async () => {
    const course = await getCourseBySlug(slug);
    if (!course) return null;
    const stages = await getStagesWithTopics(course.id);
    return { course, stages };
  }, [slug]);

  return (
    <MobileLayout
      header={
        <ScreenHeader
          title={data?.course?.title ?? "Curso"}
          subtitle="Etapas y temas"
          onBack={() => router.push("/courses")}
        />
      }
    >
      {loading ? <LoadingState /> : null}
      {error ? <ErrorState message="No se pudo cargar el curso." onRetry={reload} /> : null}
      {data === null && !loading ? <EmptyState title="Curso no encontrado." /> : null}

      {data?.stages.map((stage) => (
        <div key={stage.id}>
          <h2 style={{ fontSize: "var(--cd-text-lg)" }}>{stage.title}</h2>
          {stage.topics.length === 0 ? (
            <p style={{ color: "var(--cd-ink-600)" }}>Próximamente.</p>
          ) : (
            stage.topics.map((topic) => (
              <Link
                key={topic.id}
                href={{ pathname: "/topic", query: { id: topic.id } }}
                style={{ textDecoration: "none", color: "inherit" }}
              >
                <Card icon="📑">
                  <h3 style={{ margin: 0, fontSize: "var(--cd-text-base)" }}>{topic.title}</h3>
                  {topic.description ? (
                    <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>
                      {topic.description}
                    </p>
                  ) : null}
                </Card>
              </Link>
            ))
          )}
        </div>
      ))}
    </MobileLayout>
  );
}
