import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'gerando_tela.dart';

class CardapioTela extends StatelessWidget {
  const CardapioTela(this.receitas, {super.key});

  final List<Receita> receitas;

  @override
  Widget build(BuildContext context) {
    final restantes = dados.geracoesRestantes;
    return Scaffold(
      appBar: AppBar(title: const Text('Cardápio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Cabecalho(sobrescrito: 'Sugestões inteligentes', titulo: 'Seu cardápio'),
          const SizedBox(height: 4),
          Text('${receitas.length} receitas criadas com o que você tem na despensa',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Cores.textoSuave)),
          for (final r in receitas) ...[const SizedBox(height: 16), ReceitaCard(r)],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: restantes == 0
                ? null
                : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const GerandoTela())),
            icon: const Icon(Icons.refresh),
            label: Text(restantes == 0
                ? 'Limite de hoje atingido'
                : 'Gerar outras opções ($restantes restantes hoje)'),
          ),
        ],
      ),
    );
  }
}
