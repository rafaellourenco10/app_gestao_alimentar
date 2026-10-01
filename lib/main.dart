import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dados.dart';
import 'tema.dart';
import 'telas/boas_vindas_tela.dart';
import 'telas/compras_tela.dart';
import 'telas/despensa_tela.dart';
import 'telas/favoritos_tela.dart';
import 'telas/historico_tela.dart';
import 'telas/login_tela.dart';
import 'telas/perfil_tela.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Só retrato: deitado, os botões do Android vão para a lateral e cobririam o conteúdo.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dados.carregarAlimentos();
  await dados.carregarPreferencias();
  runApp(const NutriCasaApp());
}

class NutriCasaApp extends StatelessWidget {
  const NutriCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCasa',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: ListenableBuilder(
        listenable: dados,
        builder: (context, _) => !dados.boasVindasVistas
            ? const BoasVindasTela()
            : dados.email == null
            ? const LoginTela()
            : const Inicio(),
      ),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _aba = 0;

  static const _titulos = ['Despensa', 'Cardápios', 'Favoritos', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: Topo(
        _titulos[_aba],
        acoes: [
          ListenableBuilder(
            listenable: dados,
            builder: (context, _) {
              final n = dados.compras.where((c) => !c.comprado).length;
              return IconButton(
                tooltip: 'Lista de compras',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ComprasTela()),
                ),
                icon: Badge(
                  isLabelVisible: n > 0,
                  label: Text('$n'),
                  backgroundColor: Cores.laranja,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _aba,
        children: const [
          DespensaTela(),
          HistoricoTela(),
          FavoritosTela(),
          PerfilTela(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: Sombras.nav,
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 64,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Cores.verdeNav,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => textos.labelSmall?.copyWith(
                color: s.contains(WidgetState.selected)
                    ? Cores.verde
                    : Cores.textoSuave,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (s) => IconThemeData(
                size: 24,
                color: s.contains(WidgetState.selected)
                    ? Cores.verde
                    : Cores.textoSuave,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _aba,
            onDestinationSelected: (i) => setState(() => _aba = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.kitchen_outlined),
                selectedIcon: Icon(Icons.kitchen),
                label: 'Despensa',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Cardápios',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
