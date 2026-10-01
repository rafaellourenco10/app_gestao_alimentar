import 'package:flutter_test/flutter_test.dart';
import 'package:nutricasa/dados.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dados d;

  setUp(() async {
    d = Dados()..atrasoFalso = Duration.zero;
    await d.carregarAlimentos();
  });

  test('TACO carrega com acentos e valores por 100 g', () {
    expect(d.alimento(489).nome, 'Ovo, de galinha, inteiro, cru');
    expect(d.alimento(489).kcal, 143);
    expect(d.alimento(272).nome, 'Óleo, de soja');
  });

  test('busca ignora acento e maiúscula, e prioriza quem começa com o termo', () {
    expect(d.buscar('OLEO SOJA').first.id, 272);
    expect(d.buscar('ovo galinha').map((a) => a.id), contains(489));
    expect(d.buscar('banana').first.nome, startsWith('Banana'));
    expect(d.buscar('   '), isEmpty);
    // nome curto: "mussarela" acha a "Queijo, mozarela" da TACO; comuns vêm antes
    expect(d.buscar('mussarela').first.id, 463);
    expect(d.buscar('peito de frango').first.id, 409);
    expect(d.buscar('ovo').first.nomeCurto, 'Ovo');
  });

  test('sugestões rápidas pulam o que já está na despensa', () async {
    expect(d.sugestoes.first.id, 489);
    await d.adicionarItem(d.alimento(489), null);
    expect(d.sugestoes.map((a) => a.id), isNot(contains(489)));
    expect(d.sugestoes.length, 5);
  });

  test('macros por porção = soma(gramas × valor/100) ÷ porções', () {
    final r = Receita(
      id: 'x',
      titulo: 't',
      tipo: 'lanche',
      tempoMin: 1,
      porcoes: 2,
      dificuldade: 'Fácil',
      criadaEm: DateTime(2026),
      passos: const [],
      ingredientes: [
        Ingrediente(d.alimento(489), 100, ''), // ovo: 143 kcal, 13 g prot
        Ingrediente(d.alimento(272), 10, ''), // óleo: 88,4 kcal, 10 g gord
      ],
    );
    expect(r.kcal, closeTo((143 + 88.4) / 2, 0.01));
    expect(r.proteina, closeTo(13 / 2, 0.01));
    expect(r.gordura, closeTo((8.9 + 10) / 2, 0.01));
  });

  test('gerar cardápio: despensa vazia, limite diário e virada do dia', () async {
    var hoje = DateTime(2026, 10, 1, 9);
    d.agora = () => hoje;

    expect(d.gerarCardapio, throwsA(isA<DespensaVazia>()));

    await d.adicionarItem(d.alimento(489), '6 un');
    for (var n = 0; n < limiteDiario; n++) {
      expect((await d.gerarCardapio()).length, 3);
    }
    expect(d.geracoesRestantes, 0);
    expect(d.gerarCardapio, throwsA(isA<LimiteAtingido>()));
    expect(d.receitas.length, 3 * limiteDiario);

    hoje = DateTime(2026, 10, 2, 0, 1);
    expect(d.geracoesRestantes, limiteDiario);
  });

  test('despensa não duplica alimento e quantidade vazia vira null', () async {
    await d.adicionarItem(d.alimento(489), '6 un');
    await d.adicionarItem(d.alimento(489), '  ');
    expect(d.despensa.length, 1);
    expect(d.despensa.single.quantidade, isNull);
    await d.removerItem(489);
    expect(d.despensa, isEmpty);
  });
}
