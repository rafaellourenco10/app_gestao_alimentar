import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';
import 'package:nutricasa/telas/cardapio_tela.dart';
import 'package:nutricasa/telas/perfil_tela.dart';
import 'package:nutricasa/telas/receita_tela.dart';
import 'package:nutricasa/widgets.dart';

void main() {
  testWidgets('fluxo completo num celular pequeno: login → despensa → cardápio → receita',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.runAsync(dados.carregarAlimentos);
    dados.atrasoFalso = const Duration(milliseconds: 10);
    await tester.pumpWidget(const NutriCasaApp());

    // Login: valida e-mail e entra.
    await tester.tap(find.text('Entrar no NutriCasa'));
    await tester.pump();
    expect(find.text('Digite um e-mail válido'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@exemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar no NutriCasa'));
    await tester.pumpAndSettle();

    // Despensa vazia → busca "ovo" → adiciona com quantidade.
    expect(find.text('Sua despensa está vazia'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'ovo galinha inteiro cru');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ovo, de galinha, inteiro, cru').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '6 un');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('6 un'), findsOneWidget);
    expect(find.text('1 alimento'), findsOneWidget);
    expect(find.text('Ovos'), findsNothing); // cabeçalho do grupo leva emoji
    expect(find.textContaining('Ovos'), findsOneWidget);

    // Gerar cardápio.
    await tester.tap(find.text('Gerar cardápio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5));
    expect(find.text('Criando receitas com seus ingredientes…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(find.text('Seu cardápio'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(CardapioTela), matching: find.byType(ReceitaCard, skipOffstage: false)),
        findsNWidgets(3));

    // Abrir receita, favoritar e avaliar.
    await tester.tap(find.text('Omelete de tomate com queijo minas'));
    await tester.pumpAndSettle();
    expect(find.text('Tabela nutricional'), findsOneWidget);
    await mostrar(tester, 'Salvar nos favoritos', ReceitaTela);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar nos favoritos'));
    await tester.tap(find.text('👍  Sim'));
    await tester.pumpAndSettle();
    expect(dados.receitas.first.favorita, isTrue);
    expect(dados.receitas.first.feedback, 1);

    // Voltar e conferir as outras abas.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos').last);
    await tester.pumpAndSettle();
    expect(find.text('1 salva'), findsOneWidget);
    await tester.tap(find.text('Cardápios'));
    await tester.pumpAndSettle();
    expect(find.text('HOJE'), findsOneWidget);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('1 / $limiteDiario usados'), findsOneWidget);

    // Sair volta para o login.
    await mostrar(tester, 'Sair da conta', PerfilTela);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    expect(find.text('Entrar no NutriCasa'), findsOneWidget);
  });
}

/// Rola a tela até o texto ser construído e depois o traz para a área visível.
Future<void> mostrar(WidgetTester tester, String texto, Type tela) async {
  final alvo = find.text(texto);
  await tester.scrollUntilVisible(alvo, 200,
      scrollable: find.descendant(of: find.byType(tela), matching: find.byType(Scrollable)).first);
  await tester.ensureVisible(alvo);
}
