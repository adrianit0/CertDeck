// =============================================================================
// CertDeck — Edge Function: certdeck-exam-grade
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Corrección AUTORITATIVA de un lote de respuestas de examen (v3 · RF-29/RSP-03)
// y registro del intento (Q-06: se persiste en `certdeck_user_question_attempts`
// PERO no altera `certdeck_user_spaced_repetition` — el examen no alimenta el
// repaso en el MVP). No confía en el cliente: vuelve a leer la pregunta y aplica
// la regla de CONJUNTO EXACTO (RN-11):
//   - única   (type_id 1): correcta = answer_1.
//   - múltiple (type_id 2): correctas = primeras `correct_answers_count`.
// El acierto exige seleccionar exactamente ese conjunto (ni de menos ni de más).
//
// Cuerpo (POST): { attempts: [{ question_id, selected_answers: string[] }] }
// Respuesta: { results: [{ questionId, correct }], correctCount, total }
//
// IMPORTANTE (Constitución §4): CORS propio. El agente NO la despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Row = Record<string, any>;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function clean(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "");
}

/** Conjunto exacto: misma cardinalidad y mismos elementos (RN-11). */
function isExactSetMatch(selected: string[], correct: string[]): boolean {
  const a = new Set(selected.map(clean));
  const b = new Set(correct.map(clean));
  if (a.size !== b.size) return false;
  for (const item of a) if (!b.has(item)) return false;
  return true;
}

/** Textos correctos de la fila: las primeras `correct_answers_count` answer_*. */
function correctTextsOf(row: Row): string[] {
  const raw = [row.answer_1, row.answer_2, row.answer_3, row.answer_4, row.answer_5, row.answer_6];
  const answers = raw.filter((a): a is string => typeof a === "string" && a.length > 0);
  const count = Math.max(1, Math.min(Number(row.correct_answers_count ?? 1), answers.length));
  return answers.slice(0, count);
}

interface AttemptIn {
  question_id?: string;
  selected_answers?: unknown;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  let payload: { attempts?: AttemptIn[] };
  try {
    payload = (await req.json()) as { attempts?: AttemptIn[] };
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const attempts = (payload.attempts ?? []).filter(
    (a): a is { question_id: string; selected_answers: string[] } =>
      typeof a?.question_id === "string" && Array.isArray(a.selected_answers),
  );
  if (attempts.length === 0) return json({ data: { results: [], correctCount: 0, total: 0 } });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  const ids = [...new Set(attempts.map((a) => a.question_id))];
  const { data: rows, error } = await supabase
    .from("certdeck_exam_questions")
    .select("id, type_id, lesson_id, answer_1, answer_2, answer_3, answer_4, answer_5, answer_6, correct_answers_count")
    .in("id", ids);
  if (error) return json({ error: "query_failed", detail: error.message }, 500);

  const byId = new Map<string, Row>();
  for (const r of rows ?? []) byId.set(r.id as string, r);

  const results: { questionId: string; correct: boolean }[] = [];
  const attemptRows: Row[] = [];

  for (const attempt of attempts) {
    const row = byId.get(attempt.question_id);
    if (!row) continue; // pregunta no visible/activa: se ignora
    const selected = attempt.selected_answers.filter((s): s is string => typeof s === "string");
    const correct = isExactSetMatch(selected, correctTextsOf(row));
    results.push({ questionId: attempt.question_id, correct });
    attemptRows.push({
      user_id: userId,
      question_id: attempt.question_id,
      question_source: "exam",
      lesson_id: row.lesson_id ?? null,
      exercise_type: row.type_id === 2 ? "exam_multiple" : "exam_single",
      was_correct: correct,
      selected_answer: selected.join(" | ").slice(0, 1000),
      attempt_number: 1,
    });
  }

  // Registro del intento (Q-06): NO toca certdeck_user_spaced_repetition.
  if (attemptRows.length > 0) {
    await supabase.from("certdeck_user_question_attempts").insert(attemptRows);
  }

  const correctCount = results.filter((r) => r.correct).length;
  return json({ data: { results, correctCount, total: results.length } });
});
