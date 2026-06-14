import type { CapacitorConfig } from "@capacitor/cli";

/**
 * CertDeck — configuración de Capacitor.
 * `webDir` apunta a la salida del export estático de Next.js (`out/`), ver ADR 0003.
 * Flujo: `npm run build` (genera `out/`) → `npx cap sync`.
 */
const config: CapacitorConfig = {
  appId: "com.certdeck.app",
  appName: "CertDeck",
  webDir: "out",
};

export default config;
