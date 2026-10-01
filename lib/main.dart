import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dados.dart';
import 'tema.dart';
import 'telas/despensa_tela.dart';
import 'telas/favoritos_tela.dart';
import 'telas/historico_tela.dart';
import 'telas/login_tela.dart';
import 'telas/perfil_tela.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Só retrato: deitado, os botões do Android vão para a lateral e cobririam o conteúdo.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dados.carregarAlimentos();
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
      home: ListenableBuilder(
        listenable: dados,
        builder: (context, _) => dados.email == null ? const LoginTela() : const Inicio(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _aba,
          children: const [DespensaTela(), HistoricoTela(), FavoritosTela(), PerfilTela()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.kitchen_outlined), selectedIcon: Icon(Icons.kitchen), label: 'Despensa'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Cardápios'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
