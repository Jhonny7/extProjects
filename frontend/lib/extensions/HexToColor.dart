import 'package:flutter/material.dart';

extension HexColor on String {
  /// Convierte un string hexadecimal a un Color
  Color toColor({double opacity = 1.0}) {
    String hexString = this.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString =
          'FF$hexString'; // Si solo tiene 6 dígitos, agregar opacidad completa (FF)
    }
    return Color(int.parse('0x$hexString')).withOpacity(opacity);
  }
}
