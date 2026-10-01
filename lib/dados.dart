import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Único ponto de acesso a dados do app (ver PLANO.md).
/// Fase 1: tudo em memória. Fases 2–3: os corpos dos métodos passam a chamar
/// Supabase / Edge Function; as telas continuam iguais.

const limiteDiario = 5;

/// Básicos que a receita pode usar mesmo fora da despensa (sal, óleo, azeite).
const basicos = {517, 272, 260};

/// Sugestões rápidas da busca vazia, na ordem em que aparecem.
const sugestoesRapidas = [
  489,
  157,
  107,
  82,
  4,
  562,
  409,
  182,
  92,
  110,
  53,
  458,
  461,
  40,
  327,
];

class Alimento {
  const Alimento({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.kcal,
    required this.proteina,
    required this.carbo,
    required this.gordura,
    required this.fibra,
    this.curto,
    this.emoji,
  });

  factory Alimento.fromJson(Map<String, dynamic> j) => Alimento(
    id: j['id'] as int,
    nome: j['nome'] as String,
    categoria: j['categoria'] as String,
    kcal: (j['kcal'] as num).toDouble(),
    proteina: (j['proteina'] as num).toDouble(),
    carbo: (j['carbo'] as num).toDouble(),
    gordura: (j['gordura'] as num).toDouble(),
    fibra: (j['fibra'] as num).toDouble(),
    curto: j['curto'] as String?,
    emoji: j['emoji'] as String?,
  );

  final int id;
  final String nome;
  final String categoria;

  /// Valores por 100 g (Tabela TACO).
  final double kcal, proteina, carbo, gordura, fibra;

  /// Nome amigável e emoji dos ~200 alimentos mais comuns (null nos demais).
  final String? curto;
  final String? emoji;

  String get nomeCurto => curto ?? nome;
}

class ItemDespensa {
  const ItemDespensa(this.alimento, this.quantidade);
  final Alimento alimento;
  final String? quantidade;
}

class Ingrediente {
  const Ingrediente(this.alimento, this.gramas, this.medida);
  final Alimento alimento;
  final double gramas;

  /// Medida caseira para exibir ("2 ovos", "1 colher de sopa").
  final String medida;
}

class Receita {
  Receita({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.tempoMin,
    required this.porcoes,
    required this.dificuldade,
    required this.ingredientes,
    required this.passos,
    required this.criadaEm,
  });

  final String id;
  final String titulo;

  /// 'cafe_da_manha' | 'almoco_jantar' | 'lanche'
  final String tipo;
  final int tempoMin;
  final int porcoes;
  final String dificuldade;
  final List<Ingrediente> ingredientes;
  final List<String> passos;
  final DateTime criadaEm;
  bool favorita = false;

  /// 1 = gostou, -1 = não gostou, null = sem resposta.
  int? feedback;

  // Macros por porção, calculados pela TACO — nunca pelo valor da IA.
  double get kcal => _porPorcao((a) => a.kcal);
  double get proteina => _porPorcao((a) => a.proteina);
  double get carbo => _porPorcao((a) => a.carbo);
  double get gordura => _porPorcao((a) => a.gordura);

  double _porPorcao(double Function(Alimento) valor) =>
      ingredientes.fold(0.0, (t, i) => t + valor(i.alimento) * i.gramas / 100) /
      porcoes;
}

class DespensaVazia implements Exception {}

class LimiteAtingido implements Exception {}

class Dados extends ChangeNotifier {
  List<Alimento> _alimentos = const [];
  Map<int, Alimento> _porId = const {};
  final List<ItemDespensa> despensa = [];

  /// Histórico de receitas geradas, mais novas primeiro.
  final List<Receita> receitas = [];
  final List<DateTime> _geracoes = [];
  String? email;

  /// Substituíveis nos testes.
  DateTime Function() agora = DateTime.now;
  Duration atrasoFalso = const Duration(seconds: 2);

  Future<void> carregarAlimentos() async {
    final lista =
        jsonDecode(await rootBundle.loadString('assets/taco.json')) as List;
    _alimentos = [
      for (final j in lista) Alimento.fromJson(j as Map<String, dynamic>),
    ];
    _porId = {for (final a in _alimentos) a.id: a};
  }

  Alimento alimento(int id) => _porId[id]!;

  /// Busca sem acento e sem diferenciar maiúsculas, no nome TACO e no nome curto.
  /// Ordem: começa com o termo › alimentos comuns › resto; depois o nome mais curto.
  List<Alimento> buscar(String termo) {
    final palavras = normalizar(
      termo,
    ).split(' ').where((p) => p.isNotEmpty).toList();
    if (palavras.isEmpty) return const [];
    int peso(Alimento a) {
      final curto = normalizar(a.curto ?? '');
      if (curto.startsWith(palavras.first)) return 0;
      final comum = a.curto != null;
      if (normalizar(a.nome).startsWith(palavras.first)) return comum ? 1 : 2;
      return comum ? 3 : 4;
    }

    final achados =
        _alimentos.where((a) {
          final texto = normalizar('${a.nome} ${a.curto ?? ''}');
          return palavras.every(texto.contains);
        }).toList()..sort((a, b) {
          final p = peso(a) - peso(b);
          return p != 0 ? p : a.nomeCurto.length - b.nomeCurto.length;
        });
    return achados.take(20).toList();
  }

  /// Sugestões rápidas que ainda não estão na despensa.
  List<Alimento> get sugestoes => [
    for (final id in sugestoesRapidas)
      if (!temNaDespensa(id)) alimento(id),
  ].take(5).toList();

  // ---------- Conta (Fase 2: Supabase Auth) ----------

  Future<void> entrar(String email, String senha) async {
    this.email = email;
    notifyListeners();
  }

  Future<void> sair() async {
    email = null;
    notifyListeners();
  }

  // ---------- Despensa ----------

  bool temNaDespensa(int alimentoId) =>
      despensa.any((i) => i.alimento.id == alimentoId);

  Future<void> adicionarItem(Alimento alimento, String? quantidade) async {
    final q = quantidade?.trim();
    despensa
      ..removeWhere((i) => i.alimento.id == alimento.id)
      ..add(ItemDespensa(alimento, q == null || q.isEmpty ? null : q));
    notifyListeners();
  }

  Future<void> removerItem(int alimentoId) async {
    despensa.removeWhere((i) => i.alimento.id == alimentoId);
    notifyListeners();
  }

  // ---------- Receitas ----------

  List<Receita> get favoritas => receitas.where((r) => r.favorita).toList();

  /// Quantos ingredientes da receita (fora os básicos) o usuário tem: (tem, total).
  (int, int) cobertura(Receita r) {
    final principais = r.ingredientes.where(
      (i) => !basicos.contains(i.alimento.id),
    );
    return (
      principais.where((i) => temNaDespensa(i.alimento.id)).length,
      principais.length,
    );
  }

  int get geracoesRestantes {
    final hoje = agora();
    final usadas = _geracoes.where((g) => DateUtils.isSameDay(g, hoje)).length;
    return (limiteDiario - usadas).clamp(0, limiteDiario);
  }

  /// Fase 3: chamar a Edge Function `gerar-cardapio` (Gemini).
  Future<List<Receita>> gerarCardapio() async {
    if (despensa.isEmpty) throw DespensaVazia();
    if (geracoesRestantes == 0) throw LimiteAtingido();
    await Future<void>.delayed(atrasoFalso);
    final momento = agora();
    final novas = _receitasDeExemplo(momento);
    _geracoes.add(momento);
    receitas.insertAll(0, novas);
    notifyListeners();
    return novas;
  }

  Future<void> alternarFavorita(Receita r) async {
    r.favorita = !r.favorita;
    notifyListeners();
  }

  Future<void> avaliar(Receita r, int nota) async {
    r.feedback = r.feedback == nota ? null : nota;
    notifyListeners();
  }

  // ponytail: 3 receitas fixas até a Fase 3 trocar pelo Gemini.
  List<Receita> _receitasDeExemplo(DateTime momento) {
    Ingrediente i(int id, double g, String medida) =>
        Ingrediente(alimento(id), g, medida);
    final base = momento.microsecondsSinceEpoch;
    return [
      Receita(
        id: '$base-1',
        titulo: 'Omelete de tomate com queijo minas',
        tipo: 'cafe_da_manha',
        tempoMin: 15,
        porcoes: 1,
        dificuldade: 'Fácil',
        criadaEm: momento,
        ingredientes: [
          i(489, 100, '2 ovos'),
          i(157, 60, '½ tomate picado'),
          i(107, 20, '¼ de cebola picada'),
          i(461, 30, '1 fatia de queijo minas'),
          i(272, 5, '1 colher de chá de óleo'),
          i(517, 1, 'Sal a gosto'),
        ],
        passos: [
          'Bata os ovos com uma pitada de sal até espumar.',
          'Aqueça o óleo numa frigideira e refogue a cebola até murchar.',
          'Despeje os ovos e espalhe o tomate e o queijo por cima.',
          'Quando dourar embaixo, dobre ao meio e sirva quente.',
        ],
      ),
      Receita(
        id: '$base-2',
        titulo: 'Arroz com frango desfiado e cenoura',
        tipo: 'almoco_jantar',
        tempoMin: 25,
        porcoes: 2,
        dificuldade: 'Fácil',
        criadaEm: momento,
        ingredientes: [
          i(409, 200, '1 filé de peito de frango'),
          i(3, 300, '2 xícaras de arroz cozido'),
          i(110, 80, '1 cenoura ralada'),
          i(107, 40, '½ cebola picada'),
          i(82, 5, '2 dentes de alho'),
          i(272, 10, '1 colher de sopa de óleo'),
          i(517, 2, 'Sal a gosto'),
        ],
        passos: [
          'Cozinhe o frango em água com sal por 15 minutos e desfie.',
          'Refogue o alho e a cebola no óleo até dourar.',
          'Junte o frango e a cenoura e mexa por 3 minutos.',
          'Acrescente o arroz, misture bem e acerte o sal.',
        ],
      ),
      Receita(
        id: '$base-3',
        titulo: 'Panqueca rápida de banana e aveia',
        tipo: 'lanche',
        tempoMin: 10,
        porcoes: 1,
        dificuldade: 'Muito fácil',
        criadaEm: momento,
        ingredientes: [
          i(182, 80, '1 banana prata'),
          i(7, 30, '3 colheres de sopa de aveia'),
          i(489, 50, '1 ovo'),
          i(272, 3, 'Um fio de óleo'),
        ],
        passos: [
          'Amasse a banana e misture com o ovo e a aveia.',
          'Aqueça uma frigideira untada com o óleo em fogo baixo.',
          'Despeje a massa e doure 2 minutos de cada lado.',
        ],
      ),
    ];
  }
}

final dados = Dados();

const _acentos = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'ê': 'e',
  'è': 'e',
  'ë': 'e',
  'í': 'i',
  'î': 'i',
  'ì': 'i',
  'ï': 'i',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ò': 'o',
  'ö': 'o',
  'ú': 'u',
  'û': 'u',
  'ù': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

String normalizar(String s) =>
    s.toLowerCase().split('').map((c) => _acentos[c] ?? c).join();

const _fracoes = {'½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3};

/// Multiplica a quantidade no começo da medida caseira: "2 ovos" ×2 → "4 ovos",
/// "½ tomate" ×2 → "1 tomate", "1,5 xícara" ×2 → "3 xícara". Sem número, devolve igual.
String escalarMedida(String medida, double fator) {
  if (fator == 1) return medida;
  final m = RegExp(
    r'^(\d+(?:[.,]\d+)?)?\s*([½¼¾⅓⅔])?(\s*)',
  ).firstMatch(medida)!;
  if (m.group(1) == null && m.group(2) == null) return medida;
  final valor =
      (m.group(1) == null
          ? 0
          : double.parse(m.group(1)!.replaceAll(',', '.'))) +
      (m.group(2) == null ? 0 : _fracoes[m.group(2)]!);
  return '${formatarNumero(valor * fator)} ${medida.substring(m.end)}'
      .trimRight();
}

/// 2.0 → "2", 1.5 → "1½", 0.25 → "¼", 2.4 → "2,4".
String formatarNumero(double v) {
  final inteiro = v.floor();
  final resto = v - inteiro;
  for (final MapEntry(key: simbolo, value: f) in _fracoes.entries) {
    if ((resto - f).abs() < 0.02) {
      return inteiro == 0 ? simbolo : '$inteiro$simbolo';
    }
  }
  if (resto < 0.02) return '$inteiro';
  if (resto > 0.98) return '${inteiro + 1}';
  return v.toStringAsFixed(1).replaceAll('.', ',');
}

/// Minutos citados no passo ("Cozinhe por 15 minutos" → 15), para o timer do modo cozinhar.
int? minutosNoPasso(String passo) {
  final m = RegExp(
    r'(\d+)\s*(?:minutos?|min)\b',
    caseSensitive: false,
  ).firstMatch(passo);
  return m == null ? null : int.parse(m.group(1)!);
}
