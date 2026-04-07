import 'package:flutter/material.dart';

class ColorHexUtils {
  const ColorHexUtils._();

  static Color? parse(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    var normalized = raw.replaceAll('#', '').toUpperCase();
    if (normalized.length == 3) {
      normalized = normalized.split('').map((char) => '$char$char').join();
    }
    if (normalized.length != 6) {
      return null;
    }

    final hexValue = int.tryParse(normalized, radix: 16);
    if (hexValue == null) {
      return null;
    }

    return Color(0xFF000000 | hexValue);
  }

  static String toHex(Color color) {
    final argb = color.toARGB32();
    final red = ((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final green = ((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final blue = (argb & 0xFF).toRadixString(16).padLeft(2, '0');
    return '#${(red + green + blue).toUpperCase()}';
  }
}
