import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens do Stitch (stitch_strategic_plan_execution/*/code.html).
/// Superfícies trocadas do azulado do Stitch para off-white quente (PLANO.md › Visual).
class Paleta {
  const Paleta({
    required this.primaria,
    required this.verde,
    required this.verdeFixo,
    required this.noVerdeFixo,
    required this.verdeNav,
    required this.laranja,
    required this.noLaranja,
    required this.laranjaTexto,
    required this.laranjaFixo,
    required this.noLaranjaFixo,
    required this.terra,
    required this.fundo,
    required this.branco,
    required this.superficieBaixa,
    required this.superficie,
    required this.superficieAlta,
    required this.texto,
    required this.textoSuave,
    required this.contorno,
    required this.erro,
    required this.erroClaro,
  });

  final Color primaria;
  final Color verde;
  final Color verdeFixo;
  final Color noVerdeFixo;
  final Color verdeNav;
  final Color laranja;
  final Color noLaranja;
  final Color laranjaTexto;
  final Color laranjaFixo;
  final Color noLaranjaFixo;
  final Color terra;
  final Color fundo;
  final Color branco;
  final Color superficieBaixa;
  final Color superficie;
  final Color superficieAlta;
  final Color texto;
  final Color textoSuave;
  final Color contorno;
  final Color erro;
  final Color erroClaro;
}

const paletaClara = Paleta(
  primaria: Color(0xFF0D631B), // textos de destaque, links
  verde: Color(0xFF2E7D32), // primary-container: chips ativos, passos
  verdeFixo: Color(0xFFA3F69C), // primary-fixed: selos verdes
  noVerdeFixo: Color(0xFF002204),
  verdeNav: Color(0xFFCBFFC2), // pílula da aba ativa
  laranja: Color(0xFFFF8F06), // secondary-container: CTA, kcal
  noLaranja: Color(0xFF623300),
  laranjaTexto: Color(0xFF8F4E00), // secondary
  laranjaFixo: Color(0xFFFFDCC2), // secondary-fixed
  noLaranjaFixo: Color(0xFF2E1500),
  terra: Color(0xFF6B4F45), // tertiary
  fundo: Color(0xFFFAFAF7), // fundo das telas
  branco: Color(0xFFFFFFFF), // surface-container-lowest: cards
  superficieBaixa: Color(0xFFF2F2EC), // surface-container-low
  superficie: Color(0xFFEBEBE4), // surface-container
  superficieAlta: Color(0xFFE0E0D8), // surface-container-highest
  texto: Color(0xFF111D23),
  textoSuave: Color(0xFF40493D),
  contorno: Color(0xFF707A6C),
  erro: Color(0xFFBA1A1A),
  erroClaro: Color(0xFFFFDAD6),
);

/// Modo escuro: mesmas funções de cor, tons derivados do Material 3 escuro.
const paletaEscura = Paleta(
  primaria: Color(0xFF88D982),
  verde: Color(0xFF4CAF50),
  verdeFixo: Color(0xFF1E4D24),
  noVerdeFixo: Color(0xFFA3F69C),
  verdeNav: Color(0xFF24452A),
  laranja: Color(0xFFFF8F06),
  noLaranja: Color(0xFF3A1E00),
  laranjaTexto: Color(0xFFFFB77B),
  laranjaFixo: Color(0xFF4A2C10),
  noLaranjaFixo: Color(0xFFFFDCC2),
  terra: Color(0xFFE4BEB2),
  fundo: Color(0xFF121614),
  branco: Color(0xFF1C211E),
  superficieBaixa: Color(0xFF232925),
  superficie: Color(0xFF2B322D),
  superficieAlta: Color(0xFF3A423C),
  texto: Color(0xFFE6EDE7),
  textoSuave: Color(0xFFB7C2B8),
  contorno: Color(0xFF8B958C),
  erro: Color(0xFFFFB4AB),
  erroClaro: Color(0xFF5C1A16),
);

/// Cores da paleta ativa. `MaterialApp.builder` troca a paleta conforme o tema.
abstract final class Cores {
  static Paleta _atual = paletaClara;
  static bool get escuro => identical(_atual, paletaEscura);
  static set escuro(bool valor) => _atual = valor ? paletaEscura : paletaClara;

  static Color get primaria => _atual.primaria;
  static Color get verde => _atual.verde;
  static Color get verdeFixo => _atual.verdeFixo;
  static Color get noVerdeFixo => _atual.noVerdeFixo;
  static Color get verdeNav => _atual.verdeNav;
  static Color get laranja => _atual.laranja;
  static Color get noLaranja => _atual.noLaranja;
  static Color get laranjaTexto => _atual.laranjaTexto;
  static Color get laranjaFixo => _atual.laranjaFixo;
  static Color get noLaranjaFixo => _atual.noLaranjaFixo;
  static Color get terra => _atual.terra;
  static Color get fundo => _atual.fundo;
  static Color get branco => _atual.branco;
  static Color get superficieBaixa => _atual.superficieBaixa;
  static Color get superficie => _atual.superficie;
  static Color get superficieAlta => _atual.superficieAlta;
  static Color get texto => _atual.texto;
  static Color get textoSuave => _atual.textoSuave;
  static Color get contorno => _atual.contorno;
  static Color get erro => _atual.erro;
  static Color get erroClaro => _atual.erroClaro;
}

abstract final class Sombras {
  /// shadow-sm
  static const leve = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Cards de receita: 0 4 16 rgba(46,125,50,.06), 0 1 4 rgba(0,0,0,.03)
  static const card = [
    BoxShadow(color: Color(0x0F2E7D32), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// shadow-md
  static const media = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];

  /// Botão laranja principal: 0 8 24 rgba(255,143,6,.38)
  static const laranja = [
    BoxShadow(color: Color(0x61FF8F06), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Barra de navegação: 0 -4 20 rgba(0,0,0,.05)
  static const nav = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4)),
  ];
}

ThemeData criarTema({bool escuro = false}) {
  final anterior = Cores.escuro;
  Cores.escuro = escuro;
  try {
    return _tema(escuro);
  } finally {
    Cores.escuro = anterior;
  }
}

ThemeData _tema(bool escuro) {
  final esquema = ColorScheme.fromSeed(
    seedColor: Cores.verde,
    brightness: escuro ? Brightness.dark : Brightness.light,
    primary: Cores.primaria,
    primaryContainer: Cores.verde,
    secondary: Cores.laranjaTexto,
    secondaryContainer: Cores.laranja,
    surface: Cores.fundo,
    onSurface: Cores.texto,
    onSurfaceVariant: Cores.textoSuave,
    outline: Cores.contorno,
    error: Cores.erro,
  );
  final base = ThemeData(colorScheme: esquema, useMaterial3: true);
  final f = GoogleFonts.plusJakartaSansTextTheme(
    base.textTheme,
  ).apply(bodyColor: Cores.texto, displayColor: Cores.texto);

  // Escala do Stitch: headline-xl-mobile 26, headline-lg 24, headline-md 20, headline-sm 18,
  // body 16/14/12, label-lg 14, label-md 12, label-sm 11.
  final textos = f.copyWith(
    headlineMedium: f.headlineMedium?.copyWith(
      fontSize: 26,
      height: 34 / 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.26,
    ),
    headlineSmall: f.headlineSmall?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.24,
    ),
    titleLarge: f.titleLarge?.copyWith(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: f.titleMedium?.copyWith(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: f.bodyLarge?.copyWith(fontSize: 16, height: 24 / 16),
    bodyMedium: f.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14),
    bodySmall: f.bodySmall?.copyWith(fontSize: 12, height: 16 / 12),
    labelLarge: f.labelLarge?.copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.14,
    ),
    labelMedium: f.labelMedium?.copyWith(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.24,
    ),
    labelSmall: f.labelSmall?.copyWith(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.33,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundo,
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Cores.texto,
      titleTextStyle: textos.titleMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.superficieBaixa,
      hintStyle: textos.bodyMedium?.copyWith(color: Cores.contorno),
      prefixIconColor: Cores.contorno,
      suffixIconColor: Cores.contorno,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Cores.verde, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Cores.erro),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.laranja,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Cores.superficie,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Cores.primaria,
        textStyle: textos.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Cores.branco,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: textos.titleMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Cores.texto,
      actionTextColor: Cores.verdeFixo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Cores.verde),
    dividerTheme: DividerThemeData(color: Cores.superficie, space: 1),
  );
}
