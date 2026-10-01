import 'package:flutter/material.dart';

import '../busca_alimento.dart';
import '../dados.dart';
import '../tema.dart';
import '../voz_sheet.dart';
import '../widgets.dart';
import 'gerando_tela.dart';

class DespensaTela extends StatefulWidget {
  const DespensaTela({super.key});

  @override
  State<DespensaTela> createState() => _DespensaTelaState();
}

class _DespensaTelaState extends State<DespensaTela> {
  String? _filtro; // null = Todos

  Future<void> _ditar() => mostrarVoz(
    context,
    aoConfirmar: (itens) async {
      for (final (a, q) in itens) {
        final atual = dados.despensa
            .where((i) => i.alimento.id == a.id)
            .firstOrNull;
        await dados.adicionarItem(
          a,
          q ?? atual?.quantidade,
          validade: atual?.validade,
        );
      }
    },
  );

  Future<void> _editar(Alimento a, {ItemDespensa? item}) async {
    final resposta = await showDialog<(String, DateTime?)>(
      context: context,
      builder: (_) => _QuantidadeDialog(a, item: item),
    );
    if (resposta == null) return;
    final (quantidade, validade) = resposta;
    await dados.adicionarItem(a, quantidade, validade: validade);
  }

  Future<void> _remover(ItemDespensa item) async {
    await dados.removerItem(item.alimento.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.alimento.nomeCurto} removido'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => dados.adicionarItem(
              item.alimento,
              item.quantidade,
              validade: item.validade,
            ),
          ),
        ),
      );
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
        final ordem = emojiCategoria.keys.toList();
        final categorias = grupos.keys.toList()
          ..sort((a, b) => ordem.indexOf(a).compareTo(ordem.indexOf(b)));
        if (_filtro != null && !grupos.containsKey(_filtro)) _filtro = null;
        final visiveis = _filtro == null ? categorias : [_filtro!];
        final n = dados.despensa.length;

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
              children: [
                Cabecalho(
                  sobrescrito: 'Visão geral',
                  titulo: 'Minha despensa',
                  direita: Pilula(
                    '$n ${n == 1 ? 'alimento' : 'alimentos'}',
                    icone: Icons.eco_outlined,
                    fundo: Cores.verdeFixo,
                    cor: Cores.noVerdeFixo,
                    sombra: true,
                  ),
                ),
                const SizedBox(height: 12),
                _resumo(n),
                const SizedBox(height: 12),
                BuscaAlimento(
                  aoFalar: _ditar,
                  aoEscolher: (a) => _editar(a),
                  jaTem: (a) => dados.temNaDespensa(a.id),
                  sugestoes: () => dados.sugestoes,
                ),
                if (categorias.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _filtros(categorias),
                ],
                if (n == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Aviso(
                      icone: Icons.kitchen_outlined,
                      titulo: 'Sua despensa está vazia',
                      texto:
                          'Busque acima o que você tem em casa — ovo, tomate, arroz… '
                          'Depois é só gerar o cardápio!',
                    ),
                  ),
                for (final cat in visiveis) _grupo(cat, grupos[cat]!),
                if (n > 0) ...[
                  const SizedBox(height: 24),
                  const Dica(
                    icone: Icons.soup_kitchen_outlined,
                    texto:
                        'Dica NutriCasa: toque em Gerar cardápio para combinar estes '
                        'alimentos em receitas saborosas, sem desperdício!',
                  ),
                ],
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _rodape()),
          ],
        );
      },
    );
  }

  Widget _resumo(int n) {
    final textos = Theme.of(context).textTheme;
    final restantes = dados.geracoesRestantes;
    final vencendo = dados.vencendo;
    if (vencendo.isNotEmpty) {
      final nomes = vencendo
          .take(3)
          .map((i) => i.alimento.nomeCurto)
          .join(', ');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Cores.laranjaFixo.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: Sombras.leve,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Cores.laranja,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vencendo.length == 1
                        ? 'Use primeiro: 1 alimento vencendo'
                        : 'Use primeiro: ${vencendo.length} alimentos vencendo',
                    style: textos.labelMedium,
                  ),
                  Text(
                    vencendo.length > 3 ? '$nomes…' : nomes,
                    style: textos.bodySmall?.copyWith(
                      color: Cores.noLaranjaFixo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Cores.superficieBaixa,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Sombras.leve,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Cores.laranjaFixo,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tips_and_updates_outlined,
                  size: 22,
                  color: Cores.noLaranjaFixo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n == 0 ? 'Vamos começar?' : 'Tudo pronto para cozinhar!',
                      style: textos.labelMedium,
                    ),
                    Text(
                      n == 0
                          ? 'Adicione os alimentos que você tem em casa.'
                          : restantes == 0
                          ? 'Você já usou os $limiteDiario cardápios de hoje.'
                          : 'Gere até $restantes ${restantes == 1 ? 'cardápio' : 'cardápios'} hoje com esses ingredientes.',
                      style: textos.bodySmall?.copyWith(
                        color: Cores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filtros(List<String> categorias) {
    Widget chip(String texto, String? valor, {int? contador}) => ChipFiltro(
      texto,
      ativo: _filtro == valor,
      contador: contador,
      onTap: () => setState(() => _filtro = valor),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          chip('Todos', null, contador: dados.despensa.length),
          for (final c in categorias) chip(c, c),
        ],
      ),
    );
  }

  Widget _grupo(String categoria, List<ItemDespensa> itens) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(categoria, style: textos.titleMedium),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: corCategoria(categoria),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${itens.length} ${itens.length == 1 ? 'item' : 'itens'}',
                  style: textos.labelSmall?.copyWith(color: Cores.textoSuave),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final i in itens) _chip(i)],
          ),
        ],
      ),
    );
  }

  Widget _chip(ItemDespensa item) {
    final textos = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 40,
      ),
      child: Material(
        color: Cores.branco,
        elevation: 0.6,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editar(item.alimento, item: item),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emojiDe(item.alimento),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.alimento.nomeCurto,
                          style: textos.labelMedium,
                        ),
                        if (item.quantidade != null)
                          TextSpan(
                            text: ' (${item.quantidade})',
                            style: textos.bodySmall?.copyWith(
                              color: Cores.textoSuave,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (avisoValidade(dados.diasParaVencer(item)) case (
                  final texto,
                  final cor,
                  final fundo,
                )) ...[
                  const SizedBox(width: 6),
                  Pilula(texto, icone: Icons.schedule, cor: cor, fundo: fundo),
                ],
                const SizedBox(width: 6),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Remover ${item.alimento.nomeCurto}',
                    style: IconButton.styleFrom(
                      backgroundColor: Cores.superficie,
                    ),
                    icon: Icon(Icons.close, size: 15, color: Cores.textoSuave),
                    onPressed: () => _remover(item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rodape() {
    final textos = Theme.of(context).textTheme;
    final restantes = dados.geracoesRestantes;
    final vazia = dados.despensa.isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Cores.fundo.withValues(alpha: 0),
            Cores.fundo.withValues(alpha: 0.95),
          ],
          stops: const [0, 0.45],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Cores.branco.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(99),
              boxShadow: Sombras.leve,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  restantes == 0 ? Icons.schedule : Icons.auto_awesome,
                  size: 16,
                  color: restantes == 0 ? Cores.erro : Cores.laranja,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    restantes == 0
                        ? 'Limite de hoje atingido. Volte amanhã!'
                        : '$restantes ${restantes == 1 ? 'geração restante' : 'gerações restantes'} hoje',
                    overflow: TextOverflow.ellipsis,
                    style: textos.labelMedium?.copyWith(
                      color: restantes == 0 ? Cores.erro : Cores.laranjaTexto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          BotaoPrincipal(
            texto: 'Gerar cardápio',
            icone: Icons.auto_fix_high,
            onPressed: vazia || restantes == 0
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GerandoTela(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuantidadeDialog extends StatefulWidget {
  const _QuantidadeDialog(this.alimento, {this.item});

  final Alimento alimento;
  final ItemDespensa? item;

  @override
  State<_QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<_QuantidadeDialog> {
  late final _ctrl = TextEditingController(text: widget.item?.quantidade);
  late DateTime? _validade = widget.item?.validade;

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(dados.agora());
    final data = await showDatePicker(
      context: context,
      initialDate: _validade ?? hoje.add(const Duration(days: 7)),
      firstDate: hoje.subtract(const Duration(days: 30)),
      lastDate: hoje.add(const Duration(days: 730)),
      helpText: 'Validade',
    );
    if (data != null) setState(() => _validade = data);
  }

  void _salvar([String? texto]) =>
      Navigator.pop(context, (texto ?? _ctrl.text, _validade));
  static const _atalhos = [
    '1 un',
    '2 un',
    '6 un',
    '1 dúzia',
    '500 g',
    '1 kg',
    '1 pacote',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final a = widget.alimento;
    final novo = widget.item == null && !dados.temNaDespensa(a.id);
    return AlertDialog(
      title: Row(
        children: [
          Text(emojiDe(a), style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.nomeCurto, style: textos.titleMedium),
                if (a.curto != null)
                  Text(
                    a.nome,
                    style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Quantidade (opcional)',
              hintText: 'ex: 3 un, 500 g',
              prefixIcon: Icon(Icons.scale_outlined, size: 20),
            ),
            onSubmitted: _salvar,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final q in _atalhos)
                ActionChip(
                  label: Text(q),
                  labelStyle: textos.labelMedium,
                  backgroundColor: Cores.superficieBaixa,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  onPressed: () => _ctrl.text = q,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Cores.superficieBaixa,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _escolherData,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, size: 20, color: Cores.contorno),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _validade == null
                            ? 'Validade (opcional)'
                            : 'Vence em ${formatarData(_validade!)}',
                        style: textos.bodyMedium?.copyWith(
                          color: _validade == null
                              ? Cores.contorno
                              : Cores.texto,
                        ),
                      ),
                    ),
                    if (_validade != null)
                      IconButton(
                        tooltip: 'Remover validade',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _validade = null),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.chevron_right, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            shape: const StadiumBorder(),
          ),
          onPressed: _salvar,
          child: Text(novo ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }
}
