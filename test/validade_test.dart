import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';

void main() {
  testWidgets('despensa mostra o que está vencendo', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.runAsync(dados.carregarAlimentos);
    dados
      ..agora = (() => DateTime(2026, 10, 1, 9))
      ..despensa.clear();
    await dados.entrar('ana@exemplo.com', '123456');
    await dados.adicionarItem(
      dados.alimento(157),
      '3 un',
      validade: DateTime(2026, 10, 2),
    );
    await dados.adicionarItem(
      dados.alimento(182),
      null,
      validade: DateTime(2026, 9, 29),
    );
    await dados.adicionarItem(
      dados.alimento(489),
      '6 un',
      validade: DateTime(2026, 11, 1),
    );

    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();

    expect(find.text('Use primeiro: 2 alimentos vencendo'), findsOneWidget);
    expect(find.text('Banana prata, Tomate'), findsOneWidget);
    expect(find.text('Vence amanhã'), findsOneWidget);
    expect(find.text('Vencido'), findsOneWidget);
    expect(find.textContaining('Vence em'), findsNothing); // ovo: falta muito

    // Abrir o item mostra a validade no diálogo.
    await tester.tap(find.textContaining('Tomate', findRichText: true).last);
    await tester.pumpAndSettle();
    expect(find.text('Vence em 02/10/2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Remover validade'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Vence amanhã'), findsNothing);
  });
}
