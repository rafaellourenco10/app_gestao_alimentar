import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';

/// Simula o botão "voltar" do Android.
Future<void> voltarDoSistema(WidgetTester tester) async {
  final msg = const JSONMethodCodec().encodeMethodCall(
    const MethodCall('popRoute'),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    msg,
    (_) {},
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'sugestões fecham ao tocar fora e com o voltar, sem sair da tela',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.runAsync(dados.carregarAlimentos);
      dados
        ..boasVindasVistas = true
        ..despensa.clear()
        ..compras.clear();
      await dados.entrar('ana@exemplo.com', '123456');
      await tester.pumpWidget(const NutriCasaApp());
      await tester.pumpAndSettle();
      const sugestoes = 'SUGESTÕES RÁPIDAS';

      // Despensa: tocar fora fecha.
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text(sugestoes), findsOneWidget);
      await tester.tap(find.text('Minha despensa'));
      await tester.pumpAndSettle();
      expect(find.text(sugestoes), findsNothing);

      // Despensa: voltar fecha as sugestões e continua no app.
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await voltarDoSistema(tester);
      expect(find.text(sugestoes), findsNothing);
      expect(find.text('Minha despensa'), findsOneWidget);

      // Tocar numa sugestão continua funcionando.
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ovo').first);
      await tester.pumpAndSettle();
      expect(find.text('Quantidade (opcional)'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Lista de compras: voltar com sugestões abertas fica na lista.
      await tester.tap(find.byTooltip('Lista de compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text(sugestoes), findsOneWidget);
      await voltarDoSistema(tester);
      expect(find.text(sugestoes), findsNothing);
      expect(find.text('PARA COMPRAR'), findsOneWidget);

      // Segundo voltar (sem sugestões) volta para a despensa.
      await voltarDoSistema(tester);
      expect(find.text('Minha despensa'), findsOneWidget);
    },
  );

  testWidgets('alimento que não está na TACO pode ser cadastrado', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.runAsync(dados.carregarAlimentos);
    dados
      ..boasVindasVistas = true
      ..despensa.clear();
    await dados.entrar('ana@exemplo.com', '123456');
    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kefir de coco');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar “Kefir de coco”'));
    await tester.pumpAndSettle();
    expect(find.text('Alimento novo'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '60');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Segue o fluxo normal: pede a quantidade e entra na despensa.
    expect(find.text('Quantidade (opcional)'), findsOneWidget);
    await tester.tap(find.text('Adicionar').last);
    await tester.pumpAndSettle();
    final item = dados.despensa.single.alimento;
    expect(
      (item.nome, item.categoria, item.kcal),
      ('Kefir de coco', 'Outros', 60),
    );
  });
}
