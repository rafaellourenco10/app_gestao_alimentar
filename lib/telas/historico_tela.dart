import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'gerando_tela.dart';
import 'receita_tela.dart';

class HistoricoTela extends StatelessWidget {
  const HistoricoTela({super.key});

  static String grupo(DateTime data, DateTime agora) {
    final dias = DateUtils.dateOnly(
      agora,
    ).difference(DateUtils.dateOnly(data)).inDays;
    if (dias <= 0) return 'Hoje';
    if (dias == 1) return 'Ontem';
    if (dias < 7) return 'Esta semana';
    return 'Anteriores';
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final agora = dados.agora();
        final grupos = <String, List<Receita>>{};
        for (final r in dados.receitas) {
          (grupos[grupo(r.criadaEm, agora)] ??= []).add(r);
        }
        final podeGerar =
            dados.despensa.isNotEmpty && dados.geracoesRestantes > 0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Cabecalho(
              sobrescrito: 'Histórico',
              titulo: 'Meus cardápios',
              subtitulo: 'Sugestões geradas pela IA com a sua despensa',
            ),
            if (dados.receitas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Aviso(
                  icone: Icons.menu_book_outlined,
                  titulo: 'Nenhum cardápio ainda',
                  texto:
                      'Na aba Despensa, adicione seus alimentos e toque em "Gerar cardápio".',
                ),
              ),
            for (final MapEntry(key: nome, value: lista) in grupos.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: nome == 'Hoje'
                            ? Cores.laranja
                            : Cores.superficieAlta,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nome.toUpperCase(),
                        style: textos.labelMedium?.copyWith(
                          color: Cores.textoSuave,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      '${lista.length} ${lista.length == 1 ? 'receita' : 'receitas'}',
                      style: textos.labelSmall?.copyWith(color: Cores.primaria),
                    ),
                  ],
                ),
              ),
              for (final r in lista) ...[_Linha(r), const SizedBox(height: 12)],
            ],
            if (dados.receitas.isNotEmpty && podeGerar) ...[
              const SizedBox(height: 12),
              Cartao(
                cor: Cores.superficieBaixa,
                sombra: Sombras.leve,
                raio: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Cores.laranja,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quer novidades?', style: textos.titleMedium),
                          Text(
                            'Crie um cardápio novo com a IA',
                            style: textos.bodySmall?.copyWith(
                              color: Cores.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Cores.verde,
                        minimumSize: const Size(0, 40),
                        shape: const StadiumBorder(),
                        textStyle: textos.labelLarge,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GerandoTela(),
                        ),
                      ),
                      child: const Text('Gerar'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Linha compacta do histórico (miniatura + título + ingredientes).
class _Linha extends StatelessWidget {
  const _Linha(this.receita);

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final h = receita.criadaEm;
    final hora =
        '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';
    return Container(
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Sombras.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => ReceitaTela(receita))),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 88,
                    child: ImagemReceita(receita, altura: 88, tamanho: 0.45),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Pilula(
                              tipoReceita(receita.tipo).$1,
                              fundo: Cores.superficieBaixa,
                              cor: Cores.primaria,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hora,
                            style: textos.labelSmall?.copyWith(
                              color: Cores.textoSuave,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        receita.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textos.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Cores.laranja,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${receita.kcal.round()} kcal · ${receita.tempoMin} min',
                              overflow: TextOverflow.ellipsis,
                              style: textos.bodySmall?.copyWith(
                                color: Cores.textoSuave,
                              ),
                            ),
                          ),
                          if (receita.favorita) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Cores.erro,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Cores.superficieBaixa,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Cores.verde,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
