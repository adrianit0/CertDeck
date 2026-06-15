// =============================================================================
// CertDeck — Edge Function: certdeck-spaced-review-update
// Runtime: Deno (Supabase Edge Functions). TypeScript.
//
// Persiste de forma AUTORITATIVA el estado de repetición espaciada (SM-2
// simplificado, RN-13…17 / Q-03) de las tarjetas revisadas en una sesión.
// Recibe un lote de { question_id, grade } (grade: fail|correct|easy), lee el
// estado actual de cada tarjeta en certdeck_user_spaced_repetition, aplica el
// algoritmo y hace upsert. Marca `is_problematic` a los 3 fallos (Q-02).
//
// La lógica del algoritmo es una RÉPLICA de app/lib/srs.ts (RT-03): mismos
// parámetros para que cliente y servidor coincidan. Esta función es la única
// que CALCULA SM-2; la composición de repasos (certdeck-playable-lesson) solo
// LEE `due_at`/`lapses`.
//
// IMPORTANTE (Constitución §4): CORS propio, autocontenida. El agente NO la
// despliega.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// --- Parámetros del algoritmo (Q-03, RN-16). Réplica de app/lib/srs.ts --------
const P = {
  initialEase: 2.5,
  minEase: 1.3,
  easePenalty: 0.2,
  easyEaseBonus: 0.15,
  correctSteps: [1, 3, 7],
  easySteps: [3, 7],
  easyIntervalBonus: 1.3,
  lapsesToProblematic: 3,
};

type Grade = "fail" | "correct" | "easy";

interface CardState {
  ease_factor: number;
  interval_days: number;
  repetitions: number;
  lapses: number;
  is_problematic: boolean;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

function addDaysISO(now: Date, days: number): string {
  const d = new Date(now.getTime());
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString();
}

function nextInterval(reps: number, prev: number, ease: number, steps: number[], bonus: number): number {
  if (reps <= steps.length) return steps[reps - 1] ?? 1;
  const base = prev > 0 ? prev : (steps[steps.length - 1] ?? 1);
  return Math.max(1, Math.round(base * ease * bonus));
}

/** Aplica el SM-2 simplificado a un estado y devuelve el nuevo. */
function applyGrade(state: CardState, grade: Grade): CardState {
  let { ease_factor, interval_days, repetitions, lapses, is_problematic } = state;

  if (grade === "fail") {
    lapses += 1;
    ease_factor = Math.max(P.minEase, round2(ease_factor - P.easePenalty));
    repetitions = 0;
    interval_days = 0;
    if (lapses >= P.lapsesToProblematic) is_problematic = true;
  } else if (grade === "correct") {
    repetitions += 1;
    interval_days = nextInterval(repetitions, interval_days, ease_factor, P.correctSteps, 1);
  } else {
    repetitions += 1;
    ease_factor = round2(ease_factor + P.easyEaseBonus);
    interval_days = nextInterval(repetitions, interval_days, ease_factor, P.easySteps, P.easyIntervalBonus);
  }

  return { ease_factor, interval_days, repetitions, lapses, is_problematic };
}

interface ReviewItem {
  question_id?: string;
  grade?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_authorization" }, 401);

  let payload: { reviews?: ReviewItem[] };
  try {
    payload = (await req.json()) as { reviews?: ReviewItem[] };
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  // Normaliza y valida el lote.
  const items = (payload.reviews ?? [])
    .filter((r): r is { question_id: string; grade: Grade } =>
      typeof r?.question_id === "string" &&
      (r.grade === "fail" || r.grade === "correct" || r.grade === "easy"))
    // Dedup por question_id (última evaluación gana).
    .reduce((acc, r) => acc.set(r.question_id, r.grade), new Map<string, Grade>());

  if (items.size === 0) return json({ data: { updated: 0 } });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const userId = userData.user.id;

  const questionIds = [...items.keys()];

  // Estado actual de las tarjetas afectadas (las que no existan parten de cero).
  const { data: existing, error: readError } = await supabase
    .from("certdeck_user_spaced_repetition")
    .select("question_id, ease_factor, interval_days, repetitions, lapses, is_problematic")
    .eq("user_id", userId)
    .in("question_id", questionIds);
  if (readError) return json({ error: "query_failed", detail: readError.message }, 500);

  const current = new Map<string, CardState>();
  for (const row of existing ?? []) {
    current.set(row.question_id, {
      ease_factor: Number(row.ease_factor),
      interval_days: row.interval_days,
      repetitions: row.repetitions,
      lapses: row.lapses,
      is_problematic: row.is_problematic,
    });
  }

  const now = new Date();
  const rows = questionIds.map((qid) => {
    const base = current.get(qid) ?? {
      ease_factor: P.initialEase,
      interval_days: 0,
      repetitions: 0,
      lapses: 0,
      is_problematic: false,
    };
    const next = applyGrade(base, items.get(qid)!);
    return {
      user_id: userId,
      question_id: qid,
      ease_factor: next.ease_factor,
      interval_days: next.interval_days,
      repetitions: next.repetitions,
      lapses: next.lapses,
      is_problematic: next.is_problematic,
      due_at: addDaysISO(now, next.interval_days),
      last_reviewed_at: now.toISOString(),
    };
  });

  const { error: upsertError } = await supabase
    .from("certdeck_user_spaced_repetition")
    .upsert(rows, { onConflict: "user_id,question_id" });
  if (upsertError) return json({ error: "persist_failed", detail: upsertError.message }, 500);

  return json({ data: { updated: rows.length } });
});
