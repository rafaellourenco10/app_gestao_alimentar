import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

/// Passo a passo em tela cheia, com a tela sempre acesa e timer por etapa.
/// Devolve `true` quando o usuário toca em "Terminei!".
class CozinharTela extends StatefulWidget {
  const CozinharTela(this.receita, {super.key, this.fator = 1});

  final Receita receita;

  /// Multiplicador das quantidades (porções escolhidas ÷ porções da receita).
  final double fator;

  @override
  State<CozinharTela> createState() => _CozinharTelaState();
}

class _CozinharTelaState extends State<CozinharTela> {
  final _paginas = PageController();
  final _separados = <int>{};
  int _pagina = 0;

  // Timer: um por vez, preso ao passo que o iniciou.
  Timer? _tique;
  int? _passoDoTimer;
  Duration _restante = Duration.zero;
  bool _pausado = false;

  int get _total =>
      widget.receita.passos.length + 1; // +1: separar ingredientes

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
  }

  @override
  void dispose() {
    _tique?.cancel();
    _paginas.dispose();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  void _iniciarTimer(int passo, int minutos) {
    _tique?.cancel();
    setState(() {
      _passoDoTimer = passo;
      _restante = Duration(minutes: minutos);
      _pausado = false;
    });
    _tique = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausado) return;
      setState(() => _restante -= const Duration(seconds: 1));
      if (_restante > Duration.zero) return;
      _tique?.cancel();
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⏰ Tempo do passo ${passo + 1} acabou!')),
      );
      setState(() => _passoDoTimer = null);
    });
  }

  void _pararTimer() {
    _tique?.cancel();
    setState(() => _passoDoTimer = null);
  }

  void _ir(int pagina) => _paginas.animateToPage(
    pagina,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final ultimo = _pagina == _total - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Sair do modo cozinhar',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.receita.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: textos.titleMedium,
                    ),
                  ),
                  Pilula(
                    _pagina == 0
                        ? 'Preparação'
                        : 'Passo $_pagina de ${_total - 1}',
                    fundo: Cores.verdeNav,
                    cor: Cores.primaria,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  for (var i = 0; i < _total; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _pagina ? Cores.verde : Cores.superficie,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                onPageChanged: (p) => setState(() => _pagina = p),
                children: [
                  _ingredientes(textos),
                  for (final (i, passo) in widget.receita.passos.indexed)
                    _passo(textos, i, passo),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_pagina > 0) ...[
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: IconButton.filledTonal(
                        tooltip: 'Passo anterior',
                        style: IconButton.styleFrom(
                          backgroundColor: Cores.superficieBaixa,
                        ),
                        onPressed: () => _ir(_pagina - 1),
                        icon: Icon(Icons.arrow_back, color: Cores.texto),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: BotaoPrincipal(
                      texto: ultimo
                          ? 'Terminei!'
                          : _pagina == 0
                          ? 'Começar'
                          : 'Próximo passo',
                      icone: ultimo ? Icons.celebration : Icons.arrow_forward,
                      onPressed: ultimo
                          ? () => Navigator.pop(context, true)
                          : () => _ir(_pagina + 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ingredientes(TextTheme textos) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Separe os ingredientes', style: textos.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Toque em cada um conforme for separando.',
          style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
        ),
        const SizedBox(height: 16),
        for (final (i, ing) in widget.receita.ingredientes.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: _separados.contains(i) ? Cores.verdeNav : Cores.branco,
              borderRadius: BorderRadius.circular(12),
              elevation: 0.5,
              shadowColor: const Color(0x22000000),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(
                  () => _separados.contains(i)
                      ? _separados.remove(i)
                      : _separados.add(i),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(
                        emojiDe(ing.alimento),
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          escalarMedida(ing.medida, widget.fator),
                          style: textos.bodyLarge?.copyWith(
                            decoration: _separados.contains(i)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Icon(
                        _separados.contains(i)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Cores.verde,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _passo(TextTheme textos, int i, String passo) {
    final minutos = minutosNoPasso(passo);
    final ativo = _passoDoTimer == i;
    final mm = _restante.inMinutes.toString().padLeft(2, '0');
    final ss = (_restante.inSeconds % 60).toString().padLeft(2, '0');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Cores.verde,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${i + 1}',
              style: textos.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            passo,
            style: textos.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (minutos != null) ...[
            const SizedBox(height: 32),
            Cartao(
              raio: 16,
              sombra: Sombras.card,
              child: ativo
                  ? Row(
                      children: [
                        Icon(Icons.timer, color: Cores.laranja, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$mm:$ss',
                            style: textos.headlineMedium?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _pausado ? 'Continuar' : 'Pausar',
                          onPressed: () => setState(() => _pausado = !_pausado),
                          icon: Icon(_pausado ? Icons.play_arrow : Icons.pause),
                        ),
                        IconButton(
                          tooltip: 'Parar timer',
                          onPressed: _pararTimer,
                          icon: const Icon(Icons.stop),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () => _iniciarTimer(i, minutos),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Cores.laranja,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Iniciar timer de $minutos min',
                              style: textos.titleMedium,
                            ),
                          ),
                          Icon(Icons.play_circle, color: Cores.laranja),
                        ],
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
