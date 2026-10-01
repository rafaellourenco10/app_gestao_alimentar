import 'dart:math';

import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'cardapio_tela.dart';

const _dicas = [
  'Guarde as folhas verdes enroladas em papel-toalha: elas duram até o dobro na geladeira.',
  'Talos de brócolis e couve também vão bem em refogados e sopas — nada se perde.',
  'Banana bem madura é ótima para panquecas, bolos e vitaminas.',
  'Congele arroz e feijão em porções: é só esquentar nos dias corridos.',
];

class GerandoTela extends StatefulWidget {
  const GerandoTela({super.key});

  @override
  State<GerandoTela> createState() => _GerandoTelaState();
}

class _GerandoTelaState extends State<GerandoTela>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  final _dica = _dicas[Random().nextInt(_dicas.length)];
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _gerar();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _gerar() async {
    setState(() => _erro = null);
    try {
      final receitas = await dados.gerarCardapio();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => CardapioTela(receitas)),
      );
    } catch (e) {
      if (mounted) setState(() => _erro = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // Rolável para caber em telas pequenas sem cortar embaixo.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: switch (_erro) {
              null => _carregando(context),
              LimiteAtingido() => Aviso(
                icone: Icons.schedule,
                titulo: 'Você atingiu o limite de hoje',
                texto:
                    'São $limiteDiario cardápios por dia. '
                    'Volte amanhã para gerar novas receitas!',
                acao: 'Voltar',
                onAcao: () => Navigator.pop(context),
              ),
              DespensaVazia() => Aviso(
                icone: Icons.kitchen_outlined,
                titulo: 'Sua despensa está vazia',
                texto: 'Adicione alguns alimentos antes de gerar o cardápio.',
                acao: 'Voltar',
                onAcao: () => Navigator.pop(context),
              ),
              _ => Aviso(
                icone: Icons.wifi_off,
                titulo: 'Não foi possível gerar o cardápio',
                texto:
                    'Verifique sua conexão com a internet e tente novamente.',
                acao: 'Tentar novamente',
                onAcao: _gerar,
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _carregando(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final n = dados.despensa.length;
    final emojis = dados.despensa
        .map((i) => emojiDe(i.alimento))
        .toSet()
        .take(4)
        .toList();
    const posicoes = [
      Offset(-110, -70),
      Offset(105, -60),
      Offset(-100, 70),
      Offset(110, 75),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Pilula(
            'CHEF IA EM AÇÃO',
            icone: Icons.circle,
            fundo: Cores.verdeNav,
            cor: Cores.primaria,
            corIcone: Cores.verde,
          ),
          SizedBox(
            height: 260,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final t = _anim.value * 2 * pi;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Cores.verdeNav.withValues(alpha: 0.7),
                            Cores.fundo.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    for (final (i, e) in emojis.indexed)
                      Transform.translate(
                        offset: posicoes[i] + Offset(0, 6 * sin(t + i * 1.6)),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Cores.branco,
                            shape: BoxShape.circle,
                            boxShadow: Sombras.card,
                          ),
                          alignment: Alignment.center,
                          child: Text(e, style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                    Transform.scale(
                      scale: 1 + 0.05 * sin(t),
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: const BoxDecoration(
                          color: Cores.branco,
                          shape: BoxShape.circle,
                          boxShadow: Sombras.media,
                        ),
                        child: const Icon(
                          Icons.soup_kitchen_outlined,
                          size: 52,
                          color: Cores.verde,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Text(
            'Criando receitas com seus ingredientes…',
            textAlign: TextAlign.center,
            style: textos.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Analisando ${n == 1 ? '1 alimento' : '$n alimentos'} da sua despensa para '
            'sugerir refeições práticas e saborosas.',
            textAlign: TextAlign.center,
            style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              minHeight: 8,
              color: Cores.laranja,
              backgroundColor: Cores.superficie,
            ),
          ),
          const SizedBox(height: 24),
          Cartao(
            cor: Cores.superficieBaixa,
            sombra: Sombras.leve,
            raio: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Cores.laranjaFixo,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 22,
                    color: Cores.noLaranjaFixo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'DICA DO CHEF',
                            style: textos.labelMedium?.copyWith(
                              color: Cores.laranjaTexto,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Pilula(
                            'Zero desperdício',
                            fundo: Cores.verdeFixo,
                            cor: Cores.noVerdeFixo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(_dica, style: textos.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
