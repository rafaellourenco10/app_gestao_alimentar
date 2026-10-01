import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/telas/plano_tela.dart';

void main() {
  testWidgets('plano da semana: escolhe receitas e manda o que falta à lista', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(dados.carregarAlimentos);
    dados
      ..atrasoFalso = Duration.zero
      ..despensa.clear()
      ..compras.clear()
      ..plano.clear();
    await dados.adicionarItem(dados.alimento(489), null); // ovo
    final rs = (await tester.runAsync(dados.gerarCardapio))!;

    await tester.pumpWidget(const MaterialApp(home: PlanoTela()));
    await tester.tap(find.text('Segunda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rs[0].titulo).last); // omelete
    await tester.pumpAndSettle();
    expect(dados.plano[0], rs[0]);

    // Omelete e panqueca pedem ovo (tem); tomate etc. entram uma vez só.
    await dados.planejar(1, rs[2]);
    await dados.planejar(2, rs[0]);
    final n = await dados.adicionarFaltandoDoPlano();
    final esperado = {
      for (final r in [rs[0], rs[2]])
        for (final i in dados.faltando(r)) i.alimento.id,
    };
    expect(n, esperado.length);
    expect(dados.compras.map((c) => c.alimento.id).toSet(), esperado);
    expect(esperado, isNot(contains(489)));
  });
}
