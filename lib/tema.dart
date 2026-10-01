import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens do Stitch (stitch_strategic_plan_execution/*/code.html).
/// Superfícies trocadas do azulado do Stitch para off-white quente (PLANO.md › Visual).
abstract final class Cores {
  // Verdes
  static const primaria = Color(0xFF0D631B); // textos de destaque, links
  static const verde = Color(
    0xFF2E7D32,
  ); // primary-container: chips ativos, passos
  static const verdeFixo = Color(0xFFA3F69C); // primary-fixed: selos verdes
  static const noVerdeFixo = Color(0xFF002204);
  static const verdeNav = Color(0xFFCBFFC2); // pílula da aba ativa

  // Laranjas
  static const laranja = Color(0xFFFF8F06); // secondary-container: CTA, kcal
  static const noLaranja = Color(0xFF623300);
  static const laranjaTexto = Color(0xFF8F4E00); // secondary
  static const laranjaFixo = Color(0xFFFFDCC2); // secondary-fixed
  static const noLaranjaFixo = Color(0xFF2E1500);

  static const terra = Color(0xFF6B4F45); // tertiary

  // Superfícies (off-white quente)
  static const fundo = Color(0xFFFAFAF7);
  static const branco = Color(0xFFFFFFFF); // surface-container-lowest
  static const superficieBaixa = Color(0xFFF2F2EC); // surface-container-low
  static const superficie = Color(0xFFEBEBE4); // surface-container
  static const superficieAlta = Color(0xFFE0E0D8); // surface-container-highest

  // Texto
  static const texto = Color(0xFF111D23);
  static const textoSuave = Color(0xFF40493D);
  static const contorno = Color(0xFF707A6C);

  static const erro = Color(0xFFBA1A1A);
  static const erroClaro = Color(0xFFFFDAD6);
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

ThemeData criarTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Cores.verde,
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
        borderSide: const BorderSide(color: Cores.verde, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Cores.erro),
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
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Cores.verde,
    ),
    dividerTheme: const DividerThemeData(color: Cores.superficie, space: 1),
  );
}
