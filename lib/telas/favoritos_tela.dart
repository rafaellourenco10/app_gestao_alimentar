import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class FavoritosTela extends StatelessWidget {
  const FavoritosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final favoritas = dados.favoritas;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Cabecalho(
              sobrescrito: 'Suas receitas',
              titulo: 'Favoritos',
              direita: Selo(
                  '${favoritas.length} ${favoritas.length == 1 ? 'salva' : 'salvas'}',
                  fundo: Cores.verdeClaro, cor: Cores.verdeEscuro),
            ),
            if (favoritas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Aviso(
                  emoji: '💚',
                  titulo: 'Você ainda não favoritou nenhuma receita',
                  texto: 'Toque no coração de uma receita para guardá-la aqui.',
                ),
              ),
            for (final r in favoritas) ...[const SizedBox(height: 16), ReceitaCard(r)],
          ],
        );
      },
    );
  }
}
