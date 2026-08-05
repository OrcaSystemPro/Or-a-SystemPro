-- ============================================================================
-- OrcaSystem Pro — Schema Supabase (Postgres)
-- Cole este arquivo inteiro no SQL Editor do seu projeto Supabase e rode.
--
-- Estas 19 tabelas correspondem exatamente às 19 chaves que o OrcaSystem já
-- sincronizava com Google Sheets (lista GS_SHEETS do sistema). As colunas usam
-- os mesmos nomes camelCase já usados nos objetos JS do sistema (e no arquivo
-- OrcaSystem_Pro_Banco_de_Dados_V35.xlsx, que documentava esse mesmo schema).
--
-- Segurança: Row Level Security fica ligado em todas as tabelas, com uma
-- policy única exigindo usuário autenticado (Supabase Auth). Sem login, a
-- "anon key" pública (que vai ficar visível no HTML hospedado) não consegue
-- ler nem escrever nada. Isso reproduz o modelo atual (quem tem acesso à
-- planilha edita tudo) trocando "acesso à planilha" por "conta cadastrada em
-- Authentication → Users".
-- ============================================================================

-- ---------------------------------------------------------------------------
-- profissionais — banco de mão de obra
-- ---------------------------------------------------------------------------
create table if not exists public.profissionais (
  id integer primary key,
  func text,
  valor numeric,
  unidade text,
  "valorOriginal" numeric,
  "dataInclusao" text,
  obs text
);

-- ---------------------------------------------------------------------------
-- maquinas — banco de máquinas/equipamentos
-- ---------------------------------------------------------------------------
create table if not exists public.maquinas (
  id integer primary key,
  nome text,
  valor numeric,
  categoria text
);

-- ---------------------------------------------------------------------------
-- clientes
-- ---------------------------------------------------------------------------
create table if not exists public.clientes (
  id integer primary key,
  nome text,
  razao text,
  cnpj text,
  cidade text,
  uf text,
  tel text,
  email text,
  contato text,
  orc text,
  setor text,
  "end" text,
  obs text
);

-- ---------------------------------------------------------------------------
-- fornecedores
-- ---------------------------------------------------------------------------
create table if not exists public.fornecedores (
  id integer primary key,
  nome text,
  cnpj text,
  cat text,
  contato text,
  tel text,
  email text,
  cidade text,
  uf text,
  cep text,
  "end" text,
  obs text
);

-- ---------------------------------------------------------------------------
-- orcamentos
-- ---------------------------------------------------------------------------
create table if not exists public.orcamentos (
  id integer primary key,
  cod text,
  "desc" text,
  cliente text,
  local text,
  valor numeric,
  status text,
  data text,
  faturamento text
);

-- ---------------------------------------------------------------------------
-- materiais_db — banco de materiais
-- ---------------------------------------------------------------------------
create table if not exists public.materiais_db (
  id integer primary key,
  "desc" text,
  cat text,
  unid text,
  valor numeric,
  "valorOriginal" numeric,
  "dataInclusao" text,
  forn text,
  obs text,
  reajustes jsonb
);

-- ---------------------------------------------------------------------------
-- atividades — últimas atividades (feed, sem id no app; servidor gera)
-- ---------------------------------------------------------------------------
create table if not exists public.atividades (
  id bigserial primary key,
  texto text,
  cor text,
  data text
);

-- ---------------------------------------------------------------------------
-- reajuste_historico / reajuste_mo_historico
-- ---------------------------------------------------------------------------
create table if not exists public.reajuste_historico (
  id integer primary key,
  indice text,
  pct numeric,
  data text,
  qtd numeric,
  "dataAplicacao" text
);

create table if not exists public.reajuste_mo_historico (
  id integer primary key,
  indice text,
  pct numeric,
  data text,
  qtd numeric,
  "dataAplicacao" text
);

-- ---------------------------------------------------------------------------
-- audit_log — auditoria
-- ---------------------------------------------------------------------------
create table if not exists public.audit_log (
  id integer primary key,
  acao text,
  orc text,
  "desc" text,
  usuario text,
  data text,
  ts text
);

-- ---------------------------------------------------------------------------
-- hist_instancias — instâncias de histogramas
-- ---------------------------------------------------------------------------
create table if not exists public.hist_instancias (
  id integer primary key,
  "orcId" text,
  nome text,
  "criadoEm" text
);

-- ---------------------------------------------------------------------------
-- hist_marcos / hist_linhas_mo / hist_linhas_equip — uma tabela para todas as
-- instâncias (antes eram chaves separadas hist_marcos_{instId} no localStorage;
-- aqui "instId" é só mais uma coluna, já era assim no xlsx original).
-- ---------------------------------------------------------------------------
create table if not exists public.hist_marcos (
  id integer primary key,
  "instId" text,
  nome text,
  "dataInicio" text,
  "dataFim" text,
  status text,
  fat text
);

create table if not exists public.hist_linhas_mo (
  id integer primary key,
  "instId" text,
  func text,
  fase text,
  qtd numeric,
  "dataInicio" text,
  "dataFim" text,
  observacao text
);

create table if not exists public.hist_linhas_equip (
  id integer primary key,
  "instId" text,
  equipamento text,
  fase text,
  qtd numeric,
  "dataInicio" text,
  "dataFim" text,
  observacao text
);

-- ---------------------------------------------------------------------------
-- hist_config — configuração por histograma (chave primária natural: instId)
-- ---------------------------------------------------------------------------
create table if not exists public.hist_config (
  "instId" text primary key,
  "horasDia" numeric,
  "diasSemana" numeric,
  "limAtencao" numeric,
  "limConflito" numeric
);

-- ---------------------------------------------------------------------------
-- custos_padrao — banco de custos padrão
-- ---------------------------------------------------------------------------
create table if not exists public.custos_padrao (
  id integer primary key,
  "desc" text,
  "valorUnit" numeric,
  unidade text,
  obs text,
  "qtdPessoas" numeric,
  "qtdDias" numeric,
  "qtdItens" numeric
);

-- ---------------------------------------------------------------------------
-- org_nos — organograma
-- ---------------------------------------------------------------------------
create table if not exists public.org_nos (
  id integer primary key,
  titulo text,
  nome text,
  pai text,
  nivel numeric,
  tipo text,
  dedicacao text,
  x numeric,
  y numeric
);

-- ---------------------------------------------------------------------------
-- notif_eventos — eventos de notificação
-- ---------------------------------------------------------------------------
create table if not exists public.notif_eventos (
  id integer primary key,
  label text,
  ativo boolean,
  categoria text
);

-- ---------------------------------------------------------------------------
-- empresa_cfg — configurações da empresa/BDI (chave/valor)
-- ---------------------------------------------------------------------------
create table if not exists public.empresa_cfg (
  chave text primary key,
  valor text
);

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
