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

// =====================================================================
// AUTENTICAÇÃO
// =====================================================================

// ---------------------------------------------------------------------
// Garante que existe um usuário logado. Se não houver sessão ativa,
// redireciona para a tela de login e interrompe a execução da página.
// Use no início de cada página protegida:
//   const user = await requireAuth();
//   if (!user) return; // já foi redirecionado
// ---------------------------------------------------------------------
export async function requireAuth() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    window.location.href = 'login.html';
    return null;
  }
  return session.user;
}

// ---------------------------------------------------------------------
// Encerra a sessão do usuário e volta para a tela de login.
// ---------------------------------------------------------------------
export async function logout() {
  await supabase.auth.signOut();
  window.location.href = 'login.html';
}

// ---------------------------------------------------------------------
// Liga o botão de "Sair" (se existir na página) e exibe o e-mail do
// usuário logado em um elemento com id="usuario-logado" (se existir).
// ---------------------------------------------------------------------
export function configurarBarraUsuario(user) {
  const btnSair = document.getElementById('btn-sair');
  if (btnSair) {
    btnSair.addEventListener('click', logout);
  }
  const emailEl = document.getElementById('usuario-logado');
  if (emailEl && user?.email) {
    emailEl.textContent = user.email;
  }
}

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

// ---------------------------------------------------------------------
// Calcula o valor total de uma lista de itens de agendamento_servicos
// Espera um array de objetos com { quantidade, preco_unitario }
// ---------------------------------------------------------------------
export function calcularTotalItens(itens) {
  if (!itens || !itens.length) return 0;
  return itens.reduce((soma, item) => soma + (Number(item.quantidade) * Number(item.preco_unitario)), 0);
}

// ---------------------------------------------------------------------
// Gera um link do WhatsApp (wa.me) com mensagem pré-preenchida.
// Assume DDI do Brasil (55) quando o telefone não tiver código de país.
// Retorna null se não houver telefone cadastrado.
// ---------------------------------------------------------------------
export function gerarLinkWhatsApp(telefone, mensagem) {
  if (!telefone) return null;
  let numeros = telefone.replace(/\D/g, '');
  if (!numeros) return null;
  // Se tiver 10 ou 11 dígitos (DDD + número), assume Brasil e adiciona o 55.
  if (numeros.length <= 11) {
    numeros = '55' + numeros;
  }
  return `https://wa.me/${numeros}?text=${encodeURIComponent(mensagem)}`;
}

// ---------------------------------------------------------------------
// Monta o texto padrão enviado ao cliente sobre um agendamento/orçamento.
// Espera o agendamento já carregado com joins de clientes, veiculos e
// agendamento_servicos ( quantidade, preco_unitario, servicos(descricao) ).
// ---------------------------------------------------------------------
export function montarMensagemAgendamento(agendamento) {
  const itens = agendamento.agendamento_servicos || [];
  const linhasItens = itens.map(item =>
    `• ${item.servicos?.descricao ?? 'Serviço'} (x${item.quantidade}) — ${formatarMoeda(item.preco_unitario * item.quantidade)}`
  ).join('\n');
  const total = calcularTotalItens(itens);

  return `Olá, ${agendamento.clientes?.nome ?? ''}! Aqui é da Oficina Mecânica.\n\n` +
    `🚗 Veículo: ${agendamento.veiculos ? `${agendamento.veiculos.marca} ${agendamento.veiculos.modelo} - ${agendamento.veiculos.placa}` : '-'}\n` +
    `🗓️ Data/Hora: ${formatarDataHora(agendamento.data_hora)}\n\n` +
    `Serviços:\n${linhasItens || '(nenhum item)'}\n\n` +
    `💰 Total: ${formatarMoeda(total)}\n` +
    `📌 Status: ${agendamento.status}` +
    (agendamento.observacoes ? `\n\n📝 Observações: ${agendamento.observacoes}` : '');
}
