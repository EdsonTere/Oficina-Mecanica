# Sistema Oficina Mecânica

Sistema leve e responsivo (mobile-first) para gestão de clientes, veículos, serviços e agendamentos.
Frontend em HTML + Tailwind CSS (via CDN) + JavaScript puro (ES Modules). Backend no Supabase.

## Estrutura de arquivos

```
oficina-mecanica/
├── index.html          → Painel principal (agendamentos)
├── clientes.html        → Cadastro e listagem de clientes/veículos
├── servicos.html        → Cadastro e listagem de serviços/preços
├── js/
│   └── supabase.js      → Configuração do cliente Supabase
└── schema.sql           → Script para criar as tabelas no Supabase
```

## Passo 1 — Criar o projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e crie um projeto gratuito.
2. No painel do projeto, abra **SQL Editor**.
3. Cole todo o conteúdo do arquivo `schema.sql` e clique em **Run**.
   Isso cria as tabelas `clientes`, `veiculos`, `servicos`, `agendamentos` e as políticas de acesso (RLS).

## Passo 2 — Configurar as chaves do Supabase

1. No painel do Supabase, vá em **Project Settings > API**.
2. Copie a **Project URL** e a chave **anon public**.
3. Abra o arquivo `js/supabase.js` e substitua:

```js
const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';
```

pelos valores reais do seu projeto.

## Passo 3 — Testar localmente (opcional)

Como o projeto usa ES Modules, é preciso servir os arquivos via HTTP (abrir o `.html` direto no navegador com `file://` não funciona). Uma forma simples:

```bash
npx serve .
```

ou use a extensão "Live Server" do VS Code.

## Passo 4 — Deploy gratuito na Vercel

1. Crie um repositório no GitHub com esta pasta (ou envie os arquivos direto).
2. Acesse [vercel.com](https://vercel.com), clique em **Add New Project** e importe o repositório.
3. Como é um projeto estático (sem build), a Vercel detecta automaticamente. Não é necessário configurar comando de build — apenas confirme o deploy.
4. Pronto! Você receberá uma URL pública (ex: `oficina-mecanica.vercel.app`) para acessar do computador ou celular.

## Observações importantes

- **Segurança**: as políticas RLS criadas no `schema.sql` liberam leitura/escrita pública usando a `anon key`, o que é adequado para uso interno rápido. Se quiser restringir o acesso (por exemplo, exigir login), configure o **Supabase Auth** e ajuste as políticas RLS posteriormente.
- **Placas duplicadas**: o campo `placa` é único — o sistema impede cadastrar duas vezes o mesmo veículo.
- **Exclusão em cascata**: ao excluir um cliente, seus veículos e agendamentos vinculados também são removidos automaticamente.
- **Responsividade**: menu superior aparece em telas ≥ 768px (desktop); menu inferior fixo aparece em telas menores (celular).
