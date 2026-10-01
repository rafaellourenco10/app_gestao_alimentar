import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class FavoritosTela extends StatefulWidget {
  const FavoritosTela({super.key});

  @override
  State<FavoritosTela> createState() => _FavoritosTelaState();
}

class _FavoritosTelaState extends State<FavoritosTela> {
  String _busca = '';
  String? _tipo; // null = Todas

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final favoritas = dados.favoritas;
        final termo = normalizar(_busca.trim());
        final visiveis = favoritas
            .where((r) => _tipo == null || r.tipo == _tipo)
            .where((r) => termo.isEmpty || normalizar(r.titulo).contains(termo))
            .toList();

        Widget filtro(String texto, String? valor) => ChipFiltro(
          texto,
          ativo: _tipo == valor,
          fundo: Cores.superficieBaixa,
          onTap: () => setState(() => _tipo = valor),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Cabecalho(
              sobrescrito: 'Suas receitas',
              titulo: 'Favoritos',
              direita: Pilula(
                '${favoritas.length} ${favoritas.length == 1 ? 'salva' : 'salvas'}',
                fundo: Cores.verdeFixo,
                cor: Cores.noVerdeFixo,
                sombra: true,
              ),
            ),
            if (favoritas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Aviso(
                  icone: Icons.favorite_border,
                  titulo: 'Você ainda não favoritou nenhuma receita',
                  texto: 'Toque no coração de uma receita para guardá-la aqui.',
                ),
              )
            else ...[
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _busca = v),
                decoration: InputDecoration(
                  hintText: 'Buscar nas salvas…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filtro('Todas', null),
                    filtro('Café da manhã', 'cafe_da_manha'),
                    filtro('Almoço/Jantar', 'almoco_jantar'),
                    filtro('Lanche', 'lanche'),
                  ],
                ),
              ),
              if (visiveis.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    'Nenhuma receita salva com esse filtro.',
                    textAlign: TextAlign.center,
                    style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
                  ),
                ),
              for (final r in visiveis) ...[
                const SizedBox(height: 20),
                ReceitaCard(r),
              ],
            ],
          ],
        );
      },
    );
  }
}
