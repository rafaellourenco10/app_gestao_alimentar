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
    final textos = Theme.of(context).textTheme;
    final restantes = dados.geracoesRestantes;
    return Scaffold(
      appBar: const Topo('Cardápios', voltar: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Cabecalho(
            icone: Icons.auto_fix_high,
            sobrescrito: 'Sugestões inteligentes',
            titulo: 'Seu cardápio',
            subtitulo:
                '${receitas.length} receitas criadas com o que você tem na despensa',
            direita: const Pilula(
              'Zero desperdício',
              icone: Icons.eco_outlined,
              fundo: Cores.laranjaFixo,
              cor: Cores.laranjaTexto,
            ),
          ),
          for (final r in receitas) ...[
            const SizedBox(height: 24),
            ReceitaCard(r),
          ],
          const SizedBox(height: 28),
          Material(
            color: restantes == 0 ? Cores.superficie : Cores.superficieBaixa,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: restantes == 0
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const GerandoTela(),
                      ),
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 20,
                      color: restantes == 0 ? Cores.textoSuave : Cores.verde,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        restantes == 0
                            ? 'Limite de hoje atingido'
                            : 'Gerar outras opções ($restantes restantes hoje)',
                        overflow: TextOverflow.ellipsis,
                        style: textos.labelLarge?.copyWith(
                          color: restantes == 0
                              ? Cores.textoSuave
                              : Cores.verde,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Cores.textoSuave,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Dica: quanto mais alimentos na despensa, mais variadas as receitas!',
                  textAlign: TextAlign.center,
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
