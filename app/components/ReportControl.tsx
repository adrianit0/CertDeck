"use client";

import { useState } from "react";
import { Headset, X, Send, CheckCircle, AlertTriangle, Loader2 } from "lucide-react";
import { submitQuestionReport } from "@/lib/queries/reports";
import type { QuestionSource, ReportCategory } from "@/lib/types";

interface ReportControlProps {
  questionId: string;
  questionSource: QuestionSource;
  /** Instantánea del enunciado, para que el reporte sea legible al revisarlo. */
  questionText?: string | null;
  lessonId?: string | null;
  courseId?: string | null;
}

const CATEGORIES: { value: ReportCategory; label: string }[] = [
  { value: "bug", label: "Bug / Fallo técnico" },
  { value: "spelling", label: "Falta de ortografía" },
  { value: "wrong_answer", label: "Respuesta incorrecta" },
  { value: "confusing", label: "Pregunta confusa o ambigua" },
  { value: "other", label: "Otro" },
];

type Status = "idle" | "sending" | "success" | "error";

/**
 * Botón de ASISTENCIA TÉCNICA presente en cada tarjeta (ADR 0008 / RF-30).
 * Al pulsarlo abre un mini-popup con un combo de motivo y un campo de detalle;
 * el reporte se guarda (vía `certdeck-report-create`) para que el propietario
 * corrija el contenido más adelante.
 */
export default function ReportControl({
  questionId,
  questionSource,
  questionText,
  lessonId,
  courseId,
}: ReportControlProps) {
  const [open, setOpen] = useState(false);
  const [category, setCategory] = useState<ReportCategory>("bug");
  const [details, setDetails] = useState("");
  const [status, setStatus] = useState<Status>("idle");

  const reset = () => {
    setCategory("bug");
    setDetails("");
    setStatus("idle");
  };

  const close = () => {
    setOpen(false);
    // Limpia tras la animación de cierre.
    setTimeout(reset, 200);
  };

  const handleSubmit = async () => {
    if (status === "sending") return;
    setStatus("sending");
    try {
      await submitQuestionReport({
        questionId,
        questionSource,
        category,
        details: details.trim() || null,
        lessonId,
        courseId,
        questionText,
      });
      setStatus("success");
      setTimeout(close, 1400);
    } catch {
      setStatus("error");
    }
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Asistencia técnica: reportar un problema con esta tarjeta"
        title="Asistencia técnica"
        className="w-10 h-10 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-50/50 transition"
      >
        <Headset className="w-5 h-5 stroke-[2.2]" />
      </button>

      {open && (
        <div
          className="fixed inset-0 z-[60] flex items-end sm:items-center justify-center bg-slate-900/40 backdrop-blur-[2px] p-4"
          onClick={close}
        >
          <div
            className="w-full max-w-sm bg-white rounded-3xl shadow-2xl border border-slate-100 overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Cabecera */}
            <div className="flex items-center justify-between px-5 pt-5 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-brand-primary-light flex items-center justify-center text-brand-primary">
                  <Headset className="w-4 h-4" />
                </div>
                <h3 className="font-black text-slate-800 text-sm tracking-tight">Asistencia técnica</h3>
              </div>
              <button
                type="button"
                onClick={close}
                aria-label="Cerrar"
                className="w-8 h-8 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition"
              >
                <X className="w-4.5 h-4.5" />
              </button>
            </div>

            {status === "success" ? (
              <div className="px-5 pb-7 pt-2 flex flex-col items-center text-center gap-3">
                <div className="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500">
                  <CheckCircle className="w-7 h-7" />
                </div>
                <p className="text-sm font-bold text-slate-700">¡Gracias por tu reporte!</p>
                <p className="text-[12px] text-slate-500 leading-relaxed">
                  Lo revisaremos y corregiremos el contenido si hace falta.
                </p>
              </div>
            ) : (
              <div className="px-5 pb-5 space-y-4">
                <p className="text-[12px] text-slate-500 leading-relaxed">
                  Cuéntanos qué ha pasado con esta tarjeta. Tu reporte nos ayuda a corregir errores.
                </p>

                <div className="space-y-1.5">
                  <label htmlFor="report-category" className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                    Motivo
                  </label>
                  <select
                    id="report-category"
                    value={category}
                    onChange={(e) => setCategory(e.target.value as ReportCategory)}
                    className="w-full px-3.5 py-3 rounded-2xl border border-slate-200 bg-slate-50 text-sm font-semibold text-slate-700 focus:outline-none focus:border-brand-primary focus:bg-white transition"
                  >
                    {CATEGORIES.map((c) => (
                      <option key={c.value} value={c.value}>
                        {c.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label htmlFor="report-details" className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                    Detalle <span className="font-medium normal-case text-slate-400">(opcional)</span>
                  </label>
                  <textarea
                    id="report-details"
                    value={details}
                    onChange={(e) => setDetails(e.target.value.slice(0, 2000))}
                    rows={3}
                    placeholder="Describe el problema con tus palabras…"
                    className="w-full px-3.5 py-3 rounded-2xl border border-slate-200 bg-slate-50 text-sm text-slate-700 placeholder:text-slate-400 focus:outline-none focus:border-brand-primary focus:bg-white transition resize-none leading-relaxed"
                  />
                </div>

                {status === "error" && (
                  <div className="flex items-center gap-2 text-[12px] font-semibold text-rose-600 bg-rose-50 border border-rose-100 rounded-xl px-3 py-2">
                    <AlertTriangle className="w-4 h-4 shrink-0" />
                    No se pudo enviar. Revisa tu conexión e inténtalo de nuevo.
                  </div>
                )}

                <button
                  type="button"
                  onClick={handleSubmit}
                  disabled={status === "sending"}
                  className="w-full py-3.5 rounded-2xl bg-brand-primary text-white font-extrabold text-sm hover:bg-brand-primary-hover shadow-lg shadow-blue-500/10 flex items-center justify-center gap-2 active:scale-[0.99] transition-all disabled:opacity-60"
                >
                  {status === "sending" ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" /> Enviando…
                    </>
                  ) : (
                    <>
                      <Send className="w-4 h-4" /> Enviar reporte
                    </>
                  )}
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
