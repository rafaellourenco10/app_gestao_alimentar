import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'dados.dart';
import 'tema.dart';
import 'widgets.dart';

/// Painel de voz: ouve "6 ovos, tomate e um quilo de arroz", mostra o que entendeu
/// e chama [aoConfirmar] com os itens marcados.
Future<void> mostrarVoz(
  BuildContext context, {
  required Future<void> Function(List<(Alimento, String?)>) aoConfirmar,
  String destino = 'despensa',
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Cores.fundo,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => _Voz(aoConfirmar, destino),
);

class _Voz extends StatefulWidget {
  const _Voz(this.aoConfirmar, this.destino);

  final Future<void> Function(List<(Alimento, String?)>) aoConfirmar;
  final String destino;

  @override
  State<_Voz> createState() => _VozState();
}

class _VozState extends State<_Voz> with SingleTickerProviderStateMixin {
  final _fala = SpeechToText();
  late final _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  String _texto = '';
  String? _erro;
  bool _ouvindo = false;
  ({List<(Alimento, String?)> achados, List<String> naoEntendidos})? _resultado;
  final _marcados = <int>{};

  @override
  void initState() {
    super.initState();
    _ouvir();
  }

  @override
  void dispose() {
    _pulso.dispose();
    _fala.cancel().catchError((_) {});
    super.dispose();
  }

  Future<void> _ouvir() async {
    setState(() {
      _texto = '';
      _erro = null;
      _resultado = null;
    });
    try {
      final ok = await _fala
          .initialize(
            onError: (e) {
              if (mounted && _resultado == null) {
                setState(() {
                  _ouvindo = false;
                  _pulso.stop();
                  _erro = e.errorMsg == 'error_no_match'
                      ? 'Não consegui ouvir. Tente falar mais perto do celular.'
                      : 'Não foi possível usar o microfone agora.';
                });
              }
            },
            onStatus: (s) {
              if (s == 'done' || s == 'notListening') _terminar();
            },
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      if (!ok) throw Exception();
      setState(() => _ouvindo = true);
      _pulso.repeat(reverse: true);
      await _fala.listen(
        onResult: (r) {
          if (!mounted) return;
          setState(() => _texto = r.recognizedWords);
          if (r.finalResult) _terminar();
        },
        listenOptions: SpeechListenOptions(
          localeId: 'pt_BR',
          partialResults: true,
          listenMode: ListenMode.dictation,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 30),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _ouvindo = false;
          _pulso.stop();
          _erro =
              'O reconhecimento de voz não está disponível neste celular. '
              'Verifique a permissão do microfone.';
        });
      }
    }
  }

  void _terminar() {
    if (!mounted || _resultado != null || _erro != null) return;
    _fala.stop().catchError((_) {});
    final r = interpretarFala(dados, _texto);
    setState(() {
      _ouvindo = false;
      _pulso.stop();
      _resultado = r;
      _marcados
        ..clear()
        ..addAll(r.achados.map((a) => a.$1.id));
    });
  }

  Future<void> _confirmar() async {
    await widget.aoConfirmar([
      for (final item in _resultado!.achados)
        if (_marcados.contains(item.$1.id)) item,
    ]);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final r = _resultado;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Cores.superficieAlta,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (r == null) ...[
            Text(
              _erro == null ? 'Fale os alimentos' : 'Ops!',
              textAlign: TextAlign.center,
              style: textos.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _erro ?? 'Ex.: "6 ovos, tomate e um quilo de arroz"',
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Cores.textoSuave),
            ),
            const SizedBox(height: 24),
            Center(
              child: ScaleTransition(
                scale: Tween(
                  begin: 1.0,
                  end: _ouvindo ? 1.12 : 1.0,
                ).animate(_pulso),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _erro == null ? Cores.laranja : Cores.superficie,
                    shape: BoxShape.circle,
                    boxShadow: _erro == null ? Sombras.laranja : null,
                  ),
                  child: Icon(
                    _erro == null ? Icons.mic : Icons.mic_off,
                    size: 44,
                    color: _erro == null ? Colors.white : Cores.textoSuave,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_texto.isNotEmpty)
              Text(
                '“$_texto”',
                textAlign: TextAlign.center,
                style: textos.bodyLarge,
              ),
            const SizedBox(height: 16),
            if (_ouvindo)
              TextButton(onPressed: _terminar, child: const Text('Pronto'))
            else if (_erro != null)
              TextButton(
                onPressed: _ouvir,
                child: const Text('Tentar de novo'),
              ),
          ] else ...[
            Text(
              r.achados.isEmpty
                  ? 'Não entendi nenhum alimento'
                  : 'Entendi isto:',
              style: textos.titleLarge,
            ),
            if (_texto.isNotEmpty)
              Text(
                '“$_texto”',
                style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
              ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (a, q) in r.achados)
                    CheckboxListTile(
                      value: _marcados.contains(a.id),
                      activeColor: Cores.verde,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(
                        () => v! ? _marcados.add(a.id) : _marcados.remove(a.id),
                      ),
                      secondary: Text(
                        emojiDe(a),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(a.nomeCurto, style: textos.labelLarge),
                      subtitle: q == null ? null : Text(q),
                    ),
                  if (r.naoEntendidos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Dica(
                        icone: Icons.help_outline,
                        corIcone: Cores.laranjaTexto,
                        texto:
                            'Não encontrei: ${r.naoEntendidos.join(', ')}. '
                            'Você pode buscar pelo campo de texto.',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _ouvir,
                  icon: const Icon(Icons.mic),
                  label: const Text('Falar de novo'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotaoPrincipal(
                    texto: _marcados.isEmpty
                        ? 'Nada marcado'
                        : 'Adicionar ${_marcados.length} à ${widget.destino}',
                    icone: Icons.check,
                    onPressed: _marcados.isEmpty ? null : _confirmar,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
