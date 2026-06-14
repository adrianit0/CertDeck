import { errorResponse, handlePreflight, jsonResponse, readBody } from "../_shared/http.ts";
import { getAnonClient } from "../_shared/supabase.ts";

Deno.serve(async (request) => {
  const early = handlePreflight(request);
  if (early) {
    return early;
  }

  try {
    const body = await readBody(request);
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";

    if (!email || !password) {
      return jsonResponse({ error: "Email and password are required." }, 400);
    }

    const supabase = getAnonClient();
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return jsonResponse({ error: error.message }, 401);
    }

    return jsonResponse(data);
  } catch (error) {
    return errorResponse(error);
  }
});
