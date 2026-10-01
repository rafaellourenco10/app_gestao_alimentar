import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

/// Mostra a prévia do cartão da receita e compartilha como imagem (WhatsApp etc.).
Future<void> compartilharReceita(
  BuildContext context,
  Receita receita, {
  double fator = 1,
}) => showDialog<void>(
  context: context,
  builder: (_) => _Compartilhar(receita, fator),
);

class _Compartilhar extends StatefulWidget {
  const _Compartilhar(this.receita, this.fator);

  final Receita receita;
  final double fator;

  @override
  State<_Compartilhar> createState() => _CompartilharState();
}

class _CompartilharState extends State<_Compartilhar> {
  final _cartao = GlobalKey();
  bool _enviando = false;

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      final limite =
          _cartao.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final imagem = await limite.toImage(pixelRatio: 3);
      final png = await imagem.toByteData(format: ui.ImageByteFormat.png);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              png!.buffer.asUint8List(),
              mimeType: 'image/png',
              name: 'receita-nutricasa.png',
            ),
          ],
          text: '${widget.receita.titulo} — receita do NutriCasa 💚',
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Cores.fundo,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: RepaintBoundary(
                key: _cartao,
                child: CartaoReceita(widget.receita, fator: widget.fator),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotaoPrincipal(
                    texto: _enviando ? 'Preparando…' : 'Compartilhar',
                    icone: Icons.share,
                    onPressed: _enviando ? null : _enviar,
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

/// O cartão que vira imagem: foto/ilustração, título, números, ingredientes e passos.
class CartaoReceita extends StatelessWidget {
  const CartaoReceita(this.receita, {super.key, this.fator = 1});

  final Receita receita;
  final double fator;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final porcoes = (receita.porcoes * fator).round();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ImagemReceita(receita, altura: 150),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo.png', width: 20, height: 20),
                      const SizedBox(width: 4),
                      Text(
                        'NutriCasa',
                        style: textos.labelMedium?.copyWith(
                          color: Cores.primaria,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receita.titulo, style: textos.titleLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    pilulaKcal(receita.kcal),
                    Pilula(
                      '${receita.tempoMin} min',
                      icone: Icons.schedule,
                      fundo: Cores.superficieBaixa,
                    ),
                    Pilula(
                      '$porcoes ${porcoes == 1 ? 'porção' : 'porções'}',
                      icone: Icons.restaurant,
                      fundo: Cores.superficieBaixa,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Ingredientes', style: textos.titleMedium),
                const SizedBox(height: 6),
                for (final i in receita.ingredientes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${emojiDe(i.alimento)}  ${escalarMedida(i.medida, fator)}',
                      style: textos.bodyMedium,
                    ),
                  ),
                const SizedBox(height: 12),
                Text('Modo de preparo', style: textos.titleMedium),
                const SizedBox(height: 6),
                for (final (n, passo) in receita.passos.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${n + 1}. $passo',
                      style: textos.bodyMedium?.copyWith(
                        color: Cores.textoSuave,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${receita.kcal.round()} kcal por porção (Tabela TACO) · '
                  'feito com o app NutriCasa 💚',
                  style: textos.bodySmall?.copyWith(color: Cores.contorno),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
