import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class ReceitaTela extends StatelessWidget {
  const ReceitaTela(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: dados,
          builder: (context, _) => SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _destaque(context),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _titulo(context),
                        const SizedBox(height: 20),
                        _nutricao(context),
                        const SizedBox(height: 20),
                        _ingredientes(context),
                        const SizedBox(height: 20),
                        _preparo(context),
                        const SizedBox(height: 20),
                        _avaliacao(context),
                        const SizedBox(height: 20),
                        Text(
                          'Valores nutricionais estimados com base na Tabela Brasileira de '
                          'Composição de Alimentos (TACO). Não substituem a orientação de '
                          'um nutricionista.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Cores.textoSuave),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoRedondo({
    required Widget icone,
    required VoidCallback onPressed,
    String? dica,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: Sombras.media,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: dica,
        onPressed: onPressed,
        icon: icone,
      ),
    );
  }

  Widget _destaque(BuildContext context) {
    final (tem, total) = dados.cobertura(receita);
    return Stack(
      children: [
        ImagemReceita(
          receita,
          altura: 288 + MediaQuery.paddingOf(context).top,
          tamanho: 1.3,
        ),
        Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.paddingOf(context).top + 12,
          child: Row(
            children: [
              _botaoRedondo(
                dica: 'Voltar',
                icone: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: Cores.texto,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              BotaoFavorito(receita),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Pilula(
                  tem == total ? '100% Despensa' : '$tem de $total na despensa',
                  icone: Icons.check_circle,
                  fundo: Cores.primaria.withValues(alpha: 0.88),
                  cor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Pilula(
                receita.tempoMin <= 15 ? 'Prático & rápido' : 'Feito em casa',
                icone: Icons.local_fire_department,
                fundo: Colors.black.withValues(alpha: 0.4),
                cor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _titulo(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    Widget meta(IconData icone, Color cor, String texto) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Cores.superficieBaixa,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: 6),
          Text(
            texto,
            style: textos.labelMedium?.copyWith(color: Cores.textoSuave),
          ),
        ],
      ),
    );
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pilula(
                tipoReceita(receita.tipo).$1.toUpperCase(),
                fundo: Cores.superficieBaixa,
                cor: Cores.primaria,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '•  Receita NutriCasa',
                  overflow: TextOverflow.ellipsis,
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            receita.titulo,
            style: textos.headlineSmall?.copyWith(height: 1.25),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              meta(
                Icons.schedule,
                Cores.primaria,
                '${receita.tempoMin} minutos',
              ),
              meta(
                Icons.restaurant,
                Cores.laranjaTexto,
                '${receita.porcoes} ${receita.porcoes == 1 ? 'porção' : 'porções'}',
              ),
              meta(
                Icons.bolt,
                Cores.verde,
                'Nível ${receita.dificuldade.toLowerCase()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secao(
    BuildContext context,
    String titulo, {
    Widget? icone,
    Widget? direita,
    required List<Widget> filhos,
  }) {
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icone != null) ...[icone, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ?direita,
            ],
          ),
          const SizedBox(height: 16),
          ...filhos,
        ],
      ),
    );
  }

  Widget _nutricao(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final macros = [
      ('Proteínas', receita.proteina, receita.proteina * 4, Cores.verde),
      (
        'Carboidratos',
        receita.carbo,
        receita.carbo * 4,
        const Color(0xFF1B6D24),
      ),
      ('Gorduras', receita.gordura, receita.gordura * 9, Cores.laranja),
    ];
    final energia = macros.fold(0.0, (t, m) => t + m.$3);
    final fracaoProteina = energia == 0 ? 0 : receita.proteina * 4 / energia;
    final fracaoCarbo = energia == 0 ? 0 : receita.carbo * 4 / energia;
    final insight = fracaoProteina >= 0.25
        ? 'Boa fonte de proteína, que dá mais saciedade.'
        : fracaoCarbo >= 0.55
        ? 'Rica em carboidratos: energia para o seu dia.'
        : 'Refeição equilibrada entre proteínas, carboidratos e gorduras.';

    return _secao(
      context,
      'Tabela nutricional',
      icone: const Icon(
        Icons.local_dining,
        size: 22,
        color: Cores.laranjaTexto,
      ),
      direita: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Cores.laranjaFixo,
          borderRadius: BorderRadius.circular(99),
          boxShadow: Sombras.leve,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${receita.kcal.round()} ',
                style: textos.titleMedium,
              ),
              TextSpan(text: 'kcal', style: textos.labelMedium),
            ],
          ),
          style: const TextStyle(color: Cores.noLaranjaFixo),
        ),
      ),
      filhos: [
        for (final (nome, gramas, kcal, cor) in macros)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      nome,
                      style: textos.labelMedium?.copyWith(
                        color: Cores.textoSuave,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${gramas.toStringAsFixed(gramas < 10 ? 1 : 0).replaceAll('.', ',')}g',
                      style: textos.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: energia == 0 ? 0 : kcal / energia,
                    color: cor,
                    backgroundColor: Cores.superficieAlta,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        Dica(
          icone: Icons.eco_outlined,
          corIcone: Cores.primaria,
          texto: receita.porcoes == 1
              ? '$insight Valores por porção.'
              : '$insight Valores por porção — a receita rende ${receita.porcoes}.',
        ),
      ],
    );
  }

  Widget _ingredientes(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final (tem, total) = dados.cobertura(receita);
    return _secao(
      context,
      'Ingredientes',
      direita: Pilula(
        '${receita.ingredientes.length} itens',
        fundo: Cores.verdeFixo.withValues(alpha: 0.5),
        cor: Cores.primaria,
      ),
      filhos: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Cores.superficieBaixa,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                tem == total ? Icons.verified : Icons.info_outline,
                size: 20,
                color: Cores.verde,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tem == total
                      ? 'Todos os ingredientes foram encontrados na sua despensa! Sem desperdício hoje.'
                      : 'Você tem $tem de $total ingredientes. Os demais você pode adaptar ou substituir.',
                  style: textos.labelMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final i in receita.ingredientes) _ingrediente(context, i),
      ],
    );
  }

  Widget _ingrediente(BuildContext context, Ingrediente i) {
    final textos = Theme.of(context).textTheme;
    final basico = basicos.contains(i.alimento.id);
    final tem = basico || dados.temNaDespensa(i.alimento.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Cores.fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: tem ? Cores.primaria : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: tem
                  ? null
                  : Border.all(color: Cores.contorno, width: 1.5),
            ),
            child: tem
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.medida, style: textos.bodyMedium),
                Text(
                  '${emojiDe(i.alimento)} ${i.alimento.nomeCurto} · ${i.gramas.round()} g',
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pilula(
            basico ? 'básico' : (tem ? 'despensa' : 'falta'),
            fundo: tem ? Cores.superficieAlta : Cores.laranjaFixo,
            cor: tem ? Cores.textoSuave : Cores.laranjaTexto,
          ),
        ],
      ),
    );
  }

  Widget _preparo(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return _secao(
      context,
      'Modo de preparo',
      direita: Text(
        '${receita.passos.length} etapas simples',
        style: textos.labelMedium?.copyWith(color: Cores.textoSuave),
      ),
      filhos: [
        for (final (n, passo) in receita.passos.indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Cores.fundo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Cores.verde,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${n + 1}',
                    style: textos.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      passo,
                      style: textos.bodyMedium?.copyWith(
                        color: Cores.textoSuave,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _avaliacao(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    Widget botao(int nota, String emoji, String texto) {
      final ativo = receita.feedback == nota;
      return Expanded(
        child: Material(
          color: ativo ? Cores.verde : Cores.superficieBaixa,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => dados.avaliar(receita, nota),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    texto,
                    style: textos.labelLarge?.copyWith(
                      color: ativo ? Colors.white : Cores.texto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Cartao(
      child: Column(
        children: [
          Text('Gostou da receita?', style: textos.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Sua avaliação ajuda o NutriCasa a calibrar seus cardápios.',
            textAlign: TextAlign.center,
            style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              botao(1, '👍', 'Sim'),
              const SizedBox(width: 12),
              botao(-1, '👎', 'Não'),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => dados.alternarFavorita(receita),
            icon: Icon(
              receita.favorita ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: Text(
              receita.favorita ? 'Salva nos favoritos' : 'Salvar nos favoritos',
            ),
          ),
        ],
      ),
    );
  }
}
