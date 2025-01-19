import 'package:flutter/material.dart';

class ReviewModel {
  String id;
  String claseId;
  String autorId;
  String comentario;
  int puntuacion;
  String? nombreAlumno; // Nombre del alumno asociado a la review

  ReviewModel({
    required this.id,
    required this.claseId,
    required this.autorId,
    required this.comentario,
    required this.puntuacion,
    this.nombreAlumno, // Nuevo campo opcional
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'],
      claseId: json['clase']?['_id'] ?? '',
      autorId: json['autor']?['_id'] ?? '',
      comentario: json['contenido'] ?? 'Sin comentario',
      puntuacion: json['puntuacion'] ?? 0,
      nombreAlumno: json['autor']?['nombre'] ?? 'Desconocido', // Ajuste correcto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clase': claseId,
      'autor': autorId,
      'comentario': comentario,
      'puntuacion': puntuacion,
      'nombreAlumno': nombreAlumno, // Incluir el nombre del alumno
    };
  }
}
