import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutricasa/telas/privacidade_tela.dart';

void main() {
  testWidgets('política de privacidade mostra as seções do arquivo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacidadeTela()));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Quem é o responsável'), findsOneWidget);
    expect(find.textContaining('LGPD'), findsWidgets);
  });
}
