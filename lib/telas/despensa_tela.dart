import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'gerando_tela.dart';

class DespensaTela extends StatefulWidget {
  const DespensaTela({super.key});

  @override
  State<DespensaTela> createState() => _DespensaTelaState();
}

class _DespensaTelaState extends State<DespensaTela> {
  TextEditingController? _busca;
  FocusNode? _foco;

  Future<void> _pedirQuantidade(Alimento a, {String? atual}) async {
    final quantidade = await showDialog<String>(
      context: context,
      builder: (_) => _QuantidadeDialog(a, atual: atual),
    );
    _busca?.clear();
    _foco?.unfocus();
    if (quantidade != null) await dados.adicionarItem(a, quantidade);
  }

  Future<void> _remover(ItemDespensa item) async {
    await dados.removerItem(item.alimento.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${item.alimento.nome.split(',').first} removido'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => dados.adicionarItem(item.alimento, item.quantidade),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final grupos = <String, List<ItemDespensa>>{};
        for (final item in dados.despensa) {
          (grupos[item.alimento.categoria] ??= []).add(item);
        }
        final categorias = grupos.keys.toList()
          ..sort((a, b) => emojiCategoria.keys.toList().indexOf(a)
              .compareTo(emojiCategoria.keys.toList().indexOf(b)));

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Cabecalho(
                    sobrescrito: 'Visão geral',
                    titulo: 'Minha despensa',
                    direita: Selo(
                        '${dados.despensa.length} ${dados.despensa.length == 1 ? 'alimento' : 'alimentos'}',
                        icone: Icons.eco_outlined,
                        fundo: Cores.verdeClaro,
                        cor: Cores.verdeEscuro),
                  ),
                  const SizedBox(height: 16),
                  _campoBusca(),
                  const SizedBox(height: 8),
                  if (dados.despensa.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Aviso(
                        emoji: '🧺',
                        titulo: 'Sua despensa está vazia',
                        texto: 'Adicione o que você tem em casa pela busca acima. '
                            'Depois é só gerar o cardápio!',
                      ),
                    ),
                  for (final cat in categorias) ..._grupo(cat, grupos[cat]!),
                ],
              ),
            ),
            _rodape(),
          ],
        );
      },
    );
  }

  Widget _campoBusca() {
    return Autocomplete<Alimento>(
      displayStringForOption: (a) => a.nome,
      optionsBuilder: (v) => dados.buscar(v.text),
      onSelected: (a) => _pedirQuantidade(a),
      fieldViewBuilder: (context, controller, foco, onSubmitted) {
        _busca = controller;
        _foco = foco;
        return TextField(
          controller: controller,
          focusNode: foco,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSubmitted(),
          decoration: const InputDecoration(
            hintText: 'Adicionar alimento… (ex: ovo, tomate)',
            prefixIcon: Icon(Icons.search),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, opcoes) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: MediaQuery.sizeOf(context).width - 40,
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              children: [
                for (final a in opcoes)
                  ListTile(
                    leading: Text(emojiCategoria[a.categoria] ?? '🍽️',
                        style: const TextStyle(fontSize: 22)),
                    title: Text(a.nome),
                    subtitle: Text(a.categoria),
                    trailing: dados.temNaDespensa(a.id)
                        ? const Icon(Icons.check_circle, color: Cores.verde)
                        : const Icon(Icons.add_circle_outline, color: Cores.verde),
                    onTap: () => onSelected(a),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _grupo(String categoria, List<ItemDespensa> itens) {
    final textos = Theme.of(context).textTheme;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Row(children: [
          Text('${emojiCategoria[categoria] ?? '🍽️'}  $categoria',
              style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${itens.length} ${itens.length == 1 ? 'item' : 'itens'}',
              style: textos.labelMedium?.copyWith(color: Cores.textoSuave)),
        ]),
      ),
      Card(
        child: Column(children: [
          for (final (n, item) in itens.indexed) ...[
            if (n > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              title: Text(item.alimento.nome),
              subtitle: Text(item.quantidade ?? 'Toque para informar a quantidade',
                  style: TextStyle(
                      color: item.quantidade == null ? Cores.textoSuave : Cores.verdeEscuro,
                      fontWeight: item.quantidade == null ? null : FontWeight.w600)),
              onTap: () => _pedirQuantidade(item.alimento, atual: item.quantidade ?? ''),
              trailing: IconButton(
                tooltip: 'Remover',
                icon: const Icon(Icons.close),
                onPressed: () => _remover(item),
              ),
            ),
          ],
        ]),
      ),
    ];
  }

  Widget _rodape() {
    final restantes = dados.geracoesRestantes;
    final pode = dados.despensa.isNotEmpty && restantes > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Cores.fundo,
        border: Border(top: BorderSide(color: Color(0x0F000000))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            restantes == 0
                ? 'Você atingiu o limite de hoje. Volte amanhã!'
                : '✨ $restantes ${restantes == 1 ? 'geração restante' : 'gerações restantes'} hoje',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: restantes == 0 ? Cores.erro : Cores.laranjaTexto,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: pode
                ? () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const GerandoTela()))
                : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Gerar cardápio'),
          ),
        ],
      ),
    );
  }
}

class _QuantidadeDialog extends StatefulWidget {
  const _QuantidadeDialog(this.alimento, {this.atual});

  final Alimento alimento;
  final String? atual;

  @override
  State<_QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<_QuantidadeDialog> {
  late final _ctrl = TextEditingController(text: widget.atual);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novo = widget.atual == null && !dados.temNaDespensa(widget.alimento.id);
    return AlertDialog(
      title: Text(widget.alimento.nome),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Quantidade (opcional)',
          hintText: 'ex: 3 un, 500 g, 1 pacote',
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(novo ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }
}
