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

  test(
    'gerar cardápio: despensa vazia, limite diário e virada do dia',
    () async {
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
    },
  );

  test('despensa não duplica alimento e quantidade vazia vira null', () async {
    await d.adicionarItem(d.alimento(489), '6 un');
    await d.adicionarItem(d.alimento(489), '  ');
    expect(d.despensa.length, 1);
    expect(d.despensa.single.quantidade, isNull);
    await d.removerItem(489);
    expect(d.despensa, isEmpty);
  });

  test('escalar medida caseira para outras porções', () {
    expect(escalarMedida('2 ovos', 2), '4 ovos');
    expect(escalarMedida('½ tomate picado', 2), '1 tomate picado');
    expect(
      escalarMedida('1 filé de peito de frango', 1.5),
      '1½ filé de peito de frango',
    );
    expect(escalarMedida('1,5 xícara de leite', 2), '3 xícara de leite');
    expect(
      escalarMedida('3 colheres de sopa de aveia', 1 / 3),
      '1 colheres de sopa de aveia',
    );
    expect(escalarMedida('Sal a gosto', 3), 'Sal a gosto');
    expect(escalarMedida('2 ovos', 1), '2 ovos');
    expect(formatarNumero(2.4), '2,4');
    expect(formatarNumero(0.25), '¼');
  });

  test('minutos citados no passo viram timer', () {
    expect(minutosNoPasso('Cozinhe o frango por 15 minutos e desfie.'), 15);
    expect(minutosNoPasso('Doure 2 minutos de cada lado.'), 2);
    expect(minutosNoPasso('Mexa por 1 minuto.'), 1);
    expect(minutosNoPasso('Asse por 40 min.'), 40);
    expect(minutosNoPasso('Sirva quente.'), isNull);
  });

  test('cozinhei: quanto sobra na despensa', () {
    final ovo2 = Ingrediente(d.alimento(489), 100, '2 ovos');
    final frango = Ingrediente(
      d.alimento(409),
      200,
      '1 filé de peito de frango',
    );
    final sal = Ingrediente(d.alimento(517), 1, 'Sal a gosto');
    expect(quantidadeDepois('6 un', ovo2, 1), (nova: '4 un', acabou: false));
    expect(quantidadeDepois('6 un', ovo2, 2), (nova: '2 un', acabou: false));
    expect(quantidadeDepois('2 un', ovo2, 1), (nova: null, acabou: true));
    expect(quantidadeDepois('1 dúzia', ovo2, 1), (
      nova: '10 un',
      acabou: false,
    ));
    expect(quantidadeDepois('500 g', frango, 1), (
      nova: '300 g',
      acabou: false,
    ));
    expect(quantidadeDepois('1 kg', frango, 1), (
      nova: '0,8 kg',
      acabou: false,
    ));
    expect(quantidadeDepois('1,5 kg', frango, 1), (
      nova: '1,3 kg',
      acabou: false,
    ));
    expect(quantidadeDepois(null, ovo2, 1), (nova: null, acabou: false));
    expect(quantidadeDepois('1 pacote', sal, 1), (
      nova: '1 pacote',
      acabou: false,
    ));
    expect(quantidadeDepois('um pouco', ovo2, 1), (
      nova: 'um pouco',
      acabou: false,
    ));
  });

  test('registrar cozinhado atualiza e remove itens da despensa', () async {
    await d.adicionarItem(d.alimento(489), '6 un');
    await d.adicionarItem(d.alimento(157), '1 un');
    final r = (await d.gerarCardapio()).first;
    await d.registrarCozinhado(r, {489: '4 un', 157: null});
    expect(d.despensa.single.quantidade, '4 un');
    expect(d.cozinhados.single.aproveitados, 2);
  });

  test('validade: dias para vencer e lista dos que estão vencendo', () async {
    d.agora = () => DateTime(2026, 10, 1, 20);
    await d.adicionarItem(
      d.alimento(489),
      '6 un',
      validade: DateTime(2026, 10, 20),
    );
    await d.adicionarItem(
      d.alimento(157),
      '2 un',
      validade: DateTime(2026, 10, 2),
    );
    await d.adicionarItem(
      d.alimento(182),
      null,
      validade: DateTime(2026, 9, 30),
    );
    await d.adicionarItem(d.alimento(4), '1 pacote');
    expect(d.diasParaVencer(d.despensa[1]), 1);
    expect(d.diasParaVencer(d.despensa[2]), -1);
    expect(d.diasParaVencer(d.despensa[3]), isNull);
    expect(d.vencendo.map((i) => i.alimento.id), [182, 157]);
    // cozinhar mantém a validade de quem sobrou
    final r = (await d.gerarCardapio()).first;
    await d.registrarCozinhado(r, {489: '4 un'});
    expect(d.despensa.first.validade, DateTime(2026, 10, 20));
  });
}
