-- =====================================================================
-- MIGRAÇÃO V5 - OFICINA MECÂNICA
-- Adiciona campo de "revisão" (retorno futuro) aos agendamentos.
-- Usado para lembrar o cliente de voltar depois de alguns meses para
-- o mesmo serviço ou outro (troca de óleo, revisão geral, etc.).
--
-- Execute este script no SQL Editor do Supabase.
-- =====================================================================

alter table public.agendamentos
  add column if not exists data_revisao date;

comment on column public.agendamentos.data_revisao is
  'Data sugerida para o cliente retornar (revisão futura). Opcional.';

-- =====================================================================
-- FIM DA MIGRAÇÃO
-- =====================================================================
