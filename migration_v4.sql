-- =====================================================================
-- MIGRAÇÃO V4 - OFICINA MECÂNICA
-- Adiciona controle de acesso por administrador:
--   - Cada usuário passa a ter um "perfil" com status ativo/inativo
--   - Um usuário marcado como administrador pode ver todos os perfis
--     e ativar/desativar o acesso de qualquer cliente
--   - Usuários desativados são desconectados automaticamente no
--     próximo carregamento de página
--
-- Execute este script no SQL Editor do Supabase.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tabela de perfis (uma linha por usuário do Supabase Auth)
-- ---------------------------------------------------------------------
create table if not exists public.perfis (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  ativo boolean not null default true,
  is_admin boolean not null default false,
  ultimo_login timestamptz,
  created_at timestamptz not null default now()
);

alter table public.perfis enable row level security;

-- ---------------------------------------------------------------------
-- 2. Função auxiliar: verifica se o usuário atual é administrador
-- (security definer para não entrar em recursão com a RLS de perfis)
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select is_admin from public.perfis where user_id = auth.uid()), false);
$$;

-- ---------------------------------------------------------------------
-- 3. Cria automaticamente um perfil sempre que um novo usuário é
-- criado no Supabase Auth (seja por autocadastro ou pelo painel admin)
-- ---------------------------------------------------------------------
create or replace function public.criar_perfil_novo_usuario()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.perfis (user_id, email)
  values (new.id, new.email)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.criar_perfil_novo_usuario();

-- Cria retroativamente o perfil de usuários que já existiam antes desta migração
insert into public.perfis (user_id, email)
select id, email from auth.users
on conflict (user_id) do nothing;

-- ---------------------------------------------------------------------
-- 4. Protege as colunas sensíveis (ativo / is_admin): um usuário comum
-- não pode alterar essas colunas nem para si mesmo, mesmo via API.
-- Apenas o administrador pode. Isso vale mesmo que a política de UPDATE
-- abaixo permita a operação em geral (o gatilho reverte a tentativa).
-- ---------------------------------------------------------------------
create or replace function public.proteger_colunas_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Só aplica a proteção quando a alteração vem de uma sessão de usuário
  -- autenticado (auth.uid() preenchido). Alterações feitas diretamente
  -- pelo SQL Editor do Supabase (sem contexto de usuário) não são
  -- bloqueadas, pois só quem tem acesso ao painel do banco chega até lá.
  if auth.uid() is not null and not public.is_admin() then
    new.ativo := old.ativo;
    new.is_admin := old.is_admin;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_proteger_colunas_perfil on public.perfis;
create trigger trg_proteger_colunas_perfil
  before update on public.perfis
  for each row execute function public.proteger_colunas_perfil();

-- ---------------------------------------------------------------------
-- 5. Políticas de acesso à tabela perfis
-- ---------------------------------------------------------------------
drop policy if exists "perfis_select" on public.perfis;
create policy "perfis_select" on public.perfis
  for select using (auth.uid() = user_id or public.is_admin());

drop policy if exists "perfis_update" on public.perfis;
create policy "perfis_update" on public.perfis
  for update using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());

-- (Sem política de INSERT/DELETE para usuários comuns: perfis só são
-- criados pelo gatilho acima, com privilégio elevado.)

-- =====================================================================
-- 6. IMPORTANTE — DEPOIS DE RODAR ESTE SCRIPT:
--
-- a) Torne sua própria conta administradora. Rode este comando
--    substituindo pelo seu e-mail de login:
--
--    update public.perfis set is_admin = true where email = 'SEU-EMAIL-AQUI';
--
-- b) Vá em Authentication > Sign In / Up no painel do Supabase e
--    desative "Allow new users to sign up". Isso impede que qualquer
--    pessoa com o link crie uma conta sozinha — só você poderá criar
--    novos acessos (Authentication > Users > Add user).
-- =====================================================================
