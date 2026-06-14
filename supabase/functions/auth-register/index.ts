import { errorResponse, handlePreflight, jsonResponse, readBody } from "../_shared/http.ts";
import { getAdminClient, getAnonClient } from "../_shared/supabase.ts";

type AdminClient = ReturnType<typeof getAdminClient>;

function normalizeProfileValue(value: unknown) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

async function assignDefaultUserRole(admin: AdminClient, userId: string) {
  const { data: role, error: roleError } = await admin
    .from("rol")
    .select("id")
    .eq("name", "Usuario")
    .single();

  if (roleError) {
    return roleError;
  }

  const { error } = await admin
    .from("profile_rol")
    .upsert({
      rol_id: role.id,
      user_id: userId,
      date_start: new Date().toISOString().slice(0, 10),
      date_end: null,
    });

  return error;
}

Deno.serve(async (request) => {
  const early = handlePreflight(request);
  if (early) {
    return early;
  }

  try {
    const body = await readBody(request);
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";
    const name = normalizeProfileValue(body.name);
    const username = normalizeProfileValue(body.username);

    if (!email || !password || !name || !username) {
      return jsonResponse({ error: "Email, password, name and username are required." }, 400);
    }

    const auth = getAnonClient();
    const admin = getAdminClient();
    const { data, error } = await auth.auth.signUp({
      email,
      password,
      options: {
        data: {
          name,
          username,
        },
      },
    });

    if (error) {
      return jsonResponse({ error: error.message }, 400);
    }

    if (data.user?.id) {
      const { data: profile, error: profileError } = await admin
        .from("profiles")
        .upsert({
          id: data.user.id,
          name,
          username,
          avatar_url: normalizeProfileValue(body.avatar_url),
        })
        .select("id, name, username, avatar_url")
        .single();

      if (profileError) {
        return jsonResponse({ error: profileError.message }, 400);
      }

      const defaultRoleError = await assignDefaultUserRole(admin, data.user.id);

      if (defaultRoleError) {
        return jsonResponse({ error: defaultRoleError.message }, 400);
      }

      return jsonResponse({
        ...data,
        profile,
      }, 201);
    }

    return jsonResponse(data, 201);
  } catch (error) {
    return errorResponse(error);
  }
});
