/**
 * Acceso tipado a las variables de entorno públicas del cliente.
 *
 * El frontend usa el prefijo NEXT_PUBLIC_ (Next.js las inyecta en build).
 * Las variantes VITE_ se mantienen en `.env` solo por compatibilidad con
 * otras apps; este proyecto NO las consume (ver ADR 0003).
 *
 * IMPORTANTE: Next.js solo sustituye `process.env.NEXT_PUBLIC_*` en el
 * bundle de cliente cuando se accede de forma LITERAL (no por índice
 * dinámico). Por eso aquí se referencian con su nombre completo.
 *
 * Acceso PEREZOSO (getters): la validación solo se dispara al leer la
 * variable en runtime, no al importar el módulo, para que el build
 * estático (`output: 'export'`) no falle si el entorno no está configurado.
 */

function required(key: string, value: string | undefined): string {
  if (!value || value.trim() === "") {
    throw new Error(
      `Falta la variable de entorno requerida: ${key}. ` +
        `Defínela en app/.env (ver app/.env.example).`,
    );
  }
  return value;
}

export const env = {
  get supabaseUrl(): string {
    return required("NEXT_PUBLIC_SUPABASE_URL", process.env.NEXT_PUBLIC_SUPABASE_URL);
  },
  get supabasePublishableKey(): string {
    return required(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    );
  },
} as const;
