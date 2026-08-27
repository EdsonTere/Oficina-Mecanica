// =====================================================================
// CONFIGURAÇÃO DO CLIENTE SUPABASE
// =====================================================================
// 1. Vá em Project Settings > API no seu projeto Supabase.
// 2. Copie a "Project URL" e a "anon public" key.
// 3. Substitua os valores abaixo.
// =====================================================================

import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

const SUPABASE_URL = 'https://amuqdnydeqmvcsbwzhir.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtdXFkbnlkZXFtdmNzYnd6aGlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3OTUyMTgsImV4cCI6MjEwMzM3MTIxOH0.X4EufsAGFkvRAJ2II1P2wBevQCjE5tBdEnd4lStq510';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ---------------------------------------------------------------------
// Helper genérico para exibir erros de forma amigável no console
// e opcionalmente em um elemento da tela.
// ---------------------------------------------------------------------
export function logSupabaseError(context, error) {
  console.error(`[Supabase] Erro em "${context}":`, error);
}

// ---------------------------------------------------------------------
// Helper de formatação de moeda (BRL)
// ---------------------------------------------------------------------
export function formatarMoeda(valor) {
  const numero = Number(valor) || 0;
  return numero.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

// ---------------------------------------------------------------------
// Helper de formatação de data/hora (pt-BR)
// ---------------------------------------------------------------------
export function formatarDataHora(isoString) {
  if (!isoString) return '-';
  const data = new Date(isoString);
  return data.toLocaleString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
}
