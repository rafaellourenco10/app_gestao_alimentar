import 'package:flutter/material.dart';

import 'dados.dart';
import 'tema.dart';
import 'telas/receita_tela.dart';

const emojiCategoria = {
  'Cereais e pães': '🍞',
  'Verduras e legumes': '🥕',
  'Frutas': '🍎',
  'Óleos e gorduras': '🫒',
  'Peixes e frutos do mar': '🐟',
  'Carnes': '🍗',
  'Leite e derivados': '🧀',
  'Bebidas': '🥤',
  'Ovos': '🥚',
  'Doces e açúcares': '🍯',
  'Diversos': '🧂',
  'Industrializados': '🥫',
  'Pratos prontos': '🍱',
  'Feijões e leguminosas': '🫘',
  'Nozes e sementes': '🥜',
  'Outros': '🍽️',
};

/// Cor do pontinho ao lado do nome da categoria (como no Stitch).
Color corCategoria(String categoria) => switch (categoria) {
  'Frutas' => Cores.laranja,
  'Verduras e legumes' => Cores.primaria,
  'Carnes' || 'Peixes e frutos do mar' || 'Ovos' => Cores.terra,
  'Cereais e pães' => const Color(0xFFFFB77B),
  'Leite e derivados' => Cores.contorno,
  _ => Cores.superficieAlta,
};

String emojiDe(Alimento a) => a.emoji ?? emojiCategoria[a.categoria] ?? '🍽️';

const _tipos = {
  'cafe_da_manha': ('Café da manhã', [Color(0xFFFFEBCF), Color(0xFFFFD49A)]),
  'almoco_jantar': ('Almoço/Jantar', [Color(0xFFE2F4DC), Color(0xFFB8E3AC)]),
  'lanche': ('Lanche', [Color(0xFFFFE6DC), Color(0xFFFFC6B0)]),
};

/// Rótulo e degradê do tipo de refeição (escurecido no modo escuro).
(String, List<Color>) tipoReceita(String tipo) {
  final (rotulo, cores) =
      _tipos[tipo] ?? ('Receita', [Cores.superficieBaixa, Cores.superficie]);
  if (!Cores.escuro) return (rotulo, cores);
  return (rotulo, [for (final c in cores) Color.lerp(c, Cores.fundo, 0.72)!]);
}

/// Pílula pequena (kcal, tempo, contadores).
class Pilula extends StatelessWidget {
  const Pilula(
    this.texto, {
    super.key,
    this.icone,
    this.fundo,
    this.cor,
    this.corIcone,
    this.sombra = false,
  });

  final String texto;
  final IconData? icone;

  /// Padrões: [Cores.branco] e [Cores.texto] da paleta ativa.
  final Color? fundo;
  final Color? cor;
  final Color? corIcone;
  final bool sombra;

  @override
  Widget build(BuildContext context) {
    final cor = this.cor ?? Cores.texto;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo ?? Cores.branco,
        borderRadius: BorderRadius.circular(99),
        boxShadow: sombra ? Sombras.leve : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: corIcone ?? cor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: cor),
            ),
          ),
        ],
      ),
    );
  }
}

Widget pilulaKcal(double kcal) => Pilula(
  '${kcal.round()} kcal',
  fundo: Cores.laranja,
  cor: Cores.noLaranja,
  sombra: true,
);

/// Superfície branca com cantos arredondados e sombra.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.raio = 12,
    this.sombra = Sombras.media,
    this.cor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double raio;
  final List<BoxShadow> sombra;

  /// Padrão: [Cores.branco] da paleta ativa.
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cor ?? Cores.branco,
        borderRadius: BorderRadius.circular(raio),
        boxShadow: sombra,
      ),
      child: child,
    );
  }
}

/// Botão laranja em pílula com brilho (CTA principal do Stitch).
class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.texto,
    this.icone,
    this.onPressed,
  });

  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ativo = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: ativo ? Sombras.laranja : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 24),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Topo das telas: logo, "NutriCasa" e o título; avatar à direita.
class Topo extends StatelessWidget implements PreferredSizeWidget {
  const Topo(
    this.titulo, {
    super.key,
    this.voltar = false,
    this.acoes = const [],
  });

  final String titulo;
  final bool voltar;
  final List<Widget> acoes;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Cores.fundo,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: EdgeInsets.only(left: voltar ? 4 : 20, right: 12),
            child: Row(
              children: [
                if (voltar) const BackButton(),
                Image.asset('assets/logo.png', height: 32, width: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NutriCasa',
                        style: textos.labelMedium?.copyWith(
                          color: Cores.primaria,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      Text(
                        titulo,
                        overflow: TextOverflow.ellipsis,
                        style: textos.titleMedium,
                      ),
                    ],
                  ),
                ),
                ...acoes,
                Avatar(email: dados.email ?? '', raio: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.email, required this.raio});

  final String email;
  final double raio;

  @override
  Widget build(BuildContext context) {
    final letra = email.isEmpty ? '?' : email[0].toUpperCase();
    return CircleAvatar(
      radius: raio,
      backgroundColor: Cores.verdeFixo,
      child: Text(
        letra,
        style: TextStyle(
          color: Cores.noVerdeFixo,
          fontWeight: FontWeight.w800,
          fontSize: raio * 0.9,
        ),
      ),
    );
  }
}

/// "VISÃO GERAL / Minha despensa" com elemento opcional à direita.
class Cabecalho extends StatelessWidget {
  const Cabecalho({
    super.key,
    required this.sobrescrito,
    required this.titulo,
    this.icone,
    this.direita,
    this.subtitulo,
  });

  final String sobrescrito;
  final String titulo;
  final IconData? icone;
  final Widget? direita;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icone != null) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Cores.verdeFixo,
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 16, color: Cores.noVerdeFixo),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                sobrescrito.toUpperCase(),
                style: textos.labelMedium?.copyWith(
                  color: Cores.primaria,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ?direita,
          ],
        ),
        const SizedBox(height: 2),
        Text(titulo, style: textos.headlineSmall),
        if (subtitulo != null)
          Text(
            subtitulo!,
            style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
          ),
      ],
    );
  }
}

/// Caixa de dica/informação (surface-container-low).
class Dica extends StatelessWidget {
  const Dica({
    super.key,
    required this.icone,
    required this.texto,
    this.titulo,
    this.corIcone,
  });

  final IconData icone;
  final String texto;
  final String? titulo;
  final Color? corIcone;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Cores.superficieBaixa,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: corIcone ?? Cores.verde),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo != null) Text(titulo!, style: textos.labelLarge),
                Text(
                  texto,
                  style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Área de imagem da receita. Sem fotos por enquanto: degradê do tipo de refeição
/// com os ingredientes principais em "pratinhos".
// Palavra-chave (sem acento) → foto em assets/fotos. A ordem importa:
// "salada de fruta" antes de "salada", "omelete" antes de "frango" etc.
const _fotos = [
  (['omelete', 'ovo', 'ovos'], 'ovo'),
  (['panqueca', 'crepe', 'tapioca', 'waffle'], 'panqueca'),
  (['bolo', 'muffin', 'cuca'], 'bolo'),
  (['vitamina', 'smoothie', 'suco', 'batida'], 'vitamina'),
  (['sopa', 'caldo', 'creme de'], 'sopa'),
  (['salada de fruta'], 'frutas'),
  (['salada'], 'salada'),
  (['sanduiche', 'misto', 'torrada', 'pao', 'wrap'], 'sanduiche'),
  (['macarr', 'massa', 'espaguete', 'lasanha', 'nhoque', 'talharim'], 'massa'),
  (
    ['peixe', 'tilapia', 'sardinha', 'atum', 'salmao', 'bacalhau', 'merluza'],
    'peixe',
  ),
  (['frango', 'galinha', 'coxa', 'sobrecoxa'], 'frango'),
  (
    ['carne', 'bife', 'patinho', 'acem', 'alcatra', 'moida', 'porco', 'lombo'],
    'carne',
  ),
  (['feij', 'lentilha', 'grao-de-bico'], 'feijao'),
  (
    ['legume', 'refogad', 'abobrinha', 'brocolis', 'berinjela', 'cenoura'],
    'legumes',
  ),
  (['fruta', 'banana', 'maca', 'mamao', 'manga', 'morango'], 'frutas'),
];

const _fotoDoTipo = {
  'cafe_da_manha': 'cafe',
  'almoco_jantar': 'feijao',
  'lanche': 'sanduiche',
};

/// Foto do prato: pelo título, senão pelos ingredientes, senão pelo tipo.
String fotoDe(Receita r) {
  final ingredientes = r.ingredientes
      .where((i) => !basicos.contains(i.alimento.id))
      .map((i) => i.alimento.nome)
      .join(' ');
  for (final texto in [r.titulo, ingredientes]) {
    // Espaço antes = início de palavra ("ovo" não casa com "novo").
    final t = ' ${normalizar(texto).replaceAll(',', ' ')}';
    for (final (chaves, foto) in _fotos) {
      if (chaves.any((c) => t.contains(' $c'))) return 'assets/fotos/$foto.jpg';
    }
  }
  return 'assets/fotos/${_fotoDoTipo[r.tipo] ?? 'cafe'}.jpg';
}

class ImagemReceita extends StatelessWidget {
  const ImagemReceita(this.receita, {super.key, required this.altura});

  final Receita receita;
  final double altura;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      fotoDe(receita),
      height: altura,
      width: double.infinity,
      fit: BoxFit.cover,
      // No escuro a foto fica um pouco mais apagada para não ofuscar.
      color: Cores.escuro ? Colors.black26 : null,
      colorBlendMode: BlendMode.darken,
    );
  }
}

class ReceitaCard extends StatelessWidget {
  const ReceitaCard(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final lista = receita.ingredientes
        .where((i) => !basicos.contains(i.alimento.id))
        .map((i) => '${emojiDe(i.alimento)} ${i.alimento.nomeCurto}')
        .toSet()
        .join(' • ');
    final (tem, total) = dados.cobertura(receita);

    return Container(
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Sombras.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => ReceitaTela(receita))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ImagemReceita(receita, altura: 176),
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 64,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        pilulaKcal(receita.kcal),
                        Pilula(
                          '${receita.tempoMin} min',
                          icone: Icons.schedule,
                          corIcone: Cores.primaria,
                          sombra: true,
                        ),
                        Pilula(
                          receita.dificuldade,
                          icone: Icons.thumb_up_alt_outlined,
                          corIcone: Cores.primaria,
                          sombra: true,
                        ),
                      ],
                    ),
                  ),
                  Positioned(right: 12, top: 12, child: BotaoFavorito(receita)),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    right: 12,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Pilula(
                        tem == total
                            ? '100% dos ingredientes disponíveis'
                            : 'Você tem $tem de $total ingredientes',
                        icone: Icons.check_circle,
                        fundo: Cores.verdeFixo,
                        cor: Cores.noVerdeFixo,
                        sombra: true,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      receita.titulo,
                      style: textos.titleMedium?.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Cores.superficieBaixa,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Cores.primaria,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lista,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.bodySmall?.copyWith(
                                color: Cores.textoSuave,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            'Ver receita completa',
                            overflow: TextOverflow.ellipsis,
                            style: textos.labelLarge?.copyWith(
                              color: Cores.primaria,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Cores.primaria,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoFavorito extends StatelessWidget {
  const BotaoFavorito(this.receita, {super.key});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Cores.branco.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: Sombras.leve,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          tooltip: receita.favorita ? 'Remover dos favoritos' : 'Favoritar',
          onPressed: () => dados.alternarFavorita(receita),
          icon: Icon(
            receita.favorita ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: receita.favorita ? Cores.erro : Cores.textoSuave,
          ),
        ),
      ),
    );
  }
}

/// Estado vazio ou de erro, com ação opcional.
class Aviso extends StatelessWidget {
  const Aviso({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
    this.onAcao,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Cores.superficieBaixa,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 40, color: Cores.verde),
            ),
            const SizedBox(height: 20),
            Text(titulo, textAlign: TextAlign.center, style: textos.titleLarge),
            const SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
            ),
            if (acao != null) ...[
              const SizedBox(height: 24),
              BotaoPrincipal(texto: acao!, onPressed: onAcao),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip de filtro em pílula (verde quando ativo), com contador opcional.
class ChipFiltro extends StatelessWidget {
  const ChipFiltro(
    this.texto, {
    super.key,
    required this.ativo,
    required this.onTap,
    this.contador,
    this.fundo,
  });

  final String texto;
  final bool ativo;
  final VoidCallback onTap;
  final int? contador;

  /// Padrão: [Cores.branco] da paleta ativa.
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cor = ativo ? Colors.white : Cores.textoSuave;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: ativo ? Cores.verde : fundo ?? Cores.branco,
        shape: const StadiumBorder(),
        elevation: ativo ? 1 : 0.5,
        shadowColor: const Color(0x22000000),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(texto, style: textos.labelMedium?.copyWith(color: cor)),
                if (contador != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: (ativo ? Colors.white : Cores.verde).withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$contador',
                      style: textos.labelSmall?.copyWith(
                        color: ativo ? Colors.white : Cores.verde,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto e cores do aviso de validade; null quando ainda falta bastante.
(String, Color, Color)? avisoValidade(int? dias) {
  if (dias == null || dias > diasDeAlerta) return null;
  if (dias < 0) return ('Vencido', Cores.erro, Cores.erroClaro);
  if (dias == 0) return ('Vence hoje', Cores.erro, Cores.erroClaro);
  if (dias == 1) return ('Vence amanhã', Cores.laranjaTexto, Cores.laranjaFixo);
  return ('Vence em $dias dias', Cores.laranjaTexto, Cores.laranjaFixo);
}

String formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
