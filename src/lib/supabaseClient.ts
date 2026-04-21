import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const url = String(import.meta.env.VITE_SUPABASE_URL ?? "").trim();
const anon = String(import.meta.env.VITE_SUPABASE_ANON_KEY ?? "").trim();

function isPlaceholderUrl(u: string): boolean {
  const lower = u.toLowerCase();
  return (
    lower.includes("seu-projeto") ||
    lower.includes("your-project") ||
    lower.includes("example.supabase")
  );
}

function isPlaceholderKey(k: string): boolean {
  const lower = k.toLowerCase();
  return (
    lower.includes("sua-chave") ||
    lower.includes("your-anon") ||
    lower === "sua-chave-anon" ||
    k.length < 20
  );
}

export function getSupabaseConfig(): { url: string; anon: string } {
  return { url, anon };
}

export function isSupabaseConfigured(): boolean {
  return Boolean(url && anon && !isPlaceholderUrl(url) && !isPlaceholderKey(anon));
}

/** Mensagem quando URL/chave não estão disponíveis (dev vs build de produção). */
export function supabaseEnvHint(): string {
  if (import.meta.env.PROD) {
    return "No painel do Vercel (ou outro host): Settings → Environment Variables. Adicione VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY (valores em Supabase → Settings → API) para Production e faça Redeploy.";
  }
  return "Na pasta do projeto, crie o arquivo .env com VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY (copie de .env.example), salve e reinicie com npm run dev.";
}

export function createSupabaseClient(): SupabaseClient | null {
  if (!isSupabaseConfigured()) return null;
  return createClient(url, anon);
}
