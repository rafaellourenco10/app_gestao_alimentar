import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';
import 'cardapio_tela.dart';

class GerandoTela extends StatefulWidget {
  const GerandoTela({super.key});

  @override
  State<GerandoTela> createState() => _GerandoTelaState();
}

class _GerandoTelaState extends State<GerandoTela> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _gerar();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _gerar() async {
    setState(() => _erro = null);
    try {
      final receitas = await dados.gerarCardapio();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => CardapioTela(receitas)));
    } catch (e) {
      if (mounted) setState(() => _erro = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: switch (_erro) {
        null => _carregando(context),
        LimiteAtingido() => Aviso(
            emoji: '⏰',
            titulo: 'Você atingiu o limite de hoje',
            texto: 'São $limiteDiario cardápios por dia. Volte amanhã para gerar novas receitas!',
            acao: 'Voltar',
            onAcao: () => Navigator.pop(context),
          ),
        DespensaVazia() => Aviso(
            emoji: '🧺',
            titulo: 'Sua despensa está vazia',
            texto: 'Adicione alguns alimentos antes de gerar o cardápio.',
            acao: 'Voltar',
            onAcao: () => Navigator.pop(context),
          ),
        _ => Aviso(
            emoji: '😕',
            titulo: 'Não foi possível gerar o cardápio',
            texto: 'Verifique sua conexão com a internet e tente novamente.',
            acao: 'Tentar novamente',
            onAcao: _gerar,
          ),
      },
    );
  }

  Widget _carregando(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Selo('Chef IA em ação', icone: Icons.circle, fundo: Cores.verdeClaro, cor: Cores.verdeEscuro),
            const SizedBox(height: 40),
            ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.1)
                  .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut)),
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('🍳', style: TextStyle(fontSize: 68)),
              ),
            ),
            const SizedBox(height: 40),
            Text('Criando receitas com seus ingredientes…',
                textAlign: TextAlign.center,
                style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'Analisando ${dados.despensa.length == 1 ? '1 alimento' : '${dados.despensa.length} alimentos'} da sua despensa para '
              'sugerir refeições práticas e saborosas.',
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
            ),
            const SizedBox(height: 32),
            const LinearProgressIndicator(
              color: Cores.laranja,
              backgroundColor: Cores.verdeClaro,
              borderRadius: BorderRadius.all(Radius.circular(99)),
            ),
          ],
        ),
      ),
    );
  }
}
