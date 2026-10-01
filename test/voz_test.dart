import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';

void main() {
  testWidgets('microfone indisponível mostra aviso sem travar', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.runAsync(dados.carregarAlimentos);
    dados.boasVindasVistas = true;
    await dados.entrar('ana@exemplo.com', '123456');
    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ditar alimentos'));
    await tester.pumpAndSettle();
    expect(find.text('Fale os alimentos'), findsOneWidget);
    // Sem resposta do microfone em 5 s, o painel mostra o erro em vez de travar.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Ops!'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}
