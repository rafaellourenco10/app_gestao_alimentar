import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class ReceitaTela extends StatelessWidget {
  const ReceitaTela(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final (emoji, rotulo, corTipo) = tipoReceita(receita.tipo);
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: dados,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: corTipo,
              actions: [BotaoFavorito(receita), const SizedBox(width: 8)],
              flexibleSpace: FlexibleSpaceBar(
                background: Center(child: Text(emoji, style: const TextStyle(fontSize: 88))),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList.list(children: [
                Text(rotulo.toUpperCase(),
                    style: textos.labelMedium?.copyWith(
                        color: Cores.verde, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(receita.titulo,
                    style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Selo('${receita.tempoMin} minutos', icone: Icons.schedule, fundo: Cores.verdeClaro),
                  Selo('${receita.porcoes} ${receita.porcoes == 1 ? 'porção' : 'porções'}',
                      icone: Icons.restaurant, fundo: Cores.verdeClaro),
                  Selo(receita.dificuldade, icone: Icons.bolt, fundo: Cores.verdeClaro),
                ]),
                const SizedBox(height: 20),
                _nutricao(context),
                const SizedBox(height: 16),
                _ingredientes(context),
                const SizedBox(height: 16),
                _preparo(context),
                const SizedBox(height: 16),
                _avaliacao(context),
                const SizedBox(height: 16),
                Text(
                  'Valores nutricionais estimados com base na Tabela Brasileira de '
                  'Composição de Alimentos (TACO). Não substituem a orientação de um nutricionista.',
                  textAlign: TextAlign.center,
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao(BuildContext context, String titulo, Widget filho, {Widget? direita}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: Text(titulo,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              ?direita,
            ]),
            const SizedBox(height: 12),
            filho,
          ],
        ),
      ),
    );
  }

  Widget _nutricao(BuildContext context) {
    // Barras relativas à maior fração de energia (4 kcal/g prot e carbo, 9 kcal/g gordura).
    final macros = [
      ('Proteínas', receita.proteina, receita.proteina * 4, Cores.verde),
      ('Carboidratos', receita.carbo, receita.carbo * 4, Cores.terra),
      ('Gorduras', receita.gordura, receita.gordura * 9, Cores.laranja),
    ];
    final energia = macros.fold(0.0, (t, m) => t + m.$3);
    return _secao(
      context,
      'Tabela nutricional',
      direita: seloKcal(receita.kcal),
      Column(children: [
        for (final (nome, gramas, kcal, cor) in macros)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(children: [
              Row(children: [
                Text(nome),
                const Spacer(),
                Text('${gramas.toStringAsFixed(1)} g',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: energia == 0 ? 0 : kcal / energia,
                color: cor,
                backgroundColor: Cores.campo,
                minHeight: 6,
                borderRadius: const BorderRadius.all(Radius.circular(99)),
              ),
            ]),
          ),
        Text(receita.porcoes == 1 ? 'Valores por porção' : 'Valores por porção (receita rende ${receita.porcoes})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSuave)),
      ]),
    );
  }

  Widget _ingredientes(BuildContext context) {
    return _secao(
      context,
      'Ingredientes',
      direita: Selo('${receita.ingredientes.length} itens', fundo: Cores.verdeClaro, cor: Cores.verdeEscuro),
      Column(children: [
        for (final i in receita.ingredientes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              dados.temNaDespensa(i.alimento.id) || basicos.contains(i.alimento.id)
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: Cores.verde,
            ),
            title: Text(i.medida, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('${i.gramas.round()} g'),
            trailing: basicos.contains(i.alimento.id)
                ? const Selo('básico', fundo: Cores.campo)
                : dados.temNaDespensa(i.alimento.id)
                    ? const Selo('despensa', fundo: Cores.verdeClaro, cor: Cores.verdeEscuro)
                    : null,
          ),
      ]),
    );
  }

  Widget _preparo(BuildContext context) {
    return _secao(
      context,
      'Modo de preparo',
      direita: Text('${receita.passos.length} etapas',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSuave)),
      Column(children: [
        for (final (n, passo) in receita.passos.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Cores.verde,
                child: Text('${n + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(passo, style: Theme.of(context).textTheme.bodyLarge)),
            ]),
          ),
      ]),
    );
  }

  Widget _avaliacao(BuildContext context) {
    Widget botao(int nota, String texto) => Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: receita.feedback == nota ? Cores.verde : Cores.verdeClaro,
              foregroundColor: receita.feedback == nota ? Colors.white : Cores.verdeEscuro,
            ),
            onPressed: () => dados.avaliar(receita, nota),
            child: Text(texto),
          ),
        );
    return _secao(
      context,
      'Gostou da receita?',
      Column(children: [
        Row(children: [botao(1, '👍  Sim'), const SizedBox(width: 12), botao(-1, '👎  Não')]),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => dados.alternarFavorita(receita),
          icon: Icon(receita.favorita ? Icons.favorite : Icons.favorite_border),
          label: Text(receita.favorita ? 'Salva nos favoritos' : 'Salvar nos favoritos'),
        ),
      ]),
    );
  }
}
