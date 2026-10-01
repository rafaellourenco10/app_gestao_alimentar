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
    await widget.aoEscolher(a);
    _texto?.clear();
    _foco?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Autocomplete<Alimento>(
      displayStringForOption: (a) => a.nomeCurto,
      optionsBuilder: (v) =>
          v.text.trim().isEmpty ? widget.sugestoes() : dados.buscar(v.text),
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
                      if (sugestao)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'SUGESTÕES RÁPIDAS',
                                  style: textos.labelSmall?.copyWith(
                                    color: Cores.textoSuave,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Cores.textoSuave,
                              ),
                            ],
                          ),
                        ),
                      for (final a in opcoes)
                        _opcao(textos, a, () => onSelected(a)),
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
