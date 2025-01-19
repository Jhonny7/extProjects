import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AsignaturaModel with ChangeNotifier{
  final String id;
  final String nombre;
  final String nivel;

  AsignaturaModel({
    required this.id,
    required this.nombre,
    required this.nivel,
  });

  factory AsignaturaModel.fromJson(Map<String, dynamic> json) {
    return AsignaturaModel(
      id: json['_id'],
      nombre: json['nombre'] ?? 'Sin nombre',
      nivel: json['nivel'] ?? 'Sin nivel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'nivel': nivel,
    };
  }
}

