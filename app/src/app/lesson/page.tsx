import { Suspense } from "react";
import { LoadingState } from "@/components/ui";
import { LessonScreen } from "@/features/lesson/LessonScreen";

export default function LessonPage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <LessonScreen />
    </Suspense>
  );
}
