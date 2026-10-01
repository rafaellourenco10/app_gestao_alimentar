import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class HistoricoTela extends StatelessWidget {
  const HistoricoTela({super.key});

  static String grupo(DateTime data, DateTime agora) {
    final dias = DateUtils.dateOnly(agora).difference(DateUtils.dateOnly(data)).inDays;
    if (dias <= 0) return 'Hoje';
    if (dias == 1) return 'Ontem';
    if (dias < 7) return 'Esta semana';
    return 'Anteriores';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final agora = dados.agora();
        final grupos = <String, List<Receita>>{};
        for (final r in dados.receitas) {
          (grupos[grupo(r.criadaEm, agora)] ??= []).add(r);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Cabecalho(sobrescrito: 'Histórico', titulo: 'Meus cardápios'),
            if (dados.receitas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Aviso(
                  emoji: '📖',
                  titulo: 'Nenhum cardápio ainda',
                  texto: 'Na aba Despensa, adicione seus alimentos e toque em "Gerar cardápio".',
                ),
              ),
            for (final MapEntry(key: nome, value: lista) in grupos.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 4),
                child: Text(nome.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Cores.textoSuave, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
              for (final r in lista) ...[const SizedBox(height: 12), ReceitaCard(r)],
            ],
          ],
        );
      },
    );
  }
}
