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
        final nome = email.split('@').first;
        final usadas = limiteDiario - dados.geracoesRestantes;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Cabecalho(sobrescrito: 'Conta NutriCasa', titulo: 'Meu perfil'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Cores.verdeClaro,
                    child: Text(nome.isEmpty ? '?' : nome[0].toUpperCase(),
                        style: textos.headlineSmall?.copyWith(
                            color: Cores.verdeEscuro, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(nome,
                          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(email, style: textos.bodyMedium?.copyWith(color: Cores.textoSuave)),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _numero(context, Icons.menu_book_outlined, '${dados.receitas.length}', 'Receitas geradas'),
              const SizedBox(width: 12),
              _numero(context, Icons.favorite_border, '${dados.favoritas.length}', 'Favoritas'),
            ]),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.bolt, color: Cores.verde),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Criação com IA',
                          overflow: TextOverflow.ellipsis,
                          style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text('$usadas / $limiteDiario usados',
                        style: textos.labelLarge
                            ?.copyWith(color: Cores.verde, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: usadas / limiteDiario,
                    minHeight: 8,
                    color: Cores.verde,
                    backgroundColor: Cores.campo,
                    borderRadius: const BorderRadius.all(Radius.circular(99)),
                  ),
                  const SizedBox(height: 8),
                  Text('Limite diário de $limiteDiario cardápios. Renova à meia-noite.',
                      style: textos.bodySmall?.copyWith(color: Cores.textoSuave)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(children: [
                const ListTile(
                  enabled: false,
                  leading: Text('🥗', style: TextStyle(fontSize: 24)),
                  title: Text('Preferências alimentares'),
                  subtitle: Text('Dietas, restrições e alergias'),
                  trailing: Selo('Em breve', fundo: Cores.campo),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Text('🔒', style: TextStyle(fontSize: 24)),
                  title: const Text('Política de privacidade'),
                  subtitle: const Text('Como cuidamos dos seus dados'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _privacidade(context),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Cores.erro),
              onPressed: dados.sair,
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
            ),
          ],
        );
      },
    );
  }

  Widget _numero(BuildContext context, IconData icone, String valor, String rotulo) {
    final textos = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Icon(icone, color: Cores.verde),
            const SizedBox(height: 6),
            Text(valor, style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(rotulo, style: textos.bodySmall?.copyWith(color: Cores.textoSuave)),
          ]),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi')),
        ],
      ),
    );
  }
}
