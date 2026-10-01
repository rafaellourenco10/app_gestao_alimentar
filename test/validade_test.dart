import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/avisos.dart';
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
    dados.boasVindasVistas = true;
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

  test('aviso de validade: véspera às 9h, senão no dia, senão nada', () {
    final vence = DateTime(2026, 10, 5);
    expect(quandoAvisar(vence, DateTime(2026, 10, 1)), (
      DateTime(2026, 10, 4, 9),
      'vence amanhã',
    ));
    expect(quandoAvisar(vence, DateTime(2026, 10, 4, 10)), (
      DateTime(2026, 10, 5, 9),
      'vence hoje',
    ));
    expect(quandoAvisar(vence, DateTime(2026, 10, 5, 9, 1)), isNull);
    // virada de mês
    expect(
      quandoAvisar(DateTime(2026, 11, 1), DateTime(2026, 10, 30))?.$1,
      DateTime(2026, 10, 31, 9),
    );
  });

  test('despensa avisa quando a validade muda ou o item sai', () async {
    final d = Dados();
    await d.carregarAlimentos();
    final avisos = <(int, DateTime?)>[];
    d.aoMudarValidade = (a, v) => avisos.add((a.id, v));
    final v = DateTime(2026, 10, 5);
    await d.adicionarItem(d.alimento(157), null, validade: v);
    await d.removerItem(157);
    expect(avisos, [(157, v), (157, null)]);
  });
}
