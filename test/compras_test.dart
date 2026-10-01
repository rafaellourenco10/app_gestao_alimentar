import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/tema.dart';
import 'package:nutricasa/telas/receita_tela.dart';

void main() {
  testWidgets(
    'receita → o que falta vai para a lista → comprado vai para a despensa',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view
        ..physicalSize = const Size(360, 740)
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(top: 24, bottom: 48);
      addTearDown(tester.view.reset);

      await tester.runAsync(dados.carregarAlimentos);
      dados
        ..despensa.clear()
        ..compras.clear();
      await dados.entrar('ana@exemplo.com', '123456');
      await dados.adicionarItem(dados.alimento(489), '6 un');
      final receita = Receita(
        id: 'omelete',
        titulo: 'Omelete de tomate',
        tipo: 'cafe_da_manha',
        tempoMin: 10,
        porcoes: 1,
        dificuldade: 'Fácil',
        criadaEm: DateTime(2026),
        ingredientes: [
          Ingrediente(dados.alimento(489), 100, '2 ovos'),
          Ingrediente(dados.alimento(157), 60, '½ tomate picado'),
          Ingrediente(dados.alimento(517), 1, 'Sal a gosto'),
        ],
        passos: const ['Bata e frite.'],
      );

      await tester.pumpWidget(
        MaterialApp(theme: criarTema(), home: ReceitaTela(receita)),
      );
      await tester.scrollUntilVisible(
        find.text('Adicionar o que falta à lista'),
        200,
      );
      await tester.ensureVisible(find.text('Adicionar o que falta à lista'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar o que falta à lista'));
      await tester.pumpAndSettle();
      expect(find.text('1 item na lista de compras'), findsOneWidget);
      expect(dados.compras.single.alimento.id, 157);

      await tester.tap(find.text('Ver lista'));
      await tester.pumpAndSettle();
      expect(find.text('A COMPRAR'), findsOneWidget);
      expect(find.text('½ tomate picado'), findsOneWidget);
      expect(find.byTooltip('Compartilhar lista'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.text('NO CARRINHO'), findsOneWidget);
      final botao = find.text('Guardar 1 item na despensa');
      expect(tester.getRect(botao).bottom, lessThanOrEqualTo(740 - 48));
      await tester.tap(botao);
      await tester.pumpAndSettle();
      expect(dados.temNaDespensa(157), isTrue);
      expect(dados.compras, isEmpty);
      expect(find.text('Sua lista está vazia'), findsOneWidget);
    },
  );
}
