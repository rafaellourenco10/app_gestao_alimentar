import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema.dart';

/// Mostra assets/privacidade.md (o mesmo texto vai para a página da Play Store).
/// Só entende "## título", "- item" e parágrafos — basta para esse texto.
class PrivacidadeTela extends StatelessWidget {
  const PrivacidadeTela({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidade')),
      body: FutureBuilder(
        future: rootBundle.loadString('assets/privacidade.md'),
        builder: (context, snap) {
          final linhas = (snap.data ?? '')
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty && !l.startsWith('# '));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              for (final l in linhas)
                if (l.startsWith('## '))
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 6),
                    child: Text(l.substring(3), style: textos.titleMedium),
                  )
                else if (l.startsWith('- '))
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      '•  ${l.substring(2)}',
                      style: textos.bodyMedium,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      l,
                      style: textos.bodyMedium?.copyWith(
                        color: Cores.textoSuave,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
