import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores do DESIGN.md (stitch_strategic_plan_execution/), com fundo off-white.
abstract final class Cores {
  static const verde = Color(0xFF2E7D32);
  static const verdeEscuro = Color(0xFF1B5E20);
  static const verdeClaro = Color(0xFFE8F5E9);
  static const laranja = Color(0xFFFB8C00);
  static const laranjaClaro = Color(0xFFFFE0B2);
  static const laranjaTexto = Color(0xFFE65100);
  static const terra = Color(0xFF8D6E63);
  static const fundo = Color(0xFFFAFAF7);
  static const campo = Color(0xFFF1F1EB);
  static const texto = Color(0xFF263238);
  static const textoSuave = Color(0xFF5F6B66);
  static const erro = Color(0xFFE53935);
  static const erroClaro = Color(0xFFFFEBEE);
}

ThemeData criarTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Cores.verde,
    primary: Cores.verde,
    secondary: Cores.laranja,
    surface: Cores.fundo,
    onSurface: Cores.texto,
    error: Cores.erro,
  );
  final base = ThemeData(colorScheme: esquema, useMaterial3: true);
  final textos = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
      .apply(bodyColor: Cores.texto, displayColor: Cores.texto);
  final arredondado = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundo,
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Cores.texto,
      titleTextStyle: textos.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x0A000000)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.campo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Cores.verde, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.laranja,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: arredondado,
        textStyle: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Cores.verdeEscuro,
        backgroundColor: Cores.verdeClaro,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(48),
        shape: arredondado,
        textStyle: textos.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Cores.verdeClaro,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => textos.labelMedium?.copyWith(
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? Cores.verdeEscuro : Cores.textoSuave,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Cores.verdeEscuro : Cores.textoSuave,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
