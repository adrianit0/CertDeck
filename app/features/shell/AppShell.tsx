"use client";

import { useState, useEffect } from "react";
import { Trophy, Zap } from "lucide-react";
import type { Course, Stage, Topic, LessonWithStatus, LessonStatus, UserStats } from "@/lib/types";
import { MOCK_COURSES, MOCK_STAGES, MOCK_TOPICS, MOCK_LESSONS } from "./mockData";
import Navigation from "./Navigation";
import CoursesTab from "./CoursesTab";
import RepasosTab from "./RepasosTab";
import ProgresosTab from "./ProgresosTab";
import PerfilTab from "./PerfilTab";
import LessonPlayer from "./LessonPlayer";

/**
 * Shell principal de la app (prototipo de UI fiel al mockup de Google AI Studio).
 * Navegación por pestañas con barra inferior (ADR 0004) y reproductor de lección
 * a pantalla completa (modo concentración). Los datos son mock; la lógica real se
 * conectará a medida que avance el roadmap.
 */
export default function AppShell() {
  const [activeTab, setActiveTab] = useState("cursos");

  const [currentLessonId, setCurrentLessonId] = useState<string | null>(null);
  const [isReviewSession, setIsReviewSession] = useState(false);
  const [reviewType, setReviewType] = useState("");

  const [courses] = useState<Course[]>(MOCK_COURSES);
  const [stages] = useState<Stage[]>(MOCK_STAGES);
  const [topics] = useState<Topic[]>(MOCK_TOPICS);
  const [lessons, setLessons] = useState<LessonWithStatus[]>(MOCK_LESSONS);

  const [activeCourseId, setActiveCourseId] = useState("aws-saa-c03");
  const [activeStageId, setActiveStageId] = useState("aws-stage-1");

  const [stats, setStats] = useState<UserStats>({
    xp: 2450,
    streak: 5,
    lessonsCompleted: 1,
    totalAnswers: 15,
    correctAnswers: 12,
    ankiCardsStudied: 32,
  });

  const [incorrectTracker, setIncorrectTracker] = useState(3);

  // Alinea la etapa por defecto al cambiar de curso activo.
  useEffect(() => {
    const courseStages = stages.filter((s) => s.course_id === activeCourseId).sort((a, b) => a.position - b.position);
    const first = courseStages[0];
    if (first) setActiveStageId(first.id);
  }, [activeCourseId, stages]);

  const activeCourse: Course = courses.find((c) => c.id === activeCourseId) ?? (courses[0] as Course);
  const activeStage: Stage = stages.find((s) => s.id === activeStageId) ?? (stages[0] as Stage);

  const handleStartLesson = (lessonId: string) => {
    setCurrentLessonId(lessonId);
    setIsReviewSession(false);
    setReviewType("");
  };

  const handleStartReview = (type: string) => {
    setCurrentLessonId("lesson-any-review-session");
    setIsReviewSession(true);
    setReviewType(type);
  };

  const handleResetProgress = () => {
    setLessons(
      MOCK_LESSONS.map((l) => {
        if (l.id === "lesson-s3-1") return { ...l, status: "completed" as LessonStatus };
        if (l.id === "lesson-s3-2" || l.id === "lesson-sec-1" || l.id === "lesson-k8s-1")
          return { ...l, status: "available" as LessonStatus };
        return { ...l, status: "locked" as LessonStatus };
      }),
    );
    setStats({ xp: 250, streak: 5, lessonsCompleted: 1, totalAnswers: 10, correctAnswers: 8, ankiCardsStudied: 12 });
    setIncorrectTracker(2);
    setActiveTab("cursos");
  };

  const handleClosePlayer = (completed: boolean, correctCount: number, xpGained: number) => {
    if (completed && currentLessonId) {
      setStats((prev) => ({
        ...prev,
        xp: prev.xp + xpGained,
        lessonsCompleted: isReviewSession ? prev.lessonsCompleted : prev.lessonsCompleted + 1,
        totalAnswers: prev.totalAnswers + (isReviewSession ? 8 : 4),
        correctAnswers: prev.correctAnswers + correctCount,
        ankiCardsStudied: prev.ankiCardsStudied + (isReviewSession ? 3 : 1),
      }));

      if (isReviewSession && (reviewType === "topic-errors" || reviewType === "general-errors")) {
        setIncorrectTracker((prev) => Math.max(prev - 2, 0));
      } else if (!isReviewSession) {
        const failed = 4 - correctCount;
        if (failed > 0) setIncorrectTracker((prev) => prev + failed);

        // Desbloqueo lineal sencillo dentro del mismo tema (demo del prototipo).
        setLessons((prev) => {
          const current = prev.find((l) => l.id === currentLessonId);
          if (!current) return prev;
          const updated = prev.map((l) => (l.id === currentLessonId ? { ...l, status: "completed" as LessonStatus } : l));
          const sameTopic = updated.filter((l) => l.topic_id === current.topic_id).sort((a, b) => a.position - b.position);
          const next = sameTopic.find((l) => l.position > current.position && l.status === "locked");
          if (next) return updated.map((l) => (l.id === next.id ? { ...l, status: "available" as LessonStatus } : l));
          return updated;
        });
      }
    }

    setCurrentLessonId(null);
    setIsReviewSession(false);
    setReviewType("");
  };

  return (
    <div className="min-h-screen w-full bg-slate-100 flex justify-center items-center py-0 sm:py-6 px-0 sm:px-4">
      <div className="w-full max-w-md min-h-screen sm:min-h-[850px] sm:max-h-[880px] bg-slate-50 relative flex flex-col rounded-none sm:rounded-[40px] shadow-none sm:shadow-2xl border border-transparent sm:border-slate-100 overflow-hidden">
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
          {currentLessonId !== null ? (
            <LessonPlayer
              lessonId={currentLessonId}
              isReviewSession={isReviewSession}
              reviewType={reviewType}
              activeCourseTitle={activeCourse.title}
              onClose={handleClosePlayer}
            />
          ) : (
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

              {activeTab === "repasos" && <RepasosTab onStartReview={handleStartReview} incorrectCount={incorrectTracker} />}

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
                />
              )}
            </>
          )}
        </div>

        {/* Barra inferior (oculta dentro de la lección) */}
        {currentLessonId === null && <Navigation activeTab={activeTab} onTabChange={setActiveTab} />}
      </div>
    </div>
  );
}
