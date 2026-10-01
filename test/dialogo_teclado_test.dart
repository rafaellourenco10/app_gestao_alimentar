import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';

void main() {
  testWidgets('diálogo de quantidade não estoura com o teclado aberto', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Celular pequeno com teclado (~45% da tela), como no print do usuário.
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.runAsync(dados.carregarAlimentos);
    dados
      ..boasVindasVistas = true
      ..despensa.clear();
    await dados.entrar('ana@exemplo.com', '123456');
    await dados.adicionarItem(dados.alimento(489), '1 un');
    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Ovo', findRichText: true).last);
    await tester.pumpAndSettle();
    expect(find.text('Quantidade (opcional)'), findsOneWidget);
    // O teclado sobe (o campo tem autofocus).
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    await tester.pumpAndSettle();
    // O campo de validade continua alcançável rolando o diálogo.
    await tester.ensureVisible(find.text('Validade (opcional)'));
    await tester.pumpAndSettle();
    expect(find.text('Salvar'), findsOneWidget);
  });
}
