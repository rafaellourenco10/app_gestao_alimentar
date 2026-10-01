import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';
import 'package:nutricasa/telas/cardapio_tela.dart';
import 'package:nutricasa/telas/cozinhar_tela.dart';
import 'package:nutricasa/telas/perfil_tela.dart';
import 'package:nutricasa/telas/receita_tela.dart';

void main() {
  testarTimer();
  testWidgets(
    'fluxo completo num celular pequeno: login → despensa → cardápio → receita',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view
        ..physicalSize = const Size(360, 740)
        ..devicePixelRatio = 1
        // Barra de status em cima e os botões voltar/home/recentes do Android embaixo.
        ..padding = const FakeViewPadding(
          top: barraStatus,
          bottom: botoesAndroid,
        );
      addTearDown(tester.view.reset);

      await tester.runAsync(dados.carregarAlimentos);
      dados.atrasoFalso = const Duration(milliseconds: 10);
      await tester.pumpWidget(const NutriCasaApp());

      // Login: valida e-mail e entra.
      foraDasBarras(tester, find.text('NutriCasa'));
      foraDasBarras(tester, find.text('Entrar no NutriCasa'));
      await tester.tap(find.text('Entrar no NutriCasa'));
      await tester.pump();
      expect(find.text('Digite um e-mail válido'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'ana@exemplo.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Entrar no NutriCasa'));
      await tester.pumpAndSettle();

      // Despensa vazia → busca "ovo" → adiciona com quantidade.
      expect(find.text('Sua despensa está vazia'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).first,
        'ovo galinha inteiro cru',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ovo, de galinha, inteiro, cru').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '6 un');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('6 un', findRichText: true), findsOneWidget);
      expect(find.text('1 alimento'), findsOneWidget);
      expect(find.text('Ovos'), findsNWidgets(2)); // filtro + título do grupo
      expect(find.textContaining('Ovo', findRichText: true), findsWidgets);
      foraDasBarras(tester, find.text('Minha despensa'));
      foraDasBarras(tester, find.text('Gerar cardápio'));
      foraDasBarras(tester, aba('Perfil'));

      // Gerar cardápio.
      await tester.tap(find.text('Gerar cardápio'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 5));
      expect(
        find.text('Criando receitas com seus ingredientes…'),
        findsOneWidget,
      );
      foraDasBarras(tester, find.text('CHEF IA EM AÇÃO'));
      foraDasBarras(tester, find.byType(LinearProgressIndicator));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Seu cardápio'), findsOneWidget);
      expect(find.text('Omelete de tomate com queijo minas'), findsOneWidget);
      await rolarAteOFim(tester, CardapioTela);
      expect(find.text('Panqueca rápida de banana e aveia'), findsOneWidget);
      foraDasBarras(tester, find.textContaining('Gerar outras opções'));
      await tester.drag(rolagem(CardapioTela), const Offset(0, 10000));
      await tester.pumpAndSettle();

      // Abrir receita, favoritar e avaliar.
      await tester.tap(find.text('Omelete de tomate com queijo minas'));
      await tester.pumpAndSettle();
      expect(find.text('Tabela nutricional'), findsOneWidget);
      expect(find.text('2 ovos'), findsOneWidget);
      await tester.tap(find.byTooltip('Mais porções'));
      await tester.pump();
      expect(find.text('2 porções'), findsOneWidget);
      expect(find.text('4 ovos'), findsOneWidget);
      await tester.tap(find.byTooltip('Menos porções'));
      await tester.pump();

      // Modo cozinhar: ingredientes → passos → voltar → sair.
      await tester.tap(find.text('Começar a cozinhar'));
      await tester.pumpAndSettle();
      expect(find.text('Separe os ingredientes'), findsOneWidget);
      foraDasBarras(tester, find.text('Começar'));
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      expect(find.text('Passo 1 de 4'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Próximo passo'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Terminei!'), findsOneWidget);
      await tester.tap(find.byTooltip('Passo anterior'));
      await tester.pumpAndSettle();
      expect(find.text('Passo 3 de 4'), findsOneWidget);
      await tester.tap(find.text('Próximo passo'));
      await tester.pumpAndSettle();

      // Terminei! → painel Cozinhei: 6 ovos − 2 = 4.
      await tester.tap(find.text('Terminei!'));
      await tester.pumpAndSettle();
      expect(find.text('Cozinhou? Que delícia! 🎉'), findsOneWidget);
      expect(find.text('4 un'), findsOneWidget);
      foraDasBarras(tester, find.text('Atualizar despensa'));
      await tester.tap(find.text('Atualizar despensa'));
      await tester.pumpAndSettle();
      expect(dados.despensa.single.quantidade, '4 un');
      expect(dados.cozinhados.length, 1);
      expect(find.text('Tabela nutricional'), findsOneWidget);
      await mostrar(tester, 'Salvar nos favoritos', ReceitaTela);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar nos favoritos'));
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      expect(dados.receitas.first.favorita, isTrue);
      expect(dados.receitas.first.feedback, 1);
      await rolarAteOFim(tester, ReceitaTela);
      foraDasBarras(
        tester,
        find.textContaining('Valores nutricionais estimados'),
      );

      // Voltar e conferir as outras abas.
      await voltar(tester);
      await tester.pumpAndSettle();
      await voltar(tester);
      await tester.pumpAndSettle();
      await tester.tap(aba('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('1 salva'), findsOneWidget);
      await tester.tap(aba('Cardápios'));
      await tester.pumpAndSettle();
      expect(find.text('HOJE'), findsOneWidget);
      await tester.tap(aba('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('1 / $limiteDiario usados'), findsOneWidget);

      // Sair volta para o login.
      await rolarAteOFim(tester, PerfilTela);
      foraDasBarras(tester, find.text('Sair da conta'));
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.text('Entrar no NutriCasa'), findsOneWidget);
    },
  );
}

void testarTimer() {
  testWidgets('modo cozinhar: timer do passo avisa quando acaba', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.runAsync(dados.carregarAlimentos);
    final receita = Receita(
      id: 't',
      titulo: 'Panqueca',
      tipo: 'lanche',
      tempoMin: 10,
      porcoes: 1,
      dificuldade: 'Fácil',
      criadaEm: DateTime(2026),
      ingredientes: [Ingrediente(dados.alimento(489), 50, '1 ovo')],
      passos: const ['Doure 2 minutos de cada lado.'],
    );
    await tester.pumpWidget(MaterialApp(home: CozinharTela(receita)));
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar timer de 2 min'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('01:59'), findsOneWidget);
    await tester.pump(const Duration(minutes: 2));
    await tester.pump();
    expect(find.text('⏰ Tempo do passo 1 acabou!'), findsOneWidget);
  });
}

const alturaTela = 740.0;
const barraStatus = 24.0;
const botoesAndroid = 48.0;

/// Falha se o widget ficar atrás da barra de status ou dos botões do Android.
void foraDasBarras(WidgetTester tester, Finder alvo) {
  final r = tester.getRect(alvo.first);
  expect(
    r.top,
    greaterThanOrEqualTo(barraStatus),
    reason: '$alvo atrás da barra de status',
  );
  expect(
    r.bottom,
    lessThanOrEqualTo(alturaTela - botoesAndroid),
    reason: '$alvo atrás dos botões do Android',
  );
}

Finder rolagem(Type tela) => find
    .descendant(of: find.byType(tela), matching: find.byType(Scrollable))
    .first;

Future<void> rolarAteOFim(WidgetTester tester, Type tela) async {
  await tester.drag(rolagem(tela), const Offset(0, -10000));
  await tester.pumpAndSettle();
}

/// Rola a tela até o texto ser construído e depois o traz para a área visível.
Future<void> mostrar(WidgetTester tester, String texto, Type tela) async {
  final alvo = find.text(texto);
  await tester.scrollUntilVisible(alvo, 200, scrollable: rolagem(tela));
  await tester.ensureVisible(alvo);
}

Finder aba(String nome) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(nome));

/// Volta uma tela (os botões de voltar do app são personalizados).
Future<void> voltar(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pop();
}
