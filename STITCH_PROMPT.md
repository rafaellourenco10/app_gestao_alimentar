# Prompt para o Google Stitch

Cole o bloco abaixo no Stitch (modo **Mobile**). Ele está em inglês porque o Stitch costuma gerar layouts melhores assim, mas pede que todos os textos da interface saiam em português.

Dica: se o resultado vier com telas faltando, gere uma tela por vez reutilizando o bloco "Visual style" + a descrição da tela.

---

```
Design a mobile app (Android/iOS, Material 3) called "NutriCasa" — a home food manager. The user lists the food they have at home, and AI creates recipes using only those ingredients, showing calories, macros and step-by-step instructions. Target audience: Brazilian adults who want to cook with what they have, save money and avoid food waste.

ALL UI text must be in Brazilian Portuguese.

Visual style:
- Fresh, friendly and clean; food-app feel, not clinical
- Primary color: fresh green (#2E7D32 family); accent: warm orange (#FB8C00) for main actions and calorie highlights
- Light background (#FAFAF7), white cards with large rounded corners (16–20px), soft shadows
- Rounded sans-serif typography (e.g. Nunito or Poppins), clear hierarchy
- Simple line icons; food emoji allowed in pantry chips (🥚 🍅 🍌 🍞)
- Bottom navigation bar with 4 tabs: "Despensa", "Cardápios", "Favoritos", "Perfil"
- Generous spacing, thumb-friendly buttons, accessible contrast

Screens:

1. Login / Cadastro
   - Logo + tagline "Cozinhe com o que você já tem"
   - Email and password fields, "Entrar" button, "Criar conta" link

2. Despensa (home tab)
   - Header "Minha despensa" with item count
   - Search field with autocomplete "Adicionar alimento… (ex: ovo, tomate)"; show a dropdown with suggestions
   - Pantry items as removable chips or a list grouped by category (Frutas, Verduras e legumes, Proteínas, Grãos e pães, Laticínios)
   - Empty state illustration: "Sua despensa está vazia. Adicione o que você tem em casa!"
   - Large floating orange button at the bottom: "✨ Gerar cardápio"
   - Small text above the button: "5 gerações restantes hoje"

3. Gerando cardápio (loading)
   - Friendly animation/illustration of a pan or chef hat
   - Text: "Criando receitas com seus ingredientes…"

4. Cardápio gerado (results)
   - Title "Seu cardápio" + subtitle "3 receitas com o que você tem"
   - 3 recipe cards, each with: food photo placeholder, recipe title, calorie badge (e.g. "320 kcal"), time ("15 min"), difficulty ("Fácil"), and a heart icon to favorite
   - Secondary button "🔄 Gerar outras opções"

5. Detalhe da receita
   - Hero image placeholder, title, time / servings / difficulty row
   - Nutrition card: big calories number + 3 macro bars or rings (Proteínas, Carboidratos, Gorduras in grams)
   - "Ingredientes" section: list with grams; mark items the user has in the pantry with a green check
   - "Modo de preparo" section: numbered steps in cards
   - Bottom actions: "❤️ Favoritar" and thumbs up/down feedback "Gostou da receita?"
   - Small disclaimer at the bottom: "Valores nutricionais estimados com base na Tabela TACO."

6. Favoritos
   - Grid or list of saved recipe cards (title, kcal, time)
   - Empty state: "Você ainda não favoritou nenhuma receita"

7. Cardápios (history tab)
   - List of previously generated recipes grouped by date ("Hoje", "Ontem", "Esta semana")

8. Perfil
   - Avatar, name, email
   - Simple stats: "Receitas geradas", "Favoritas"
   - Options: "Preferências alimentares (em breve)", "Política de privacidade", "Sair"

Also show these states: daily limit reached ("Você atingiu o limite de hoje. Volte amanhã!"), no internet error, and an error card with a "Tentar novamente" button.
```
