import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../busca_alimento.dart';
import '../dados.dart';
import '../tema.dart';
import '../voz_sheet.dart';
import '../widgets.dart';

class ComprasTela extends StatelessWidget {
  const ComprasTela({super.key});

  Future<void> _guardar(BuildContext context) async {
    final n = await dados.guardarComprados();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          n == 1
              ? '1 item guardado na despensa'
              : '$n itens guardados na despensa',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const Topo('Lista de compras', voltar: true),
      body: ListenableBuilder(
        listenable: dados,
        builder: (context, _) {
          final pendentes = dados.compras.where((c) => !c.comprado).toList();
          final comprados = dados.compras.where((c) => c.comprado).toList();
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  120 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  Cabecalho(
                    sobrescrito: 'Para comprar',
                    titulo: 'Lista de compras',
                    direita: pendentes.isEmpty
                        ? null
                        : IconButton.filledTonal(
                            tooltip: 'Compartilhar lista',
                            style: IconButton.styleFrom(
                              backgroundColor: Cores.verdeNav,
                            ),
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                text: dados.textoDaLista,
                                subject: 'Lista de compras',
                              ),
                            ),
                            icon: const Icon(
                              Icons.share,
                              color: Cores.primaria,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  BuscaAlimento(
                    dica: 'Adicionar à lista… (ex: leite, pão)',
                    textoJaTem: 'Na lista',
                    jaTem: (a) =>
                        dados.compras.any((c) => c.alimento.id == a.id),
                    sugestoes: () => dados.sugestoes,
                    aoEscolher: (a) => dados.adicionarCompra(a, null),
                    aoFalar: () => mostrarVoz(
                      context,
                      destino: 'lista',
                      aoConfirmar: (itens) async {
                        for (final (a, q) in itens) {
                          await dados.adicionarCompra(a, q);
                        }
                      },
                    ),
                  ),
                  if (dados.compras.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Aviso(
                        icone: Icons.shopping_cart_outlined,
                        titulo: 'Sua lista está vazia',
                        texto:
                            'Adicione itens pela busca ou, numa receita, toque em '
                            '"Adicionar o que falta à lista".',
                      ),
                    ),
                  if (pendentes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _titulo(textos, 'A comprar', pendentes.length),
                    for (final c in pendentes) _Linha(c),
                  ],
                  if (comprados.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _titulo(textos, 'No carrinho', comprados.length),
                    for (final c in comprados) _Linha(c),
                  ],
                ],
              ),
              if (comprados.isNotEmpty)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                  child: BotaoPrincipal(
                    texto: comprados.length == 1
                        ? 'Guardar 1 item na despensa'
                        : 'Guardar ${comprados.length} itens na despensa',
                    icone: Icons.kitchen_outlined,
                    onPressed: () => _guardar(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _titulo(TextTheme textos, String texto, int n) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            texto.toUpperCase(),
            style: textos.labelMedium?.copyWith(
              color: Cores.textoSuave,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Text('$n', style: textos.labelSmall?.copyWith(color: Cores.primaria)),
      ],
    ),
  );
}

class _Linha extends StatelessWidget {
  const _Linha(this.item);

  final ItemCompra item;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final id = item.alimento.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: item.comprado ? Cores.superficieBaixa : Cores.branco,
        borderRadius: BorderRadius.circular(16),
        elevation: item.comprado ? 0 : 0.6,
        shadowColor: const Color(0x33000000),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => dados.alternarComprado(id),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
            child: Row(
              children: [
                Checkbox(
                  value: item.comprado,
                  activeColor: Cores.verde,
                  onChanged: (_) => dados.alternarComprado(id),
                ),
                Text(
                  emojiDe(item.alimento),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.alimento.nomeCurto,
                        overflow: TextOverflow.ellipsis,
                        style: textos.labelLarge?.copyWith(
                          decoration: item.comprado
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.comprado ? Cores.textoSuave : Cores.texto,
                        ),
                      ),
                      if (item.quantidade != null)
                        Text(
                          item.quantidade!,
                          overflow: TextOverflow.ellipsis,
                          style: textos.bodySmall?.copyWith(
                            color: Cores.textoSuave,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tirar ${item.alimento.nomeCurto} da lista',
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Cores.textoSuave,
                  ),
                  onPressed: () => dados.removerCompra(id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
