import 'package:flutter/material.dart';

import '../dados.dart';
import '../tema.dart';
import '../widgets.dart';

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

    Widget aba(bool valor, IconData icone, String texto) {
      final ativo = _cadastro == valor;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _cadastro = valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: ativo ? Cores.branco : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: ativo ? Sombras.leve : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icone,
                  size: 16,
                  color: ativo ? Cores.primaria : Cores.textoSuave,
                ),
                const SizedBox(width: 6),
                Text(
                  texto,
                  style: textos.labelMedium?.copyWith(
                    color: ativo ? Cores.primaria : Cores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget rotulo(String texto, {Widget? direita}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(texto, style: textos.labelMedium)),
          ?direita,
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Cores.primaria.withValues(alpha: 0.1),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Cores.branco,
                            shape: BoxShape.circle,
                            boxShadow: Sombras.media,
                          ),
                          child: Image.asset('assets/logo.png'),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Cores.laranja,
                              shape: BoxShape.circle,
                              boxShadow: Sombras.leve,
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Pilula(
                    'Cozinha inteligente & afetuosa',
                    icone: Icons.eco_outlined,
                    fundo: Cores.verdeFixo.withValues(alpha: 0.5),
                    cor: Cores.noVerdeFixo,
                  ),
                  const SizedBox(height: 6),
                  Text('NutriCasa', style: textos.headlineMedium),
                  Text(
                    'Cozinhe com o que você já tem',
                    style: textos.titleMedium?.copyWith(color: Cores.primaria),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Economize, evite desperdício e coma bem todos os dias.',
                      textAlign: TextAlign.center,
                      style: textos.bodyMedium?.copyWith(
                        color: Cores.textoSuave,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Cartao(
                    padding: const EdgeInsets.all(16),
                    sombra: Sombras.leve,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Cores.superficieBaixa,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              aba(false, Icons.login, 'Entrar'),
                              aba(true, Icons.person_add_alt, 'Cadastrar'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        rotulo(
                          'E-mail',
                          direita: Text(
                            'Obrigatório',
                            style: textos.labelSmall?.copyWith(
                              color: Cores.contorno,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.mail_outline, size: 20),
                          ),
                          validator: (v) =>
                              v != null &&
                                  RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())
                              ? null
                              : 'Digite um e-mail válido',
                        ),
                        const SizedBox(height: 16),
                        rotulo('Senha'),
                        TextFormField(
                          controller: _senha,
                          obscureText: _ocultar,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            hintText: 'Mínimo de 6 caracteres',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              tooltip: _ocultar
                                  ? 'Mostrar senha'
                                  : 'Ocultar senha',
                              icon: Icon(
                                _ocultar
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _ocultar = !_ocultar),
                            ),
                          ),
                          validator: (v) => (v ?? '').length >= 6
                              ? null
                              : 'A senha precisa de pelo menos 6 caracteres',
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Cores.verde,
                            shape: const StadiumBorder(),
                            elevation: 2,
                          ),
                          onPressed: _enviar,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _cadastro
                                      ? 'Criar conta'
                                      : 'Entrar no NutriCasa',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ],
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
