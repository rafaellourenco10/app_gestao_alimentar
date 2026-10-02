import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'avisos.dart';
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
  await iniciarAvisos();

  // Relatório de erros: só liga com a chave (flutter run --dart-define=SENTRY_DSN=...).
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isEmpty) return runApp(const NutriCasaApp());
  await SentryFlutter.init(
    (o) => o
      ..dsn = dsn
      ..sendDefaultPii =
          false // nunca envia e-mail ou dados pessoais
      ..environment = kReleaseMode ? 'producao' : 'desenvolvimento',
    appRunner: () => runApp(const NutriCasaApp()),
  );
}

class NutriCasaApp extends StatelessWidget {
  const NutriCasaApp({super.key});

  static final _claro = criarTema();
  static final _escuro = criarTema(escuro: true);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) => MaterialApp(
        title: 'NutriCasa',
        debugShowCheckedModeBanner: false,
        theme: _claro,
        darkTheme: _escuro,
        themeMode: dados.tema,
        // As cores dos widgets (Cores.*) seguem o tema que está valendo.
        builder: (context, filho) {
          Cores.escuro = Theme.of(context).brightness == Brightness.dark;
          return filho!;
        },
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: ListenableBuilder(
          listenable: dados,
          builder: (context, _) => dados.email == null
              ? const LoginTela()
              : !dados.boasVindasVistas
              ? const BoasVindasTela()
              : const Inicio(),
        ),
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
  @override
  void initState() {
    super.initState();
    abaAtual.value = 0;
  }

  static const _titulos = ['Despensa', 'Cardápios', 'Favoritos', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: abaAtual,
      builder: (context, aba, _) => Scaffold(
        appBar: Topo(
          _titulos[aba],
          acoes: [
            ListenableBuilder(
              listenable: dados,
              builder: (context, _) {
                final n = dados.compras.where((c) => !c.comprado).length;
                return IconButton(
                  tooltip: 'Lista de compras',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ComprasTela(),
                    ),
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
          index: aba,
          children: const [
            DespensaTela(),
            HistoricoTela(),
            FavoritosTela(),
            PerfilTela(),
          ],
        ),
        bottomNavigationBar: const BarraAbas(),
      ),
    );
  }
}
