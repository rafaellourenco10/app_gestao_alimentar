# NutriCasa — regras do projeto

- **Fonte da verdade: [PLANO.md](PLANO.md).** Escopo, fases, stack e banco estão lá. Não implementar nada da seção "Fica fora do MVP" sem o usuário pedir.
- Seguir as fases em ordem; marcar `[x]` no checklist do PLANO.md ao concluir cada item.
- Todo acesso a dados passa por `lib/dados.dart` (funções simples). Telas nunca falam direto com Supabase/Gemini.
- Chave do Gemini **nunca** no app — só na Edge Function `gerar-cardapio`.
- Calorias/macros são calculadas pela TACO, nunca confiar no valor da IA.
- Visual: `stitch_strategic_plan_execution/` (telas + DESIGN.md) com os ajustes da seção "Visual" do PLANO.md (fundo `#FAFAF7`, sem itens fora do MVP).
- UI em português do Brasil.
- Commit **a cada progresso** (`flutter analyze` + `flutter test` limpos), sem perguntar. **Push só quando o usuário pedir.**
- O usuário testa no próprio celular (`flutter run`); não usar emulador.
- Novas ideias: mandar **lista numerada** de possíveis alterações → o usuário escolhe os números → registrar no PLANO.md → executar uma tarefa por vez, com commit ao fim de cada uma → resumo final; push só se ele pedir.

## graphify (opcional)

O grafo do código em `graphify-out/` é atualizado sozinho a cada commit (hook do git, sem custo de IA).
Consultar só quando ajudar — ex.: projeto grande, "quem usa X?", "o que quebra se mudar Y?":
`python -m graphify query "<pergunta>"` (o comando `graphify` não está no PATH desta máquina).
