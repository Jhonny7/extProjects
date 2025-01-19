import 'package:flutter/material.dart';

class ClaseModel {
  String id;
  String nombreAsignatura;
  String estado; // 'finalizada', 'pendiente'
  String? review;
  DateTime? fecha; // Cambiar a DateTime para manejar fechas correctamente
  String? nombreProfesor; // Nombre del profesor
  bool tieneReview; // Indica si la clase tiene una review

  ClaseModel({
    required this.id,
    required this.nombreAsignatura,
    required this.estado,
    this.review,
    this.fecha,
    this.nombreProfesor,
    this.tieneReview = false,
  });

  factory ClaseModel.fromJson(Map<String, dynamic> json) {
    return ClaseModel(
      id: json['_id'] ?? '',
      nombreAsignatura: json['asignatura']?['nombre'] ?? 'Sin asignatura',
      estado: json['estado'] ?? 'pendiente',
      review: json['review'],
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
      nombreProfesor: json['profesor']?['nombre'] ?? 'Sin nombre',
      tieneReview: json['review'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombreAsignatura': nombreAsignatura,
      'estado': estado,
      'review': review,
      'fecha': fecha?.toIso8601String(),
      'nombreProfesor': nombreProfesor,
      'tieneReview': tieneReview,
    };
  }
}
