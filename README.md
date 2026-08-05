# OrcaSystem Pro — Banco de Dados na Nuvem (Supabase)

Este repositório contém o OrcaSystem Pro já adaptado para usar **Supabase (Postgres)**
como banco de dados na nuvem, no lugar do Google Sheets.

- `index.html` — o sistema completo (era `OrcaSystem_Pro_V35_GoogleSync.html`).
- `supabase_schema.sql` — schema Postgres para colar no SQL Editor do Supabase.

## 1. Criar o projeto Supabase

1. Crie uma conta em https://supabase.com (gratuito) e um novo projeto.
2. Abra **SQL Editor** → cole o conteúdo de `supabase_schema.sql` → **Run**.
   Isso cria as 19 tabelas e já ativa Row Level Security (só usuário logado acessa).
3. Vá em **Authentication → Users → Add user** e crie um usuário (e-mail/senha) para
   cada pessoa que vai sincronizar o sistema. Não é preciso nenhum fluxo de "criar conta"
   dentro do próprio OrcaSystem — os usuários já existem no Supabase.
4. Vá em **Settings → API** e copie:
   - **Project URL**
   - **anon public key**

## 2. Publicar o sistema (GitHub Pages)

1. Crie um repositório novo no GitHub (pode ser privado).
2. Suba os arquivos deste diretório (`index.html`, `supabase_schema.sql`, este `README.md`).
3. Em **Settings → Pages**, escolha a branch `main` e a pasta raiz (`/`).
4. O GitHub te dá uma URL do tipo `https://SEU-USUARIO.github.io/SEU-REPO/` — é nela que
   o sistema deve ser acessado (não abra o `index.html` direto do disco: o Supabase Auth
   exige HTTP/HTTPS).

## 3. Configurar o sistema

1. Acesse a URL publicada e entre com o login local do sistema (o mesmo de sempre).
2. Vá em **Configurações → ☁️ Supabase — Banco de Dados**.
3. Cole a **Project URL** e a **Anon Public Key**.
4. Informe o **e-mail** e **senha** do usuário criado no passo 1.3 e clique em **Entrar**.
5. Clique em **🧪 Testar** — deve aparecer "Conectado ✅".
6. Clique no ícone ☁ no topo (ou "☁ Sincronizar Nuvem") para rodar a primeira sincronização.

## Checklist de teste ponta-a-ponta

- [ ] Login no Supabase funciona e o status muda para "Autenticado ✅"
- [ ] "Testar" retorna "Conectado ✅"
- [ ] Após sincronizar, as tabelas no Supabase (Table Editor) mostram os dados do sistema
      (clientes, orçamentos, profissionais etc.)
- [ ] Alterar um dado no sistema (ex.: editar um cliente) e, depois de ~2,5s, conferir que
      a tabela `clientes` no Supabase foi atualizada
- [ ] Abrir o sistema em outro navegador/computador, logar com o mesmo usuário Supabase e
      confirmar que os dados aparecem sincronizados
- [ ] Testar login com e-mail/senha errados — deve mostrar erro sem travar a tela

## Observações importantes

- A sincronização substitui **todo o conteúdo de cada tabela** a cada rodada (o mesmo
  comportamento que já existia com Google Sheets) — não há mesclagem de conflitos linha a
  linha. Se duas pessoas editarem ao mesmo tempo e sincronizarem em momentos próximos,
  a última sincronização prevalece.
- As listas de categorias (`cats_*`) continuam apenas locais, como já era antes — nunca
  fizeram parte da sincronização.
- A `anon public key` do Supabase fica visível no código-fonte da página publicada — isso é
  esperado e seguro *desde que* o Row Level Security do `supabase_schema.sql` esteja ativo
  (ele exige login para qualquer leitura/escrita). Nunca desative o RLS dessas tabelas.
