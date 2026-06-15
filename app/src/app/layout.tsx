import type { Metadata, Viewport } from "next";
import "@/styles/globals.css";

export const metadata: Metadata = {
  title: "CertDeck",
  description:
    "Estudia certificaciones de ciberseguridad, cloud y tecnología con memorización espaciada.",
  applicationName: "CertDeck",
};

export const viewport: Viewport = {
  themeColor: "#2b8fe6",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

// Aplica la clase `.dark` ANTES del primer pintado para evitar el parpadeo
// claro→oscuro al cargar (lee la preferencia persistida en localStorage).
const themeNoFlashScript = `try{if(localStorage.getItem('certdeck:theme')==='dark'){document.documentElement.classList.add('dark')}}catch(e){}`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeNoFlashScript }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
