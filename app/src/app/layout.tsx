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

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
