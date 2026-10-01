import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'compras_tela.dart';
import 'receita_tela.dart';

const diasDaSemana = [
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
  'Domingo',
];

class PlanoTela extends StatelessWidget {
  const PlanoTela({super.key});

  Future<void> _escolher(BuildContext context, int dia) async {
    // Favoritas primeiro, depois o resto do histórico.
    final opcoes = [
      ...dados.receitas.where((r) => r.favorita),
      ...dados.receitas.where((r) => !r.favorita),
    ];
    final textos = Theme.of(context).textTheme;
    final escolhida = await showModalBottomSheet<Receita>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, rolagem) => ListView(
          controller: rolagem,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(diasDaSemana[dia], style: textos.titleLarge),
            const SizedBox(height: 8),
            for (final r in opcoes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    child: ImagemReceita(r, altura: 48),
                  ),
                ),
                title: Text(r.titulo),
                subtitle: Text(
                  '${tipoReceita(r.tipo).$1}${r.favorita ? ' • ♥' : ''}',
                ),
                onTap: () => Navigator.pop(context, r),
              ),
          ],
        ),
      ),
    );
    if (escolhida != null) await dados.planejar(dia, escolhida);
  }

  Future<void> _comprar(BuildContext context) async {
    final n = await dados.adicionarFaltandoDoPlano();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            n == 0
                ? 'Você já tem tudo para a semana'
                : n == 1
                ? '1 item na lista de compras'
                : '$n itens na lista de compras',
          ),
          action: n == 0
              ? null
              : SnackBarAction(
                  label: 'Ver lista',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ComprasTela(),
                    ),
                  ),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Plano da semana')),
      body: ListenableBuilder(
        listenable: dados,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Escolha uma receita para cada dia e monte a lista de compras '
              'com o que falta.',
              style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
            ),
            const SizedBox(height: 16),
            for (final (dia, nome) in diasDaSemana.indexed) ...[
              _dia(context, dia, nome),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
            BotaoPrincipal(
              texto: 'Adicionar o que falta à lista',
              icone: Icons.shopping_cart_outlined,
              onPressed: dados.plano.isEmpty ? null : () => _comprar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dia(BuildContext context, int dia, String nome) {
    final textos = Theme.of(context).textTheme;
    final r = dados.plano[dia];
    final faltam = r == null ? 0 : dados.faltando(r).length;
    return Cartao(
      raio: 16,
      sombra: Sombras.card,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          title: Text(
            nome,
            style: textos.labelLarge?.copyWith(color: Cores.primaria),
          ),
          subtitle: Text(
            r == null
                ? 'Toque para escolher uma receita'
                : '${r.titulo}${faltam > 0 ? '\nFalta${faltam == 1 ? '' : 'm'} $faltam ingrediente${faltam == 1 ? '' : 's'}' : ''}',
            style: textos.bodyMedium?.copyWith(
              color: r == null ? Cores.textoSuave : Cores.texto,
            ),
          ),
          onTap: () => r == null
              ? _escolher(context, dia)
              : Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => ReceitaTela(r))),
          trailing: r == null
              ? const Icon(Icons.add)
              : PopupMenuButton<String>(
                  tooltip: 'Opções',
                  onSelected: (o) => o == 'trocar'
                      ? _escolher(context, dia)
                      : dados.planejar(dia, null),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'trocar',
                      child: Text('Trocar receita'),
                    ),
                    PopupMenuItem(
                      value: 'tirar',
                      child: Text('Tirar do plano'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
