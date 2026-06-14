import { Suspense } from "react";
import { LoadingState } from "@/components/ui";
import { CourseScreen } from "@/features/content/CourseScreen";

export default function CoursePage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <CourseScreen />
    </Suspense>
  );
}
