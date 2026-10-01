# NutriCasa — regras do projeto

- **Fonte da verdade: [PLANO.md](PLANO.md).** Escopo, fases, stack e banco estão lá. Não implementar nada da seção "Fica fora do MVP" sem o usuário pedir.
- Seguir as fases em ordem; marcar `[x]` no checklist do PLANO.md ao concluir cada item.
- Todo acesso a dados passa por `lib/dados.dart` (funções simples). Telas nunca falam direto com Supabase/Gemini.
- Chave do Gemini **nunca** no app — só na Edge Function `gerar-cardapio`.
- Calorias/macros são calculadas pela TACO, nunca confiar no valor da IA.
- Visual: `stitch_strategic_plan_execution/` (telas + DESIGN.md) com os ajustes da seção "Visual" do PLANO.md (fundo `#FAFAF7`, sem itens fora do MVP).
- UI em português do Brasil.
- Um commit por pedaço funcionando.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

On this machine the CLI is not on PATH: use `python -m graphify ...`.

Rules:
- For codebase questions, first run `python -m graphify query "<question>"` when graphify-out/graph.json exists. Use `python -m graphify path "<A>" "<B>"` for relationships and `python -m graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `python -m graphify update .` to keep the graph current (AST-only, no API cost).
