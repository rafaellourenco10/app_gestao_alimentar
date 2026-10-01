import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('boas-vindas aparecem uma vez e ficam salvas', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(dados.carregarAlimentos);
    await dados.carregarPreferencias();
    await dados.sair();
    expect(dados.boasVindasVistas, isFalse);

    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();
    // Primeiro o login, depois a introdução.
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@exemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar no NutriCasa'));
    await tester.pumpAndSettle();
    expect(find.text('Cozinhe com o que você já tem'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Cardápios criados pela IA'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Pular'), findsNothing);
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.text('Despensa'), findsWidgets);

    // Na próxima abertura, não aparecem de novo.
    await dados.carregarPreferencias();
    expect(dados.boasVindasVistas, isTrue);
  });
}
