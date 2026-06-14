import { Suspense } from "react";
import { LoadingState } from "@/components/ui";
import { TopicScreen } from "@/features/content/TopicScreen";

export default function TopicPage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <TopicScreen />
    </Suspense>
  );
}
