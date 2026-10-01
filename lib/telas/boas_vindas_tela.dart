import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

/// Três telas curtas na primeira abertura do app.
class BoasVindasTela extends StatefulWidget {
  const BoasVindasTela({super.key});

  @override
  State<BoasVindasTela> createState() => _BoasVindasTelaState();
}

class _BoasVindasTelaState extends State<BoasVindasTela> {
  final _paginas = PageController();
  int _pagina = 0;

  static const _conteudo = [
    (
      ['🥚', '🍅', '🥕'],
      'Cozinhe com o que você já tem',
      'Cadastre os alimentos da sua casa — digitando ou falando — e o '
          'NutriCasa cuida do resto.',
    ),
    (
      ['✨', '🍳', '🥗'],
      'Cardápios criados pela IA',
      'Receitas práticas com os seus ingredientes, com calorias e macros '
          'calculados pela Tabela TACO.',
    ),
    (
      ['⏱️', '🛒', '💚'],
      'Sem desperdício',
      'Modo cozinhar passo a passo, lista de compras e aviso do que está '
          'perto de vencer.',
    ),
  ];

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final ultima = _pagina == _conteudo.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 32, width: 32),
                  const SizedBox(width: 8),
                  Text(
                    'NutriCasa',
                    style: textos.titleMedium?.copyWith(color: Cores.primaria),
                  ),
                  const Spacer(),
                  if (!ultima)
                    TextButton(
                      onPressed: dados.concluirBoasVindas,
                      child: const Text('Pular'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                onPageChanged: (p) => setState(() => _pagina = p),
                children: [
                  for (final (emojis, titulo, texto) in _conteudo)
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _ilustracao(emojis),
                          const SizedBox(height: 40),
                          Text(
                            titulo,
                            textAlign: TextAlign.center,
                            style: textos.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            texto,
                            textAlign: TextAlign.center,
                            style: textos.bodyLarge?.copyWith(
                              color: Cores.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _conteudo.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _pagina ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _pagina ? Cores.verde : Cores.superficieAlta,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: BotaoPrincipal(
                texto: ultima ? 'Começar' : 'Próximo',
                icone: ultima ? Icons.check : Icons.arrow_forward,
                onPressed: ultima
                    ? dados.concluirBoasVindas
                    : () => _paginas.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ilustracao(List<String> emojis) {
    return SizedBox(
      width: 240,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Cores.verdeNav, Cores.fundo.withValues(alpha: 0)],
              ),
            ),
          ),
          for (final (i, e) in emojis.indexed)
            Align(
              alignment: const [
                Alignment(-0.85, 0.5),
                Alignment(0, -0.55),
                Alignment(0.85, 0.5),
              ][i],
              child: Container(
                width: i == 1 ? 104 : 76,
                height: i == 1 ? 104 : 76,
                decoration: const BoxDecoration(
                  color: Cores.branco,
                  shape: BoxShape.circle,
                  boxShadow: Sombras.card,
                ),
                alignment: Alignment.center,
                child: Text(e, style: TextStyle(fontSize: i == 1 ? 52 : 36)),
              ),
            ),
        ],
      ),
    );
  }
}
