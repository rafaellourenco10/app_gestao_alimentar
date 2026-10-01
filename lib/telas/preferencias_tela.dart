import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

const opcoesRestricao = ['Vegetariano', 'Vegano', 'Sem lactose', 'Sem glúten'];

class PreferenciasTela extends StatefulWidget {
  const PreferenciasTela({super.key});

  @override
  State<PreferenciasTela> createState() => _PreferenciasTelaState();
}

class _PreferenciasTelaState extends State<PreferenciasTela> {
  final _restricoes = {...dados.restricoes};
  final _alergias = TextEditingController(text: dados.alergias);
  final _meta = TextEditingController(text: dados.metaKcal?.toString() ?? '');

  @override
  void dispose() {
    _alergias.dispose();
    _meta.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final meta = int.tryParse(_meta.text);
    await dados.salvarPreferenciasAlimentares(
      _restricoes,
      _alergias.text,
      meta == null || meta <= 0 ? null : meta,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências alimentares')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'As receitas sugeridas vão respeitar estas escolhas.',
            style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
          ),
          const SizedBox(height: 20),
          Text('Dieta e restrições', style: textos.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in opcoesRestricao)
                FilterChip(
                  label: Text(o),
                  selected: _restricoes.contains(o),
                  onSelected: (sim) => setState(
                    () => sim ? _restricoes.add(o) : _restricoes.remove(o),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Alergias', style: textos.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _alergias,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex.: amendoim, camarão',
            ),
          ),
          const SizedBox(height: 24),
          Text('Meta de calorias por dia', style: textos.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _meta,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              hintText: 'Ex.: 2000',
              suffixText: 'kcal',
            ),
          ),
          const SizedBox(height: 32),
          BotaoPrincipal(texto: 'Salvar', onPressed: _salvar),
        ],
      ),
    );
  }
}

/// Resumo curto para o subtítulo no Perfil.
String resumoPreferencias() {
  final partes = [
    ...dados.restricoes,
    if (dados.alergias.isNotEmpty) 'alergias',
    if (dados.metaKcal != null) '${dados.metaKcal} kcal/dia',
  ];
  return partes.isEmpty ? 'Dietas, restrições e alergias' : partes.join(' • ');
}
