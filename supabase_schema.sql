-- ============================================================================
-- OrcaSystem Pro — Schema Supabase (Postgres)
-- Cole este arquivo inteiro no SQL Editor do seu projeto Supabase e rode.
--
-- Este schema é seguro para rodar de novo (drop + recreate) caso você já
-- tenha criado uma versão anterior com colunas fixas.
--
-- Desenho: cada tabela guarda o objeto inteiro (como já era salvo no
-- localStorage do OrcaSystem) numa coluna "dados" (jsonb), em vez de tentar
-- prever cada campo como coluna separada. Isso evita quebrar a sincronização
-- toda vez que um objeto tiver um campo novo/opcional (ex.: orçamentos têm
-- dezenas de campos aninhados — itens de mão de obra, equipamentos,
-- materiais, impostos, snapshot original etc.). O "id" (ou "instId"/"chave")
-- fica também como coluna própria só para ser a chave primária.
--
-- Segurança: Row Level Security fica ligado em todas as tabelas, com uma
-- policy única exigindo usuário autenticado (Supabase Auth). Sem login, a
-- "anon key" pública (que vai ficar visível no HTML hospedado) não consegue
-- ler nem escrever nada.
-- ============================================================================

drop table if exists public.profissionais cascade;
drop table if exists public.maquinas cascade;
drop table if exists public.clientes cascade;
drop table if exists public.fornecedores cascade;
drop table if exists public.orcamentos cascade;
drop table if exists public.materiais_db cascade;
drop table if exists public.atividades cascade;
drop table if exists public.reajuste_historico cascade;
drop table if exists public.reajuste_mo_historico cascade;
drop table if exists public.audit_log cascade;
drop table if exists public.hist_instancias cascade;
drop table if exists public.hist_marcos cascade;
drop table if exists public.hist_linhas_mo cascade;
drop table if exists public.hist_linhas_equip cascade;
drop table if exists public.hist_config cascade;
drop table if exists public.custos_padrao cascade;
drop table if exists public.org_nos cascade;
drop table if exists public.notif_eventos cascade;
drop table if exists public.empresa_cfg cascade;

-- ---------------------------------------------------------------------------
-- Tabelas "lista de objetos" — id do próprio app é a chave primária.
-- ---------------------------------------------------------------------------
create table public.profissionais   (id integer primary key, dados jsonb not null);
create table public.maquinas        (id integer primary key, dados jsonb not null);
create table public.clientes        (id integer primary key, dados jsonb not null);
create table public.fornecedores    (id integer primary key, dados jsonb not null);
create table public.orcamentos      (id integer primary key, dados jsonb not null);
create table public.materiais_db    (id integer primary key, dados jsonb not null);
create table public.reajuste_historico    (id integer primary key, dados jsonb not null);
create table public.reajuste_mo_historico (id integer primary key, dados jsonb not null);
create table public.audit_log       (id integer primary key, dados jsonb not null);
create table public.hist_instancias (id integer primary key, dados jsonb not null);
create table public.custos_padrao   (id integer primary key, dados jsonb not null);
create table public.org_nos         (id integer primary key, dados jsonb not null);
create table public.notif_eventos   (id integer primary key, dados jsonb not null);

-- ---------------------------------------------------------------------------
-- atividades — feed sem id no app; o Postgres gera o id.
-- ---------------------------------------------------------------------------
create table public.atividades (id bigserial primary key, dados jsonb not null);

-- ---------------------------------------------------------------------------
-- hist_marcos / hist_linhas_mo / hist_linhas_equip — várias instâncias de
-- histograma na mesma tabela; "instId" identifica a instância.
-- ---------------------------------------------------------------------------
create table public.hist_marcos       (id integer primary key, "instId" text not null, dados jsonb not null);
create table public.hist_linhas_mo    (id integer primary key, "instId" text not null, dados jsonb not null);
create table public.hist_linhas_equip (id integer primary key, "instId" text not null, dados jsonb not null);

-- ---------------------------------------------------------------------------
-- hist_config — um objeto de configuração por instância (chave = instId).
-- ---------------------------------------------------------------------------
create table public.hist_config ("instId" text primary key, dados jsonb not null);

-- ---------------------------------------------------------------------------
-- empresa_cfg — configurações da empresa/BDI (já era naturalmente chave/valor).
-- ---------------------------------------------------------------------------
create table public.empresa_cfg (chave text primary key, valor text);

-- ============================================================================
-- Row Level Security — só usuário autenticado (Supabase Auth) acessa.
-- ============================================================================
do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'profissionais','maquinas','clientes','fornecedores','orcamentos',
      'materiais_db','atividades','reajuste_historico','reajuste_mo_historico',
      'audit_log','hist_instancias','hist_marcos','hist_linhas_mo',
      'hist_linhas_equip','hist_config','custos_padrao','org_nos',
      'notif_eventos','empresa_cfg'
    ])
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format(
      'drop policy if exists "auth_full_access" on public.%I;', t
    );
    execute format(
      'create policy "auth_full_access" on public.%I for all to authenticated using (true) with check (true);',
      t
    );
  end loop;
end $$;
