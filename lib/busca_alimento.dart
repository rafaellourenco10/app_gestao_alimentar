import 'package:flutter/material.dart';

import 'dados.dart';
import 'tema.dart';
import 'widgets.dart';

/// Campo de busca de alimentos da TACO com sugestões rápidas (despensa e lista de compras).
class BuscaAlimento extends StatefulWidget {
  const BuscaAlimento({
    super.key,
    required this.aoEscolher,
    required this.jaTem,
    required this.sugestoes,
    this.dica = 'Adicionar alimento… (ex: ovo, tomate)',
    this.textoJaTem = 'Na despensa',
    this.aoFalar,
  });

  final Future<void> Function(Alimento) aoEscolher;
  final bool Function(Alimento) jaTem;
  final List<Alimento> Function() sugestoes;
  final String dica;
  final String textoJaTem;

  /// Se informado, mostra o microfone para ditar alimentos.
  final VoidCallback? aoFalar;

  @override
  State<BuscaAlimento> createState() => _BuscaAlimentoState();
}

class _BuscaAlimentoState extends State<BuscaAlimento> {
  TextEditingController? _texto;
  FocusNode? _foco;

  Future<void> _escolher(Alimento a) async {
    if (a.id == _idNovo) {
      final novo = await showDialog<Alimento>(
        context: context,
        builder: (_) => _NovoAlimentoDialog(a.nome),
      );
      if (novo == null) return;
      a = novo;
    }
    await widget.aoEscolher(a);
    _texto?.clear();
    _foco?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Autocomplete<Alimento>(
      displayStringForOption: (a) => a.nomeCurto,
      optionsBuilder: (v) {
        final t = v.text.trim();
        if (t.isEmpty) return widget.sugestoes();
        final achados = dados.buscar(t);
        if (achados.isNotEmpty) return achados;
        // Nada na TACO: itens parecidos + opção de cadastrar o alimento.
        return [...dados.parecidos(t), _opcaoNovo(t)];
      },
      onSelected: _escolher,
      fieldViewBuilder: (context, controller, foco, onSubmitted) {
        _texto = controller;
        _foco = foco;
        // Com as sugestões abertas, o "voltar" do celular só fecha as sugestões.
        return ListenableBuilder(
          listenable: foco,
          builder: (context, campo) => PopScope(
            canPop: !foco.hasFocus,
            onPopInvokedWithResult: (saiu, _) {
              if (!saiu) foco.unfocus();
            },
            child: campo!,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: Sombras.leve,
            ),
            child: TextField(
              controller: controller,
              focusNode: foco,
              // Tocar fora fecha as sugestões (no Android o campo não perde o foco sozinho).
              onTapOutside: (_) => foco.unfocus(),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSubmitted(),
              decoration: InputDecoration(
                hintText: widget.dica,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: widget.aoFalar == null
                    ? null
                    : IconButton(
                        tooltip: 'Ditar alimentos',
                        icon: Icon(Icons.mic_none, color: Cores.verde),
                        onPressed: widget.aoFalar,
                      ),
                fillColor: Cores.branco,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Cores.verde, width: 1.5),
                ),
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, opcoes) {
        final sugestao = (_texto?.text.trim() ?? '').isEmpty;
        return Align(
          alignment: Alignment.topLeft,
          // Faz parte do campo: tocar numa sugestão não conta como "tocar fora".
          child: TextFieldTapRegion(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Material(
                elevation: 12,
                shadowColor: const Color(0x33000000),
                color: Cores.branco,
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 320,
                    maxWidth: MediaQuery.sizeOf(context).width - 40,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    children: [
                      if (sugestao) _tituloSugestoes(textos),
                      if (opcoes.length > 1 && opcoes.last.id == _idNovo)
                        _titulo(textos, 'VOCÊ QUIS DIZER?'),
                      for (final a in opcoes)
                        a.id == _idNovo
                            ? _opcaoCadastrar(textos, a, () => onSelected(a))
                            : _opcao(textos, a, () => onSelected(a)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _titulo(TextTheme textos, String texto) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
    child: Text(
      texto,
      style: textos.labelSmall?.copyWith(color: Cores.textoSuave),
    ),
  );

  Widget _tituloSugestoes(TextTheme textos) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'SUGESTÕES RÁPIDAS',
            style: textos.labelSmall?.copyWith(color: Cores.textoSuave),
          ),
        ),
        Icon(Icons.auto_awesome, size: 14, color: Cores.textoSuave),
      ],
    ),
  );

  Widget _opcaoCadastrar(TextTheme textos, Alimento a, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Cores.verde, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Adicionar “${a.nome}”', style: textos.labelLarge),
                    Text(
                      'Alimento novo, fora da tabela',
                      style: textos.bodySmall?.copyWith(
                        color: Cores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _opcao(TextTheme textos, Alimento a, VoidCallback onTap) {
    final tem = widget.jaTem(a);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Text(emojiDe(a), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.nomeCurto, style: textos.labelLarge),
                  Text(
                    a.curto == null ? a.categoria : a.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            tem
                ? Pilula(
                    widget.textoJaTem,
                    icone: Icons.check,
                    fundo: Cores.superficie,
                    cor: Cores.textoSuave,
                  )
                : Pilula(
                    'Adicionar',
                    icone: Icons.add,
                    fundo: Cores.verdeFixo,
                    cor: Cores.noVerdeFixo,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Id da opção "Adicionar 'xyz'" na lista (a TACO começa no 1; os do usuário são negativos).
const _idNovo = 0;

Alimento _opcaoNovo(String nome) => Alimento(
  id: _idNovo,
  nome: nome,
  categoria: '',
  kcal: 0,
  proteina: 0,
  carbo: 0,
  gordura: 0,
  fibra: 0,
);

/// Cadastro de alimento fora da TACO: nome e kcal por 100 g (opcional, do rótulo).
class _NovoAlimentoDialog extends StatefulWidget {
  const _NovoAlimentoDialog(this.nome);
  final String nome;

  @override
  State<_NovoAlimentoDialog> createState() => _NovoAlimentoDialogState();
}

class _NovoAlimentoDialogState extends State<_NovoAlimentoDialog> {
  late final _nome = TextEditingController(text: widget.nome);
  final _kcal = TextEditingController();

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return;
    final kcal = double.tryParse(_kcal.text.trim().replaceAll(',', '.'));
    final a = await dados.criarAlimento(nome, kcal);
    if (mounted) Navigator.pop(context, a);
  }

  @override
  void dispose() {
    _nome.dispose();
    _kcal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Alimento novo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.edit_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kcal,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Kcal por 100 g (opcional)',
              hintText: 'veja no rótulo',
              prefixIcon: Icon(Icons.local_fire_department_outlined, size: 20),
              suffixText: 'kcal',
            ),
            onSubmitted: (_) => _salvar(),
          ),
          const SizedBox(height: 8),
          Text(
            'Sem as kcal, as receitas com este alimento mostram o total sem ele.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Cores.textoSuave),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
