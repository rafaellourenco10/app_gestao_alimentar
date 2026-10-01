import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricasa/dados.dart';
import 'package:nutricasa/main.dart';
import 'package:nutricasa/tema.dart';
import 'package:nutricasa/telas/perfil_tela.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('modo escuro: troca no perfil, fica salvo e as abas abrem', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'boasVindas': true});
    await tester.runAsync(dados.carregarAlimentos);
    await dados.carregarPreferencias();
    await dados.entrar('ana@exemplo.com', '123456');
    await dados.adicionarItem(dados.alimento(489), '6 un');

    await tester.pumpWidget(const NutriCasaApp());
    await tester.pumpAndSettle();
    expect(Cores.escuro, isFalse);

    final abas = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: abas, matching: find.text('Perfil')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Escuro'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(PerfilTela),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    expect(Cores.escuro, isTrue);
    expect(Cores.fundo, paletaEscura.fundo);

    for (final aba in ['Despensa', 'Cardápios', 'Favoritos', 'Perfil']) {
      await tester.tap(find.descendant(of: abas, matching: find.text(aba)));
      await tester.pumpAndSettle();
    }

    // Preferência salva para a próxima abertura.
    dados.tema = ThemeMode.system;
    await dados.carregarPreferencias();
    expect(dados.tema, ThemeMode.dark);
    await dados.definirTema(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(Cores.escuro, isFalse);
  });
}
