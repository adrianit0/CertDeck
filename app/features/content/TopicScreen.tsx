"use client";

import { useEffect, useState } from "react";
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
import { getLessonsByTopic, getTopic } from "@/lib/queries/content";
import { computeLessonStatus, getProgressMap } from "@/lib/progress/localProgress";
import type { LessonType } from "@/lib/types";

const LESSON_TYPE_ICON: Record<LessonType, string> = {
  normal: "📗",
  review: "🔁",
  error_correction: "🩹",
  expansion: "➕",
  final: "🏁",
};

const STATUS_LABEL = {
  locked: "🔒 Bloqueada",
  available: "▶️ Disponible",
  in_progress: "… En progreso",
  completed: "✅ Completada",
} as const;

export function TopicScreen() {
  const router = useRouter();
  const topicId = useSearchParams().get("id") ?? "";

  const { data, loading, error, reload } = useAsync(async () => {
    const topic = await getTopic(topicId);
    if (!topic) return null;
    const lessons = await getLessonsByTopic(topicId);
    return { topic, lessons };
  }, [topicId]);

  // Progreso optimista (cliente). Se lee tras montar para evitar desajustes.
  const [progress, setProgress] = useState(() => ({}) as ReturnType<typeof getProgressMap>);
  useEffect(() => {
    setProgress(getProgressMap());
  }, [data]);

  const lessonIds = data?.lessons.map((l) => l.id) ?? [];

  return (
    <MobileLayout
      header={
        <ScreenHeader
          title={data?.topic?.title ?? "Tema"}
          subtitle="Resumen y lecciones"
          onBack={() => router.back()}
        />
      }
    >
      {loading ? <LoadingState /> : null}
      {error ? <ErrorState message="No se pudo cargar el tema." onRetry={reload} /> : null}
      {data === null && !loading ? <EmptyState title="Tema no encontrado." /> : null}

      {data?.topic.summary ? (
        <Card icon="🧭">
          <h3 style={{ margin: 0, fontSize: "var(--cd-text-base)" }}>Resumen del tema</h3>
          <p style={{ margin: "4px 0 0", color: "var(--cd-ink-600)" }}>{data.topic.summary}</p>
        </Card>
      ) : null}

      {data?.lessons.map((lesson, index) => {
        const status = computeLessonStatus(index, lessonIds, progress);
        const locked = status === "locked";
        const onActivate = locked
          ? undefined
          : () => router.push(`/lesson?id=${encodeURIComponent(lesson.id)}`);
        return (
          <Card
            key={lesson.id}
            icon={LESSON_TYPE_ICON[lesson.lesson_type]}
            onActivate={onActivate}
            style={locked ? { opacity: 0.6 } : undefined}
          >
            <h3 style={{ margin: 0, fontSize: "var(--cd-text-base)" }}>{lesson.title}</h3>
            <p style={{ margin: "4px 0 0", fontSize: "var(--cd-text-sm)", color: "var(--cd-ink-600)" }}>
              {STATUS_LABEL[status]}
            </p>
          </Card>
        );
      })}
    </MobileLayout>
  );
}
