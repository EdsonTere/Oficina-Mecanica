-- =====================================================================
-- MIGRAÇÃO V3 - OFICINA MECÂNICA
-- Adiciona login (Supabase Auth) com ambiente isolado por usuário.
-- Cada usuário passa a ver SOMENTE os próprios clientes, veículos,
-- serviços e agendamentos.
--
-- ATENÇÃO: este script APAGA os dados de teste cadastrados até agora
-- (clientes, veículos, serviços, agendamentos), pois os registros
-- antigos não têm dono (user_id) e não seria possível atribuí-los
-- automaticamente a um usuário específico.
--
-- Execute este script no SQL Editor do Supabase.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Limpa os dados de teste (ordem por causa das FKs)
-- ---------------------------------------------------------------------
truncate table public.agendamento_servicos cascade;
truncate table public.agendamentos cascade;
truncate table public.veiculos cascade;
truncate table public.clientes cascade;
truncate table public.servicos cascade;

-- ---------------------------------------------------------------------
-- 2. Adiciona a coluna user_id em todas as tabelas principais
-- O valor padrão "auth.uid()" preenche automaticamente com o usuário
-- logado no momento do INSERT — o frontend não precisa informar isso.
-- ---------------------------------------------------------------------
alter table public.clientes
  add column if not exists user_id uuid not null default auth.uid() references auth.users(id) on delete cascade;

alter table public.veiculos
  add column if not exists user_id uuid not null default auth.uid() references auth.users(id) on delete cascade;

alter table public.servicos
  add column if not exists user_id uuid not null default auth.uid() references auth.users(id) on delete cascade;

alter table public.agendamentos
  add column if not exists user_id uuid not null default auth.uid() references auth.users(id) on delete cascade;

alter table public.agendamento_servicos
  add column if not exists user_id uuid not null default auth.uid() references auth.users(id) on delete cascade;

create index if not exists idx_clientes_user_id on public.clientes(user_id);
create index if not exists idx_veiculos_user_id on public.veiculos(user_id);
create index if not exists idx_servicos_user_id on public.servicos(user_id);
create index if not exists idx_agendamentos_user_id on public.agendamentos(user_id);
create index if not exists idx_agendamento_servicos_user_id on public.agendamento_servicos(user_id);

-- ---------------------------------------------------------------------
-- 3. Remove as políticas antigas (acesso público) de todas as tabelas
-- ---------------------------------------------------------------------
drop policy if exists "clientes_select_publica" on public.clientes;
drop policy if exists "clientes_insert_publica" on public.clientes;
drop policy if exists "clientes_update_publica" on public.clientes;
drop policy if exists "clientes_delete_publica" on public.clientes;

drop policy if exists "veiculos_select_publica" on public.veiculos;
drop policy if exists "veiculos_insert_publica" on public.veiculos;
drop policy if exists "veiculos_update_publica" on public.veiculos;
drop policy if exists "veiculos_delete_publica" on public.veiculos;

drop policy if exists "servicos_select_publica" on public.servicos;
drop policy if exists "servicos_insert_publica" on public.servicos;
drop policy if exists "servicos_update_publica" on public.servicos;
drop policy if exists "servicos_delete_publica" on public.servicos;

drop policy if exists "agendamentos_select_publica" on public.agendamentos;
drop policy if exists "agendamentos_insert_publica" on public.agendamentos;
drop policy if exists "agendamentos_update_publica" on public.agendamentos;
drop policy if exists "agendamentos_delete_publica" on public.agendamentos;

drop policy if exists "agendamento_servicos_select_publica" on public.agendamento_servicos;
drop policy if exists "agendamento_servicos_insert_publica" on public.agendamento_servicos;
drop policy if exists "agendamento_servicos_update_publica" on public.agendamento_servicos;
drop policy if exists "agendamento_servicos_delete_publica" on public.agendamento_servicos;

-- ---------------------------------------------------------------------
-- 4. Cria as novas políticas: cada usuário só acessa suas próprias linhas
-- ---------------------------------------------------------------------

-- CLIENTES
create policy "clientes_select_dono" on public.clientes for select using (auth.uid() = user_id);
create policy "clientes_insert_dono" on public.clientes for insert with check (auth.uid() = user_id);
create policy "clientes_update_dono" on public.clientes for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "clientes_delete_dono" on public.clientes for delete using (auth.uid() = user_id);

-- VEICULOS
create policy "veiculos_select_dono" on public.veiculos for select using (auth.uid() = user_id);
create policy "veiculos_insert_dono" on public.veiculos for insert with check (auth.uid() = user_id);
create policy "veiculos_update_dono" on public.veiculos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "veiculos_delete_dono" on public.veiculos for delete using (auth.uid() = user_id);

-- SERVICOS
create policy "servicos_select_dono" on public.servicos for select using (auth.uid() = user_id);
create policy "servicos_insert_dono" on public.servicos for insert with check (auth.uid() = user_id);
create policy "servicos_update_dono" on public.servicos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "servicos_delete_dono" on public.servicos for delete using (auth.uid() = user_id);

-- AGENDAMENTOS
create policy "agendamentos_select_dono" on public.agendamentos for select using (auth.uid() = user_id);
create policy "agendamentos_insert_dono" on public.agendamentos for insert with check (auth.uid() = user_id);
create policy "agendamentos_update_dono" on public.agendamentos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "agendamentos_delete_dono" on public.agendamentos for delete using (auth.uid() = user_id);

-- AGENDAMENTO_SERVICOS
create policy "agendamento_servicos_select_dono" on public.agendamento_servicos for select using (auth.uid() = user_id);
create policy "agendamento_servicos_insert_dono" on public.agendamento_servicos for insert with check (auth.uid() = user_id);
create policy "agendamento_servicos_update_dono" on public.agendamento_servicos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "agendamento_servicos_delete_dono" on public.agendamento_servicos for delete using (auth.uid() = user_id);

-- =====================================================================
-- IMPORTANTE: antes de testar o cadastro, vá em
-- Authentication > Providers > Email no painel do Supabase e, se quiser
-- testar rapidamente sem confirmar e-mail, desative "Confirm email".
-- (Você pode reativar depois, quando for usar em produção de verdade.)
-- =====================================================================
