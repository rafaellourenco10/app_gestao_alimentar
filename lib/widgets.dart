import 'package:flutter/material.dart';

import 'dados.dart';
import 'tema.dart';
import 'telas/receita_tela.dart';

const emojiCategoria = {
  'Cereais e pães': '🍞',
  'Verduras e legumes': '🥕',
  'Frutas': '🍎',
  'Óleos e gorduras': '🫒',
  'Peixes e frutos do mar': '🐟',
  'Carnes': '🍗',
  'Leite e derivados': '🧀',
  'Bebidas': '🥤',
  'Ovos': '🥚',
  'Doces e açúcares': '🍯',
  'Diversos': '🧂',
  'Industrializados': '🥫',
  'Pratos prontos': '🍱',
  'Feijões e leguminosas': '🫘',
  'Nozes e sementes': '🥜',
};

const _tipos = {
  'cafe_da_manha': ('☕', 'Café da manhã', Color(0xFFFFF3E0)),
  'almoco_jantar': ('🍲', 'Almoço/Jantar', Color(0xFFE8F5E9)),
  'lanche': ('🥞', 'Lanche', Color(0xFFFBE9E7)),
};

(String, String, Color) tipoReceita(String tipo) =>
    _tipos[tipo] ?? ('🍽️', 'Receita', const Color(0xFFF1F1EB));

/// Pílula pequena (kcal, tempo, dificuldade).
class Selo extends StatelessWidget {
  const Selo(this.texto, {super.key, this.icone, this.fundo = Colors.white, this.cor = Cores.texto});

  final String texto;
  final IconData? icone;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 14, color: cor), const SizedBox(width: 4)],
          Text(texto,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

Selo seloKcal(double kcal) =>
    Selo('${kcal.round()} kcal', fundo: Cores.laranjaClaro, cor: Cores.laranjaTexto);

class ReceitaCard extends StatelessWidget {
  const ReceitaCard(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final (emoji, rotulo, corTipo) = tipoReceita(receita.tipo);
    final textos = Theme.of(context).textTheme;
    final nomes = receita.ingredientes
        .where((i) => !basicos.contains(i.alimento.id))
        .map((i) => i.alimento.nome.split(',').first)
        .toSet()
        .join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => ReceitaTela(receita))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              color: corTipo,
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),
                  Padding(
                    padding: const EdgeInsets.only(right: 52),
                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                      seloKcal(receita.kcal),
                      Selo('${receita.tempoMin} min', icone: Icons.schedule),
                      Selo(receita.dificuldade, icone: Icons.thumb_up_alt_outlined),
                    ]),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Selo(rotulo, fundo: Cores.verde, cor: Colors.white),
                  ),
                  Align(alignment: Alignment.topRight, child: BotaoFavorito(receita)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receita.titulo,
                      style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(nomes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.bodySmall?.copyWith(color: Cores.textoSuave)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Flexible(
                      child: Text('Ver receita completa',
                          overflow: TextOverflow.ellipsis,
                          style: textos.labelLarge
                              ?.copyWith(color: Cores.verdeEscuro, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 18, color: Cores.verdeEscuro),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BotaoFavorito extends StatelessWidget {
  const BotaoFavorito(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) => IconButton.filled(
        style: IconButton.styleFrom(backgroundColor: Colors.white),
        tooltip: receita.favorita ? 'Remover dos favoritos' : 'Favoritar',
        onPressed: () => dados.alternarFavorita(receita),
        icon: Icon(receita.favorita ? Icons.favorite : Icons.favorite_border,
            color: Cores.erro),
      ),
    );
  }
}

/// Estado vazio ou de erro, com ação opcional.
class Aviso extends StatelessWidget {
  const Aviso({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.texto,
    this.acao,
    this.onAcao,
  });

  final String emoji;
  final String titulo;
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(titulo,
                textAlign: TextAlign.center,
                style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(texto,
                textAlign: TextAlign.center,
                style: textos.bodyMedium?.copyWith(color: Cores.textoSuave)),
            if (acao != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAcao, child: Text(acao!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Título de tela no estilo do Stitch ("VISÃO GERAL / Minha despensa").
class Cabecalho extends StatelessWidget {
  const Cabecalho({super.key, required this.sobrescrito, required this.titulo, this.direita});

  final String sobrescrito;
  final String titulo;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sobrescrito.toUpperCase(),
                  style: textos.labelMedium?.copyWith(
                      color: Cores.verde, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(titulo,
                  style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        ?direita,
      ],
    );
  }
}
