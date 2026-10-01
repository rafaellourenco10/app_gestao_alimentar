import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _cadastro = false;
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_form.currentState!.validate()) return;
    dados.entrar(_email.text.trim(), _senha.text);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                        color: Cores.verdeClaro, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('🌱', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Text('NutriCasa',
                      style: textos.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Cozinhe com o que você já tem',
                      style: textos.titleMedium
                          ?.copyWith(color: Cores.verde, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Economize, evite desperdício e coma bem todos os dias.',
                      textAlign: TextAlign.center,
                      style: textos.bodyMedium?.copyWith(color: Cores.textoSuave)),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                  value: false, label: Text('Entrar'), icon: Icon(Icons.login)),
                              ButtonSegment(
                                  value: true,
                                  label: Text('Cadastrar'),
                                  icon: Icon(Icons.person_add_alt)),
                            ],
                            selected: {_cadastro},
                            onSelectionChanged: (s) => setState(() => _cadastro = s.first),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                                labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
                            validator: (v) => v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())
                                ? null
                                : 'Digite um e-mail válido',
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senha,
                            obscureText: _ocultar,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _enviar(),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                                icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _ocultar = !_ocultar),
                              ),
                            ),
                            validator: (v) => (v ?? '').length >= 6
                                ? null
                                : 'A senha precisa de pelo menos 6 caracteres',
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Cores.verde),
                            onPressed: _enviar,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(_cadastro ? 'Criar conta' : 'Entrar no NutriCasa'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
