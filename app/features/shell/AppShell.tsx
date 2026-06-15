"use client";

import { useState, useEffect, useMemo, useCallback } from "react";
import { Trophy, Zap, Loader2, AlertCircle } from "lucide-react";
import type {
  Course,
  Stage,
  Topic,
  Lesson,
  LessonWithStatus,
  FlashcardQuestion,
} from "@/lib/types";
import {
  getCourses,
  getStagesWithTopics,
  getLessonsByTopic,
  getQuestionsByLessons,
  getQuestionsByIds,
} from "@/lib/queries/content";
import { completeLesson } from "@/lib/queries/progress";
import { logout } from "@/lib/auth/login";
import {
  getProgressState,
  computeLessonStatus,
  computeUserStats,
  recordReviewSession,
  resetProgress,
  type ProgressState,
} from "@/lib/progress/localProgress";
import { shuffle } from "@/lib/shuffle";
import { useSession } from "@/hooks/useSession";
import Navigation from "./Navigation";
import CoursesTab from "./CoursesTab";
import RepasosTab from "./RepasosTab";
import ProgresosTab from "./ProgresosTab";
import PerfilTab from "./PerfilTab";
import LessonPlayer from "./LessonPlayer";

interface CourseData {
  stages: Stage[];
  topics: Topic[];
  lessons: Lesson[];
}

const REVIEW_LESSON_ID = "__review-session__";
const TOPIC_REVIEW_SIZE = 5;
const GENERAL_REVIEW_SIZE = 10;

/** Construye las lecciones con su estado de desbloqueo (lineal por tema). */
function buildLessonsWithStatus(
  lessons: Lesson[],
  topics: Topic[],
  lessonProgress: ProgressState["lessons"],
): LessonWithStatus[] {
  const result: LessonWithStatus[] = [];
  for (const topic of topics) {
    const topicLessons = lessons
      .filter((l) => l.topic_id === topic.id)
      .sort((a, b) => a.position - b.position);
    const ids = topicLessons.map((l) => l.id);
    topicLessons.forEach((lesson, index) => {
      result.push({ ...lesson, status: computeLessonStatus(index, ids, lessonProgress) });
    });
  }
  return result;
}

/**
 * Shell principal de la app: navegación por pestañas con barra inferior
 * (ADR 0004) y reproductor de lección a pantalla completa. El contenido se
 * obtiene de Supabase (`lib/queries`) y el progreso/métricas del progreso real
 * (capa optimista local + Edge Functions, ADR 0002).
 */
export default function AppShell() {
  const { session } = useSession();

  const [activeTab, setActiveTab] = useState("cursos");

  const [currentLessonId, setCurrentLessonId] = useState<string | null>(null);
  const [isReviewSession, setIsReviewSession] = useState(false);
  const [reviewType, setReviewType] = useState("");
  const [reviewQuestions, setReviewQuestions] = useState<FlashcardQuestion[]>([]);

  // Catálogo de cursos.
  const [courses, setCourses] = useState<Course[] | null>(null);
  const [coursesLoading, setCoursesLoading] = useState(true);
  const [coursesError, setCoursesError] = useState(false);

  // Contenido del curso activo (etapas + temas + lecciones).
  const [activeCourseId, setActiveCourseId] = useState<string | null>(null);
  const [activeStageId, setActiveStageId] = useState<string | null>(null);
  const [courseData, setCourseData] = useState<CourseData | null>(null);
  const [courseLoading, setCourseLoading] = useState(false);
  const [courseError, setCourseError] = useState(false);

  // Progreso real (localStorage optimista; se reconcilia con `certdeck_user_*`).
  const [progress, setProgress] = useState<ProgressState>(() => getProgressState());
  const refreshProgress = useCallback(() => setProgress(getProgressState()), []);

  // --- Carga del catálogo de cursos ---------------------------------------
  useEffect(() => {
    let active = true;
    setCoursesLoading(true);
    setCoursesError(false);
    getCourses()
      .then((cs) => {
        if (!active) return;
        setCourses(cs);
        setActiveCourseId((prev) => prev ?? cs[0]?.id ?? null);
        setCoursesLoading(false);
      })
      .catch(() => {
        if (!active) return;
        setCoursesError(true);
        setCoursesLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);

  // --- Carga del contenido del curso activo -------------------------------
  useEffect(() => {
    if (!activeCourseId) return;
    let active = true;
    setCourseLoading(true);
    setCourseError(false);
    (async () => {
      try {
        const stagesWithTopics = await getStagesWithTopics(activeCourseId);
        const stages: Stage[] = stagesWithTopics.map(({ topics: _topics, ...stage }) => stage);
        const topics: Topic[] = stagesWithTopics.flatMap((s) => s.topics);
        const lessonsByTopic = await Promise.all(topics.map((t) => getLessonsByTopic(t.id)));
        if (!active) return;
        setCourseData({ stages, topics, lessons: lessonsByTopic.flat() });
        setActiveStageId(stages[0]?.id ?? null);
        setCourseLoading(false);
      } catch {
        if (!active) return;
        setCourseError(true);
        setCourseLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, [activeCourseId]);

  // --- Derivados ----------------------------------------------------------
  const lessons = useMemo<LessonWithStatus[]>(() => {
    if (!courseData) return [];
    return buildLessonsWithStatus(courseData.lessons, courseData.topics, progress.lessons);
  }, [courseData, progress.lessons]);

  const stats = useMemo(() => computeUserStats(progress), [progress]);
  const pendingErrors = useMemo(() => Object.keys(progress.failedQuestions).length, [progress]);

  const activeCourse = courses?.find((c) => c.id === activeCourseId) ?? null;
  const stages = courseData?.stages ?? [];
  const topics = courseData?.topics ?? [];
  const activeStage =
    stages.find((s) => s.id === activeStageId) ?? stages[0] ?? null;

  const userEmail = session?.user?.email ?? null;
  const userName = userEmail ? (userEmail.split("@")[0] ?? "Estudiante") : "Invitado";

  // --- Acciones -----------------------------------------------------------
  const handleStartLesson = (lessonId: string) => {
    setReviewQuestions([]);
    setCurrentLessonId(lessonId);
    setIsReviewSession(false);
    setReviewType("");
  };

  const handleStartReview = async (type: string) => {
    if (!courseData || !activeStage) return;

    const stageLessonIds = new Set(
      lessons
        .filter((l) => topics.some((t) => t.id === l.topic_id && t.stage_id === activeStage.id))
        .map((l) => l.id),
    );

    let questions: FlashcardQuestion[] = [];
    try {
      if (type === "topic-errors" || type === "general-errors") {
        const failed = Object.entries(progress.failedQuestions)
          .filter(([, lessonId]) => type === "general-errors" || stageLessonIds.has(lessonId))
          .map(([id]) => id);
        questions = await getQuestionsByIds(failed);
      } else {
        const lessonIds =
          type === "topic-review"
            ? Array.from(stageLessonIds)
            : courseData.lessons.map((l) => l.id);
        const size = type === "topic-review" ? TOPIC_REVIEW_SIZE : GENERAL_REVIEW_SIZE;
        questions = shuffle(await getQuestionsByLessons(lessonIds)).slice(0, size);
      }
    } catch {
      questions = [];
    }

    setReviewQuestions(questions);
    setReviewType(type);
    setIsReviewSession(true);
    setCurrentLessonId(REVIEW_LESSON_ID);
  };

  const handleResetProgress = () => {
    resetProgress();
    refreshProgress();
    setActiveTab("cursos");
  };

  const handleClosePlayer = (
    completed: boolean,
    result: Parameters<typeof completeLesson>[1] | null,
  ) => {
    if (completed && result) {
      if (isReviewSession) {
        recordReviewSession(result);
      } else if (currentLessonId) {
        // Persiste local (inmediato) + Edge Function autoritativa (background).
        void completeLesson(currentLessonId, result);
      }
      refreshProgress();
    }

    setCurrentLessonId(null);
    setIsReviewSession(false);
    setReviewType("");
    setReviewQuestions([]);
  };

  // --- Render -------------------------------------------------------------
  const renderContent = () => {
    if (coursesLoading) {
      return <CenteredState kind="loading" message="Cargando cursos…" />;
    }
    if (coursesError) {
      return (
        <CenteredState
          kind="error"
          title="No se pudieron cargar los cursos"
          message="Revisa tu conexión o inicia sesión e inténtalo de nuevo."
        />
      );
    }
    if (!courses || courses.length === 0) {
      return (
        <CenteredState
          kind="empty"
          title="Aún no hay cursos disponibles"
          message="Cuando haya certificaciones publicadas aparecerán aquí."
        />
      );
    }
    if (courseLoading || !courseData || !activeCourse || !activeStage) {
      if (courseError) {
        return (
          <CenteredState
            kind="error"
            title="No se pudo cargar el curso"
            message="Inténtalo de nuevo en unos instantes."
          />
        );
      }
      return <CenteredState kind="loading" message="Cargando contenido…" />;
    }

    return (
      <>
        {activeTab === "cursos" && (
          <CoursesTab
            courses={courses}
            stages={stages}
            topics={topics}
            lessons={lessons}
            activeCourse={activeCourse}
            activeStage={activeStage}
            setActiveCourseId={setActiveCourseId}
            setActiveStageId={setActiveStageId}
            onStartLesson={handleStartLesson}
          />
        )}

        {activeTab === "repasos" && (
          <RepasosTab
            onStartReview={handleStartReview}
            pendingErrors={pendingErrors}
            completedLessons={stats.lessonsCompleted}
          />
        )}

        {activeTab === "progresos" && (
          <ProgresosTab stats={stats} lessons={lessons} topics={topics} activeStage={activeStage} />
        )}

        {activeTab === "perfil" && (
          <PerfilTab
            stats={stats}
            courses={courses}
            activeCourse={activeCourse}
            setActiveCourseId={setActiveCourseId}
            onResetProgress={handleResetProgress}
            onLogout={() => void logout()}
            userName={userName}
            userEmail={userEmail}
          />
        )}
      </>
    );
  };

  return (
    <div className="h-full sm:h-auto sm:min-h-screen w-full bg-slate-100 flex justify-center items-center py-0 sm:py-6 px-0 sm:px-4">
      <div className="w-full max-w-md h-full sm:h-auto sm:min-h-[850px] sm:max-h-[880px] bg-slate-50 relative flex flex-col rounded-none sm:rounded-[40px] shadow-none sm:shadow-2xl border border-transparent sm:border-slate-100 overflow-hidden">
        {/* Cabecera (oculta dentro de la lección) */}
        {currentLessonId === null && (
          <header className="px-5 pt-5 pb-1 flex justify-between items-center bg-white border-b border-slate-50 shrink-0">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-xl bg-brand-primary flex items-center justify-center text-white shadow-md shadow-blue-500/10">
                <Trophy className="w-4 h-4 text-amber-300 fill-amber-300 stroke-[1.5]" />
              </div>
              <div>
                <h1 className="font-black text-slate-800 text-[17px] tracking-tight">CertDeck</h1>
                <p className="text-[9px] text-slate-400 font-bold uppercase tracking-widest leading-none">Smart ANKI Engine</p>
              </div>
            </div>

            <div className="flex items-center gap-1.5 bg-amber-50 border border-amber-100 rounded-full px-3 py-1 text-xs">
              <Zap className="w-3.5 h-3.5 text-amber-500 fill-amber-500" />
              <span className="font-extrabold text-slate-700">{stats.streak}d Racha</span>
            </div>
          </header>
        )}

        {/* Contenido principal */}
        <div className="flex-1 overflow-y-auto no-scrollbar relative min-h-0 bg-slate-50/50">
          {currentLessonId !== null && activeCourse ? (
            <LessonPlayer
              lessonId={currentLessonId}
              isReviewSession={isReviewSession}
              reviewType={reviewType}
              reviewQuestions={reviewQuestions}
              activeCourseTitle={activeCourse.title}
              onClose={handleClosePlayer}
            />
          ) : (
            renderContent()
          )}
        </div>

        {/* Barra inferior (oculta dentro de la lección) */}
        {currentLessonId === null && <Navigation activeTab={activeTab} onTabChange={setActiveTab} />}
      </div>
    </div>
  );
}

/** Estado a pantalla completa para carga / error / vacío. */
function CenteredState({
  kind,
  title,
  message,
}: {
  kind: "loading" | "error" | "empty";
  title?: string;
  message: string;
}) {
  if (kind === "loading") {
    return (
      <div className="h-full flex flex-col items-center justify-center gap-4 p-8 text-center">
        <Loader2 className="w-9 h-9 text-brand-primary animate-spin" />
        <p className="text-sm font-bold text-slate-500">{message}</p>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col items-center justify-center gap-4 p-8 text-center">
      <div
        className={`w-16 h-16 rounded-3xl flex items-center justify-center border ${
          kind === "error"
            ? "bg-rose-50 border-rose-100 text-rose-500"
            : "bg-slate-100 border-slate-200 text-slate-400"
        }`}
      >
        <AlertCircle className="w-8 h-8" />
      </div>
      <div className="space-y-1">
        {title && <h2 className="font-black text-slate-800 text-lg tracking-tight">{title}</h2>}
        <p className="text-sm text-slate-500 leading-relaxed max-w-[280px]">{message}</p>
      </div>
    </div>
  );
}
