"use client";

import { useState, useEffect, useMemo, useCallback } from "react";
import { Trophy, Zap, Loader2, AlertCircle, WifiOff } from "lucide-react";
import type {
  Course,
  Stage,
  Topic,
  Lesson,
  LessonWithStatus,
  FlashcardQuestion,
  ExamQuestion,
  ExamAttempt,
  ExamFilters,
} from "@/lib/types";
import {
  getCourses,
  getStagesWithTopics,
  getLessonsByTopic,
  getQuestionsByLessons,
  getQuestionsByIds,
  getCourseContentVersion,
} from "@/lib/queries/content";
import {
  readCatalogCache,
  writeCatalogCache,
  type CourseCatalog,
} from "@/lib/cache/contentCache";
import { getExamQuestions, gradeExam } from "@/lib/queries/exam";
import {
  getProgress,
  completeLesson,
  recordReview,
  resetProgress,
  submitCardReviews,
  type ReviewType,
} from "@/lib/queries/progress";
import { logout } from "@/lib/auth/login";
import {
  emptyState,
  applyLessonCompleted,
  applyReviewSession,
  computeLessonStatus,
  computeUserStats,
  type ProgressState,
} from "@/lib/progress/progressState";
import { shuffle } from "@/lib/shuffle";
import { useSession } from "@/hooks/useSession";
import { useOnline } from "@/hooks/useOnline";
import Navigation from "./Navigation";
import CoursesTab from "./CoursesTab";
import RepasosTab from "./RepasosTab";
import ProgresosTab from "./ProgresosTab";
import PerfilTab from "./PerfilTab";
import LessonPlayer from "./LessonPlayer";
import ExamPracticeTab from "@/features/exam/ExamPracticeTab";
import ExamPlayer from "@/features/exam/ExamPlayer";

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
  const isOnline = useOnline();

  const [activeTab, setActiveTab] = useState("cursos");

  const [currentLessonId, setCurrentLessonId] = useState<string | null>(null);
  // Oferta de corrección de errores tras una lección floja (Q-01, score < 60%).
  const [offerCorrection, setOfferCorrection] = useState(false);
  const [isReviewSession, setIsReviewSession] = useState(false);
  const [reviewType, setReviewType] = useState("");
  const [reviewQuestions, setReviewQuestions] = useState<FlashcardQuestion[]>([]);

  // Práctica de examen (v3): simulacro a pantalla completa, independiente de las
  // lecciones/repasos (no toca el repaso espaciado; Q-06).
  const [examActive, setExamActive] = useState(false);
  const [examLoading, setExamLoading] = useState(false);
  const [examQuestions, setExamQuestions] = useState<ExamQuestion[]>([]);

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

  // Progreso real: estado OPTIMISTA en memoria (ADR 0006). La fuente de verdad
  // es la BD; se carga al montar/cambiar sesión y se reconcilia al reconectar.
  const [progress, setProgress] = useState<ProgressState>(emptyState);
  // `connectionLost` se activa cuando falla una ESCRITURA write-through; junto a
  // `!isOnline` determina el aviso superior y el bloqueo de iniciar lecciones.
  const [connectionLost, setConnectionLost] = useState(false);
  const offline = !isOnline || connectionLost;

  const loadProgress = useCallback(async () => {
    try {
      setProgress(await getProgress());
      setConnectionLost(false);
    } catch {
      setConnectionLost(true);
    }
  }, []);

  const userId = session?.user?.id ?? null;

  // Carga/reconciliación del progreso desde la BD: al iniciar sesión y cada vez
  // que se recupera la conexión (reconcilia el optimismo con la verdad real).
  useEffect(() => {
    if (!userId || !isOnline) return;
    void loadProgress();
  }, [userId, isOnline, loadProgress]);

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

  // --- Carga del contenido del curso activo (con caché local, ADR 0009) ----
  // El catálogo (etapas+temas+lecciones) apenas cambia y es voluminoso, así que
  // se cachea en `localStorage`. En cada arranque solo se pide un TOKEN de
  // versión ligero (`certdeck-content-version`); si coincide con el cacheado se
  // usa la caché y se evita la descarga pesada (etapas/temas + N de lecciones).
  useEffect(() => {
    if (!activeCourseId) return;
    const courseId = activeCourseId;
    let active = true;
    setCourseLoading(true);
    setCourseError(false);

    const apply = (catalog: CourseCatalog) => {
      if (!active) return;
      setCourseData(catalog);
      setActiveStageId(catalog.stages[0]?.id ?? null);
      setCourseLoading(false);
    };

    const fetchCatalog = async (): Promise<CourseCatalog> => {
      const stagesWithTopics = await getStagesWithTopics(courseId);
      const stages: Stage[] = stagesWithTopics.map(({ topics: _topics, ...stage }) => stage);
      const topics: Topic[] = stagesWithTopics.flatMap((s) => s.topics);
      const lessonsByTopic = await Promise.all(topics.map((t) => getLessonsByTopic(t.id)));
      return { stages, topics, lessons: lessonsByTopic.flat() };
    };

    (async () => {
      const cached = readCatalogCache(courseId);

      // 1) Token de versión (ligero). Si falla (offline) caemos a la caché.
      let version: string | null = null;
      try {
        version = await getCourseContentVersion(courseId);
      } catch {
        if (cached) return apply(cached.catalog);
      }

      // 2) Caché vigente → sin descarga pesada.
      if (version && cached && cached.version === version) {
        return apply(cached.catalog);
      }

      // 3) Cache miss (o cambió la versión) → descarga y se guarda.
      try {
        const catalog = await fetchCatalog();
        if (!active) return;
        apply(catalog);
        if (version) writeCatalogCache(courseId, version, catalog);
      } catch {
        if (!active) return;
        if (cached) return apply(cached.catalog); // último recurso: caché previa
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
    if (offline) return; // Sin conexión no se inician nuevas lecciones (ADR 0006).
    setReviewQuestions([]);
    setCurrentLessonId(lessonId);
    setIsReviewSession(false);
    setReviewType("");
  };

  const handleStartReview = async (type: string) => {
    if (offline) return; // Sin conexión no se inician nuevos repasos (ADR 0006).
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

  // --- Práctica de examen (v3) --------------------------------------------
  const handleStartExam = async (filters: ExamFilters) => {
    if (offline || examLoading) return;
    setExamLoading(true);
    try {
      const questions = await getExamQuestions(filters);
      setExamQuestions(questions);
      setExamActive(true);
    } catch {
      setExamQuestions([]);
      setExamActive(true); // el player muestra el estado "sin preguntas"
    } finally {
      setExamLoading(false);
    }
  };

  const handleCloseExam = (completed: boolean, attempts: ExamAttempt[]) => {
    if (completed && attempts.length > 0) {
      // Corrección autoritativa + registro del intento; luego refresca el
      // histórico de examen leyendo el progreso real (no es optimista).
      void gradeExam(attempts)
        .then(() => loadProgress())
        .catch(() => setConnectionLost(true));
    }
    setExamActive(false);
    setExamQuestions([]);
  };

  const handleResetProgress = () => {
    setProgress(emptyState()); // Optimista: vacía la UI de inmediato.
    setActiveTab("cursos");
    void resetProgress().catch(() => setConnectionLost(true));
  };

  const handleClosePlayer = (
    completed: boolean,
    result: Parameters<typeof completeLesson>[1] | null,
  ) => {
    if (completed && result) {
      if (isReviewSession) {
        // Optimista en memoria + write-through autoritativo a la BD (ADR 0006).
        setProgress((prev) => applyReviewSession(prev, result));
        const type = (reviewType || "general-review") as ReviewType;
        void recordReview(type, result).catch(() => setConnectionLost(true));
      } else if (currentLessonId) {
        const lessonId = currentLessonId;
        setProgress((prev) => applyLessonCompleted(prev, lessonId, result));
        void completeLesson(lessonId, result).catch(() => setConnectionLost(true));
        // Q-01 (RN-07): si el rendimiento es bajo, ofrecer corregir errores.
        setOfferCorrection(result.scorePercentage < 60);
      }
      // Actualiza la repetición espaciada (SM-2) de las tarjetas revisadas, en
      // lecciones y repasos por igual (v2.2).
      void submitCardReviews(result.cardReviews).catch(() => setConnectionLost(true));
    }

    setCurrentLessonId(null);
    setIsReviewSession(false);
    setReviewType("");
    setReviewQuestions([]);
  };

  // --- Botón "atrás" de hardware (Android/iOS) -----------------------------
  // Por defecto Capacitor cierra la app al pulsar atrás. Si hay una sesión a
  // pantalla completa (lección/repaso o examen) en curso, interceptamos y
  // pedimos confirmación igual que la "X" superior; fuera de una sesión se
  // mantiene el comportamiento por defecto (salir de la app).
  const inLesson = currentLessonId !== null;
  useEffect(() => {
    let remove: (() => void) | undefined;
    void (async () => {
      try {
        const { App } = await import("@capacitor/app");
        const handle = await App.addListener("backButton", () => {
          if (inLesson) {
            if (
              window.confirm(
                "¿Seguro que quieres salir de la lección? Perderás el progreso de esta tanda.",
              )
            ) {
              handleClosePlayer(false, null);
            }
          } else if (examActive) {
            if (
              window.confirm(
                "¿Salir de la práctica de examen? Perderás el progreso de esta tanda.",
              )
            ) {
              handleCloseExam(false, []);
            }
          } else {
            void App.exitApp();
          }
        });
        remove = () => void handle.remove();
      } catch {
        // En web (sin Capacitor nativo) no hay botón atrás de hardware: se ignora.
      }
    })();
    return () => remove?.();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inLesson, examActive]);

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
            offerCorrection={offerCorrection}
            onStartCorrection={() => {
              setOfferCorrection(false);
              void handleStartReview("topic-errors");
            }}
            onDismissCorrection={() => setOfferCorrection(false)}
          />
        )}

        {activeTab === "repasos" && (
          <RepasosTab
            onStartReview={handleStartReview}
            pendingErrors={pendingErrors}
            completedLessons={stats.lessonsCompleted}
          />
        )}

        {activeTab === "examen" && (
          <ExamPracticeTab
            activeCourse={activeCourse}
            topics={topics}
            onStartExam={handleStartExam}
            examLoading={examLoading}
            offline={offline}
            examAttempts={progress.exam.attempts}
            examAccuracy={
              progress.exam.attempts > 0
                ? Math.round((progress.exam.correct / progress.exam.attempts) * 100)
                : 0
            }
          />
        )}

        {activeTab === "progresos" && (
          <ProgresosTab
            stats={stats}
            lessons={lessons}
            topics={topics}
            activeStage={activeStage}
            srs={progress.srs}
            exam={progress.exam}
          />
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
        {/* Aviso de pérdida de conexión (ADR 0006): el progreso no se guarda y
            no se pueden iniciar nuevas lecciones hasta recuperar la red. */}
        {offline && (
          <div className="shrink-0 flex items-center justify-center gap-2 bg-rose-500 text-white text-[11px] font-bold px-4 py-2 text-center leading-tight">
            <WifiOff className="w-3.5 h-3.5 shrink-0" />
            Sin conexión: tu progreso no se guardará y no puedes empezar lecciones nuevas.
          </div>
        )}

        {/* Cabecera (oculta dentro de la lección o el examen) */}
        {currentLessonId === null && !examActive && (
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
              isRepeat={!isReviewSession && progress.lessons[currentLessonId]?.status === "completed"}
              activeCourseTitle={activeCourse.title}
              activeCourseId={activeCourse.id}
              onClose={handleClosePlayer}
            />
          ) : examActive && activeCourse ? (
            <ExamPlayer
              questions={examQuestions}
              courseTitle={activeCourse.title}
              onClose={handleCloseExam}
            />
          ) : (
            renderContent()
          )}
        </div>

        {/* Barra inferior (oculta dentro de la lección o el examen) */}
        {currentLessonId === null && !examActive && (
          <Navigation activeTab={activeTab} onTabChange={setActiveTab} />
        )}
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
