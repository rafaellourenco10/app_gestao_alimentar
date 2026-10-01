import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

class PerfilTela extends StatelessWidget {
  const PerfilTela({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: dados,
      builder: (context, _) {
        final email = dados.email ?? '';
        final usuario = email.split('@').first;
        final nome = usuario.isEmpty
            ? ''
            : usuario[0].toUpperCase() + usuario.substring(1);
        final usadas = limiteDiario - dados.geracoesRestantes;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Cabecalho(
              sobrescrito: 'Conta NutriCasa',
              titulo: 'Meu perfil',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: Sombras.card,
                gradient: const LinearGradient(
                  colors: [Cores.branco, Color(0xFFEFFBEA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Cores.verdeNav, width: 3),
                    ),
                    child: Avatar(email: email, raio: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          overflow: TextOverflow.ellipsis,
                          style: textos.titleLarge,
                        ),
                        Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: textos.bodyMedium?.copyWith(
                            color: Cores.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _numero(
                  context,
                  Icons.menu_book_outlined,
                  Cores.verdeNav,
                  Cores.verde,
                  '${dados.receitas.length}',
                  'Receitas geradas',
                ),
                const SizedBox(width: 12),
                _numero(
                  context,
                  Icons.favorite_border,
                  Cores.laranjaFixo,
                  Cores.laranjaTexto,
                  '${dados.favoritas.length}',
                  'Favoritas salvas',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Cartao(
              raio: 16,
              sombra: Sombras.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Cores.verde),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Criação com IA',
                          overflow: TextOverflow.ellipsis,
                          style: textos.titleMedium,
                        ),
                      ),
                      Text(
                        '$usadas / $limiteDiario usados',
                        style: textos.labelLarge?.copyWith(color: Cores.verde),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: usadas / limiteDiario,
                      minHeight: 10,
                      color: Cores.verde,
                      backgroundColor: Cores.superficie,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Limite diário: $usadas de $limiteDiario cardápios gerados hoje.',
                    style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Cores.texto),
                      const SizedBox(width: 4),
                      Text('Renova à meia-noite', style: textos.labelMedium),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 28, 4, 10),
              child: Text(
                'AJUSTES & SUPORTE',
                style: textos.labelMedium?.copyWith(
                  color: Cores.textoSuave,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Cartao(
              raio: 16,
              sombra: Sombras.card,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _opcao(
                    context,
                    emoji: '🥗',
                    fundo: Cores.verdeNav,
                    titulo: 'Preferências alimentares',
                    subtitulo: 'Dietas, restrições e alergias',
                    emBreve: true,
                  ),
                  const Divider(indent: 72, endIndent: 16),
                  _opcao(
                    context,
                    emoji: '🔒',
                    fundo: Cores.superficieBaixa,
                    titulo: 'Política de privacidade',
                    subtitulo: 'Como cuidamos dos seus dados',
                    onTap: () => _privacidade(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Cores.erro),
                onPressed: dados.sair,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'NutriCasa v0.1.0 • Feito com afeto no Brasil',
              textAlign: TextAlign.center,
              style: textos.labelMedium?.copyWith(color: Cores.contorno),
            ),
          ],
        );
      },
    );
  }

  Widget _numero(
    BuildContext context,
    IconData icone,
    Color fundo,
    Color cor,
    String valor,
    String rotulo,
  ) {
    final textos = Theme.of(context).textTheme;
    return Expanded(
      child: Cartao(
        raio: 16,
        sombra: Sombras.card,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
              child: Icon(icone, size: 22, color: cor),
            ),
            const SizedBox(height: 8),
            Text(valor, style: textos.headlineSmall),
            Text(
              rotulo,
              textAlign: TextAlign.center,
              style: textos.labelMedium?.copyWith(color: Cores.textoSuave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcao(
    BuildContext context, {
    required String emoji,
    required Color fundo,
    required String titulo,
    required String subtitulo,
    bool emBreve = false,
    VoidCallback? onTap,
  }) {
    final textos = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: fundo,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    overflow: TextOverflow.ellipsis,
                    style: textos.bodyLarge,
                  ),
                  Text(
                    subtitulo,
                    overflow: TextOverflow.ellipsis,
                    style: textos.bodySmall?.copyWith(color: Cores.textoSuave),
                  ),
                ],
              ),
            ),
            if (emBreve)
              const Pilula(
                'Em breve',
                fundo: Cores.superficie,
                cor: Cores.textoSuave,
              )
            else
              const Icon(Icons.chevron_right, color: Cores.textoSuave),
          ],
        ),
      ),
    );
  }

  // ponytail: texto provisório; a política completa (LGPD) entra na Fase 4.
  void _privacidade(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de privacidade'),
        content: const Text(
          'O NutriCasa guarda apenas seu e-mail, os alimentos da sua despensa e as '
          'receitas geradas, para fazer o app funcionar. Para criar receitas, enviamos '
          'somente os nomes e quantidades dos alimentos ao serviço de IA — nunca seus '
          'dados pessoais.\n\nA versão completa estará disponível antes do lançamento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
