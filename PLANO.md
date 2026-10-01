# Plano do MVP: NutriCasa

**Ideia:** o usuário cadastra o que tem em casa → a IA (Gemini) monta receitas usando esses ingredientes → o app calcula as calorias e os macros com a Tabela TACO.

**Estratégia:** primeiro o app completo com **dados falsos (mock)** e sem backend. Depois conectamos o Supabase e o Gemini. Assim você vê e testa o app rodando cedo, sem precisar criar contas.

## Stack

| Camada | Escolha | Quando entra |
|---|---|---|
| App | Flutter | Fase 1 |
| Dados de alimentos | Subconjunto da TACO em JSON dentro do app | Fase 1 |
| Backend | Supabase (Postgres, Auth, Edge Functions) | Fase 2 |
| IA | Gemini Flash (plano grátis do Google AI Studio) | Fase 3 |

Estado no Flutter: `setState`. Adicionar Riverpod só se ficar difícil passar dados entre as telas.

### Como o "conectar depois" funciona

Todo o acesso a dados fica em **um único arquivo**, `lib/dados.dart`, com funções simples: `listarDespensa()`, `adicionarItem()`, `gerarCardapio()`, `favoritar()` etc.
- **Fase 1:** as funções usam listas em memória e receitas fixas de exemplo.
- **Fases 2 e 3:** trocamos o corpo dessas funções por chamadas ao Supabase. **As telas não mudam.**

## Escopo do MVP

**Entra:**
1. Login com e-mail e senha (na Fase 1 a tela existe, mas entra direto)
2. Despensa: adicionar e remover alimentos com **quantidade opcional** ("3 un", "500 g"), autocomplete pela TACO e agrupamento por categoria
3. Gerar cardápio: 3 receitas com os ingredientes da despensa
4. Detalhe da receita: ingredientes, modo de preparo, calorias e macros, 👍/👎
5. Favoritos
6. Histórico de cardápios (agrupado por Hoje, Ontem e Esta semana)
7. Perfil simples: nome, e-mail, receitas geradas, favoritas, uso diário (x/5) e sair
8. Limite de 5 gerações por dia
9. Telas de erro: limite atingido, sem internet, falha ao gerar, despensa vazia

**Fica fora do MVP:**
- Economia em R$, kg evitados e CO₂ (não temos preços nem pesos)
- Fotos de comida (no lugar delas, um emoji ou ilustração por tipo de prato)
- Login com Google e Apple
- Leitor de código de barras
- Validade dos itens e notificações de validade
- Plano Pró/premium e modo off-line
- Filtros de cardápio (Mais rápidas, Menos calorias…)
- Etapas com % na tela de carregamento (fica só a animação)
- Foto da geladeira, plano semanal, metas de dieta, lista de compras, cache de respostas

## Visual

A base é o Stitch: as telas e o `DESIGN.md` em `stitch_strategic_plan_execution/`, **com estes ajustes:**
- **Fundo off-white quente `#FAFAF7`** (e não o azulado `#f4faff` das telas). Cards brancos `#FFFFFF`.
- Primária verde `#2E7D32`; ação principal laranja `#FB8C00`; texto `#263238`.
- Fonte Plus Jakarta Sans (pacote `google_fonts`).
- Raios: inputs 12–16 px, cards 18–20 px, badges em pílula.
- Avatar com as iniciais do usuário (sem foto).
- Remover das telas tudo o que está na lista "Fica fora do MVP".

## Banco de dados (Fase 2)

```sql
-- Importada da TACO (somente leitura)
create table alimentos (
  id int primary key,
  nome text not null,
  categoria text,
  kcal_100g numeric,
  proteina_100g numeric,
  carbo_100g numeric,
  gordura_100g numeric,
  fibra_100g numeric
);

create table despensa (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users default auth.uid(),
  alimento_id int not null references alimentos,
  quantidade text,               -- opcional: "3 un", "500 g"
  validade date,                 -- opcional
  created_at timestamptz default now(),
  unique (user_id, alimento_id)
);

create table receitas (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users default auth.uid(),
  titulo text not null,
  dados jsonb not null,          -- receita completa (ingredientes, passos, macros)
  kcal_total numeric,
  favorita boolean default false,
  feedback smallint,             -- 1 = 👍, -1 = 👎, null = sem resposta
  created_at timestamptz default now()
);
```

- **RLS** ativado em `despensa` e `receitas` (cada usuário só vê os próprios dados). `alimentos` fica com leitura pública.
- **Limite diário:** contar quantas `receitas` o usuário criou hoje. Não precisa de tabela extra.

## Fluxo da geração (Fase 3, Edge Function `gerar-cardapio`)

1. O app chama a função (o token JWT do usuário vai junto automaticamente).
2. A função lê a despensa do usuário: `id` da TACO, nome, quantidade e validade.
3. Ela verifica o limite diário e, se passou de 5, retorna o erro 429.
4. Envia ao Gemini a lista `[{id, nome, quantidade}]` com a regra: **use só esses ids e mais os básicos (sal, óleo, água); não passe da quantidade disponível; priorize os que vencem antes; informe a quantidade em gramas.**
   - Usar `responseMimeType: application/json` + `responseSchema` para garantir um JSON válido.
5. **A função calcula as calorias e os macros** com `alimentos` (gramas × valor por 100 g ÷ 100). O valor da IA nunca é usado.
6. Salva as receitas em `receitas` e devolve ao app.

Schema de resposta pedido ao Gemini:

```json
{
  "receitas": [{
    "titulo": "Omelete de tomate",
    "tipo": "cafe_da_manha",
    "tempo_min": 15,
    "porcoes": 1,
    "dificuldade": "fácil",
    "ingredientes": [{ "alimento_id": 488, "nome": "Ovo", "gramas": 100 }],
    "passos": ["Bata os ovos...", "..."]
  }]
}
```

Por que mandar os ids: a IA devolve exatamente o item da TACO, então não há como "adivinhar" qual alimento ela quis dizer. O campo `tipo` define o emoji ou a ilustração do card.

## Fases

Cada fase termina com algo funcionando que dá para testar.

### Fase 0: Setup (meio dia)
- [x] Flutter instalado
- [x] `flutter doctor` OK para Android (o usuário testa no próprio celular com `flutter run`)
- [x] Criar o repositório git e o projeto `flutter create`

**Pronto quando:** o app padrão abre no celular.

### Fase 1: App completo com dados falsos (1–2 semanas)
- [x] Tema (cores, fonte, raios) a partir do `DESIGN.md`
- [x] Navegação com as 4 abas: Despensa, Cardápios, Favoritos e Perfil
- [x] TACO completa (597 alimentos) em `assets/taco.json`, convertida do CSV de [raulfdm/taco-api](https://github.com/raulfdm/taco-api) (MIT). Sem valor de energia na fonte: leite integral, leite desnatado UHT, iogurte de abacaxi e coco verde
- [x] `lib/dados.dart` com funções que usam dados em memória
- [x] As 8 telas: login, despensa, gerando, cardápio, detalhe, histórico, favoritos e perfil
- [x] `gerarCardapio()` falso: espera 2 s e devolve 3 receitas fixas, com kcal calculado pela TACO local
- [x] Telas de erro e de estado vazio
- [x] Testes: cálculo de macros, busca, limite diário e o fluxo completo num celular pequeno (`flutter test`)

**Pronto quando:** dá para fazer o fluxo inteiro no celular (adicionar alimentos, gerar, abrir a receita, favoritar) sem internet.

### Fase 1.5: Melhorias de experiência (pedido do usuário, antes do Supabase)
- [x] Ajustar porções (recalcula quantidades)
- [x] Modo cozinhar: passo a passo em tela cheia, tela sempre acesa, timer por etapa
- [x] "Cozinhei!": desconta da despensa o que foi usado
- [x] Validade dos alimentos (aviso de vencimento)
- [x] Lista de compras (o que falta na receita + manual, compartilhar no WhatsApp)
- [x] Adicionar alimentos por voz
- [x] Boas-vindas na primeira abertura
- [x] Compartilhar receita como imagem
- [x] Modo escuro
- [x] Resumo da semana (dados reais)
- [x] Relatório de erros (Sentry, ativado só com a chave `SENTRY_DSN`)

### Fase 1.6: Próximas melhorias (escolhidas em 01/10/2026)
- [ ] Ícone do app e tela de abertura com o logo do Stitch
- [ ] Fotos por tipo de prato no lugar dos emojis
- [ ] Política de privacidade completa (LGPD)
- [ ] Testes automáticos no GitHub (Actions: analyze + test)
- [ ] Preferências alimentares (vegetariano, sem lactose/glúten, alergias, meta de calorias)
- [ ] Notificação de validade (aviso no celular mesmo com o app fechado)
- [ ] Plano da semana + lista de compras do que falta

### Fase 2: Supabase (3–5 dias)
- [ ] Criar o projeto no Supabase e pegar a URL e a anon key
- [ ] Importar a TACO completa em `alimentos` (os valores "Tr" e "NA" viram 0 ou null)
- [ ] Criar `despensa` e `receitas` com RLS
- [ ] Login real (Supabase Auth)
- [ ] Trocar o corpo das funções de `dados.dart` por chamadas ao Supabase (a geração continua falsa)

**Pronto quando:** você loga em dois celulares e vê a mesma despensa.

### Fase 3: IA com Gemini (3–5 dias)
- [ ] Criar a chave do Gemini no Google AI Studio
- [ ] Instalar o Supabase CLI e criar a Edge Function `gerar-cardapio` (o fluxo acima)
- [ ] `supabase secrets set GEMINI_API_KEY=...`
- [ ] Trocar a `gerarCardapio()` falsa pela chamada à função
- [ ] Testar com 10 despensas diferentes (incluindo uma com só 2 itens)

**Pronto quando:** o botão "Gerar cardápio" devolve receitas reais com as kcal da TACO.

### Fase 4: Acabamento e publicação (3–5 dias)
- [ ] Ícone (logo do Stitch), splash e nome
- [ ] Política de privacidade (LGPD, obrigatória na Play Store)
- [ ] Aviso: "valores nutricionais estimados, não substituem um nutricionista"
- [ ] Publicar no **teste interno** da Google Play (conta de US$ 25)

**Pronto quando:** 5 a 10 pessoas usando de verdade.

**Total estimado:** 3 a 5 semanas, trabalhando sozinho em meio período.

## Riscos e cuidados

- **A chave do Gemini nunca vai no app.** Ela fica só na Edge Function.
- **Plano grátis do Gemini:** o Google pode usar os dados para treino. Não mande dados pessoais (só alimentos e quantidades). Passe para o plano pago quando abrir para o público.
- **A IA pode inventar uma receita estranha:** existem o botão "Gerar outras opções" e o 👍/👎 (os dados ajudam a melhorar o prompt).

## Depois do MVP (por ordem de valor)

1. Validade dos itens + "use primeiro o que está vencendo" + notificações
2. Preferências e restrições (vegano, sem lactose, meta calórica)
3. Foto da geladeira (o Gemini lê imagem)
4. Login com Google e Apple
5. Plano semanal + lista de compras
6. Filtros de cardápio e cache de combinações repetidas
7. Fotos geradas para as receitas
8. Plano premium (gerações ilimitadas)
