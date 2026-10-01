import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

/// Painel "Cozinhei!": mostra o que sai da despensa e deixa ajustar antes de confirmar.
Future<void> mostrarCozinhei(
  BuildContext context,
  Receita receita,
  double fator,
) async {
  final feito = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Cores.fundo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _Cozinhei(receita, fator),
  );
  if (feito == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despensa atualizada! Bom apetite 😋')),
    );
  }
}

typedef _Item = (Ingrediente, String?, TextEditingController);

class _Cozinhei extends StatefulWidget {
  const _Cozinhei(this.receita, this.fator);

  final Receita receita;
  final double fator;

  @override
  State<_Cozinhei> createState() => _CozinheiState();
}

class _CozinheiState extends State<_Cozinhei> {
  late final List<_Item> _itens = [
    for (final ing in widget.receita.ingredientes)
      if (!basicos.contains(ing.alimento.id) &&
          dados.temNaDespensa(ing.alimento.id))
        _item(ing),
  ];
  late final _acabou = <int>{
    for (final (ing, atual, _) in _itens)
      if (quantidadeDepois(atual, ing, widget.fator).acabou) ing.alimento.id,
  };

  _Item _item(Ingrediente ing) {
    final atual = dados.despensa
        .firstWhere((x) => x.alimento.id == ing.alimento.id)
        .quantidade;
    final depois = quantidadeDepois(atual, ing, widget.fator);
    return (ing, atual, TextEditingController(text: depois.nova ?? ''));
  }

  @override
  void dispose() {
    for (final (_, _, c) in _itens) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmar() async {
    await dados.registrarCozinhado(widget.receita, {
      for (final (ing, _, c) in _itens)
        ing.alimento.id: _acabou.contains(ing.alimento.id) ? null : c.text,
    });
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Cores.superficieAlta,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cozinhou? Que delícia! 🎉', style: textos.titleLarge),
                const SizedBox(height: 4),
                Text(
                  _itens.isEmpty
                      ? 'Nenhum alimento da despensa para atualizar.'
                      : 'Confira o que sobrou na despensa. Ajuste se precisar.',
                  style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              children: [for (final item in _itens) _linha(textos, item)],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: BotaoPrincipal(
              texto: _itens.isEmpty
                  ? 'Marcar como feita'
                  : 'Atualizar despensa',
              icone: Icons.check,
              onPressed: _confirmar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linha(TextTheme textos, _Item item) {
    final (ing, atual, ctrl) = item;
    final id = ing.alimento.id;
    final acabou = _acabou.contains(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: Sombras.leve,
      ),
      child: Row(
        children: [
          Text(emojiDe(ing.alimento), style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ing.alimento.nomeCurto,
                  overflow: TextOverflow.ellipsis,
                  style: textos.labelLarge,
                ),
                Text(
                  'Tinha: ${atual ?? 'sem quantidade'}',
                  overflow: TextOverflow.ellipsis,
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 84,
            child: TextField(
              controller: ctrl,
              enabled: !acabou,
              textAlign: TextAlign.center,
              style: textos.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                hintText: acabou ? 'acabou' : 'sobrou',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: acabou,
                activeColor: Cores.laranja,
                onChanged: (v) =>
                    setState(() => v! ? _acabou.add(id) : _acabou.remove(id)),
              ),
              Text(
                'Acabou',
                style: textos.labelSmall?.copyWith(color: Cores.textoSuave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
