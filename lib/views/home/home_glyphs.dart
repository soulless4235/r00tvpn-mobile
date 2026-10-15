import 'package:fl_clash/icons/glyph.dart';

/// The desktop app's home screen icons (Lucide, ISC), on the glyph grid.
abstract final class HomeGlyphs {
  static const power = Glyph([
    GlyphPath('M12 2v10', role: GlyphRole.line),
    GlyphPath('M18.4 6.6a9 9 0 1 1-12.77.04', role: GlyphRole.line),
  ]);

  static const route = Glyph([
    GlyphCircle(6, 19, 3, role: GlyphRole.line),
    GlyphPath(
      'M9 19h8.5a3.5 3.5 0 0 0 0-7h-11a3.5 3.5 0 0 1 0-7H15',
      role: GlyphRole.line,
    ),
    GlyphCircle(18, 5, 3, role: GlyphRole.line),
  ]);

  static const globe = Glyph([
    GlyphCircle(12, 12, 10, role: GlyphRole.line),
    GlyphPath(
      'M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20',
      role: GlyphRole.line,
    ),
    GlyphPath('M2 12h20', role: GlyphRole.line),
  ]);

  static const chevronsRight = Glyph([
    GlyphPath('m6 17 5-5-5-5', role: GlyphRole.line),
    GlyphPath('m13 17 5-5-5-5', role: GlyphRole.line),
  ]);

  static const calendarClock = Glyph([
    GlyphPath(
      'M21 7.5V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h3.5',
      role: GlyphRole.line,
    ),
    GlyphPath('M16 2v4M8 2v4M3 10h5', role: GlyphRole.line),
    GlyphPath('M17.5 17.5 16 16.3V14', role: GlyphRole.line),
    GlyphCircle(16, 16, 6, role: GlyphRole.line),
  ]);

  static const infinity = Glyph([
    GlyphPath(
      'M12 12c-2-2.67-4-4-6-4a4 4 0 1 0 0 8c2 0 4-1.33 6-4Zm0 0c2 2.67 4 4 6 4a4 4 0 0 0 0-8c-2 0-4 1.33-6 4Z',
      role: GlyphRole.line,
    ),
  ]);

  static const gauge = Glyph([
    GlyphPath('m12 14 4-4', role: GlyphRole.line),
    GlyphPath('M3.34 19a10 10 0 1 1 17.32 0', role: GlyphRole.line),
  ]);

  static const wifiOff = Glyph([
    GlyphPath('M12 20h.01', role: GlyphRole.line),
    GlyphPath('M8.5 16.43a5 5 0 0 1 7 0', role: GlyphRole.line),
    GlyphPath('M2 8.82a15 15 0 0 1 4.17-2.65', role: GlyphRole.line),
    GlyphPath('M10.66 5c4.01-.36 8.14.9 11.34 3.76', role: GlyphRole.line),
    GlyphPath('M16.85 11.25a10 10 0 0 1 2.22 1.68', role: GlyphRole.line),
    GlyphPath('M5 13a10 10 0 0 1 5.24-2.76', role: GlyphRole.line),
    GlyphPath('m2 2 20 20', role: GlyphRole.line),
  ]);
}
