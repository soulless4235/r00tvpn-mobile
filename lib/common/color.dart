import 'dart:math';

import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';

extension ColorExtension on Color {
  Color get opacity80 {
    return withValues(alpha: 0.8);
  }

  Color get opacity60 {
    return withValues(alpha: 0.6);
  }

  Color get opacity50 {
    return withValues(alpha: 0.5);
  }

  Color get opacity38 {
    return withValues(alpha: 0.38);
  }

  Color get opacity30 {
    return withValues(alpha: 0.3);
  }

  Color get opacity12 {
    return withValues(alpha: 0.12);
  }

  Color get opacity15 {
    return withValues(alpha: 0.15);
  }

  Color get opacity10 {
    return withValues(alpha: 0.1);
  }

  Color get opacity3 {
    return withValues(alpha: 0.03);
  }

  Color get opacity0 {
    return withValues(alpha: 0);
  }

  int get value32bit {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  int get alpha8bit => (0xff000000 & value32bit) >> 24;

  int get red8bit => (0x00ff0000 & value32bit) >> 16;

  int get green8bit => (0x0000ff00 & value32bit) >> 8;

  int get blue8bit => (0x000000ff & value32bit) >> 0;

  int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  Color lighten([double amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    final HSLColor hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    return hsl
        .withLightness(min(1, max(0, hsl.lightness + amount / 100)))
        .toColor();
  }

  String get hex {
    final value = toARGB32();
    final red = (value >> 16) & 0xFF;
    final green = (value >> 8) & 0xFF;
    final blue = value & 0xFF;
    return '#${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color blendDarken(BuildContext context, {double factor = 0.1}) {
    final brightness = Theme.of(context).brightness;
    return Color.lerp(
      this,
      brightness == Brightness.dark ? Colors.white : Colors.black,
      factor,
    )!;
  }
}

extension ColorSchemeExtension on ColorScheme {
  /// r00tvpn "Graphite": the desktop app's neutral surfaces in either mode,
  /// and its exact orange when [brandAccent] (the default accent) is in use.
  ColorScheme toGraphite({required bool brandAccent}) {
    final dark = brightness == Brightness.dark;
    final neutral = dark
        ? copyWith(
            surface: const Color(0xFF111317),
            onSurface: const Color(0xFFE7E9EC),
            onSurfaceVariant: const Color(0xFF9AA1AC),
            surfaceDim: const Color(0xFF0D0F12),
            surfaceBright: const Color(0xFF2A2F37),
            surfaceContainerLowest: const Color(0xFF0D0F12),
            surfaceContainerLow: const Color(0xFF14161B),
            surfaceContainer: const Color(0xFF181B21),
            surfaceContainerHigh: const Color(0xFF1F232A),
            surfaceContainerHighest: const Color(0xFF23272E),
            secondaryContainer: const Color(0xFF23272E),
            onSecondaryContainer: const Color(0xFFFFFFFF),
            outline: const Color(0xFF3A3F48),
            outlineVariant: const Color(0xFF2A2F37),
            inverseSurface: const Color(0xFFE7E9EC),
            onInverseSurface: const Color(0xFF181B21),
            error: const Color(0xFFF2685B),
            onError: const Color(0xFF2B0703),
          )
        : copyWith(
            surface: const Color(0xFFF3F3F1),
            onSurface: const Color(0xFF16181D),
            onSurfaceVariant: const Color(0xFF5C626C),
            surfaceDim: const Color(0xFFE4E4E1),
            surfaceBright: const Color(0xFFFFFFFF),
            surfaceContainerLowest: const Color(0xFFFFFFFF),
            surfaceContainerLow: const Color(0xFFFAFAF8),
            surfaceContainer: const Color(0xFFFFFFFF),
            surfaceContainerHigh: const Color(0xFFECECEA),
            surfaceContainerHighest: const Color(0xFFE4E4E1),
            secondaryContainer: const Color(0xFFECECEA),
            onSecondaryContainer: const Color(0xFF16181D),
            outline: const Color(0xFFC9CBCE),
            outlineVariant: const Color(0xFFE2E2DC),
            inverseSurface: const Color(0xFF2A2E35),
            onInverseSurface: const Color(0xFFF3F3F1),
            error: const Color(0xFFC8372D),
            onError: const Color(0xFFFFFFFF),
          );
    if (!brandAccent) {
      return neutral;
    }
    return dark
        ? neutral.copyWith(
            primary: const Color(0xFFFF8A3D),
            onPrimary: const Color(0xFF1A1206),
            primaryContainer: const Color(0xFF4A2C17),
            onPrimaryContainer: const Color(0xFFFFD2B3),
            inversePrimary: const Color(0xFFC2550A),
            surfaceTint: const Color(0xFFFF8A3D),
          )
        : neutral.copyWith(
            primary: const Color(0xFFC2550A),
            onPrimary: const Color(0xFFFFFFFF),
            primaryContainer: const Color(0xFFFFE1CC),
            onPrimaryContainer: const Color(0xFF5A2600),
            inversePrimary: const Color(0xFFFF8A3D),
            surfaceTint: const Color(0xFFC2550A),
          );
  }

  ColorScheme toPureBlack(bool isPureBlack) {
    if (!isPureBlack || brightness != Brightness.dark) {
      return this;
    }
    final shift = Hct.fromInt(surface.toARGB32()).tone;
    Color lower(Color color) {
      final hct = Hct.fromInt(color.toARGB32());
      return Color(
        Hct.from(hct.hue, hct.chroma, max(0, hct.tone - shift)).toInt(),
      );
    }

    return copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: lower(surfaceContainerLow),
      surfaceContainer: lower(surfaceContainer),
      surfaceContainerHigh: lower(surfaceContainerHigh),
      surfaceContainerHighest: lower(surfaceContainerHighest),
      surfaceBright: lower(surfaceBright),
    );
  }

  Color get modalScrim => scrim.withValues(alpha: 0.32);

  // r00tvpn: the desktop app's status colours and latency thresholds, so a
  // node reads the same on every platform
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF6FD89C)
      : const Color(0xFF1E8A55);

  Color get warning => brightness == Brightness.dark
      ? const Color(0xFFF2C66D)
      : const Color(0xFFB77C00);

  Color? delayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return error;
    if (delay < 500) return success;
    return warning;
  }
}

extension GraphiteThemeData on ThemeData {
  /// The desktop app's section bar: its sidebar colour, and labels small
  /// enough for all six sections on a phone.
  ThemeData get withGraphiteNavigationBar => copyWith(
    navigationBarTheme: navigationBarTheme.copyWith(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.surfaceContainerHighest,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          fontSize: 10,
          letterSpacing: -0.3,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
        );
      }),
    ),
  );
}
