"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { ErrorState, LoadingState, MobileLayout, ScreenHeader } from "@/components/ui";
import { useAsync } from "@/hooks/useAsync";
import { getPlayableLesson } from "@/lib/queries/content";
import { completeLesson } from "@/lib/queries/progress";
import { LessonPlayer } from "./LessonPlayer";

export function LessonScreen() {
  const router = useRouter();
  const lessonId = useSearchParams().get("id") ?? "";

  const { data, loading, error, reload } = useAsync(() => getPlayableLesson(lessonId), [lessonId]);

  return (
    <MobileLayout
      header={
        <ScreenHeader
          title={data?.lesson.title ?? "Lección"}
          onBack={() => router.back()}
        />
      }
    >
      {loading ? <LoadingState /> : null}
      {error ? <ErrorState message="No se pudo cargar la lección." onRetry={reload} /> : null}
      {data ? (
        <LessonPlayer
          data={data}
          onFinish={async (result) => {
            await completeLesson(data.lesson.id, result);
            router.back();
          }}
        />
      ) : null}
    </MobileLayout>
  );
}
