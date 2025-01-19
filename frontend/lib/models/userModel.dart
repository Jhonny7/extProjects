import 'package:flutter/material.dart';
import '../models/asignaturaModel.dart';
import '../models/clase.dart'; // Importar el modelo ClaseModel desde el archivo específico
import '../models/review.dart'; // Importar el modelo ReviewModel desde el archivo específico

class UserModel with ChangeNotifier {
  String id;
  String name;
  String username;
  String mail;
  String password;
  String fechaNacimiento;
  bool isProfesor;
  bool isAlumno;
  bool isAdmin;
  bool conectado;
  String? foto;
  String? descripcion;
  List<Map<String, String>>? disponibilidad;
  List<AsignaturaModel>? asignaturasImparte;
  Map<String, dynamic>? location;

  // Nuevas propiedades
  double? mediaValoraciones; // Media de valoraciones del profesor
  List<ClaseModel>? historialClases; // Historial de clases del alumno
  List<ReviewModel>? reviews; // Reviews recibidas por el profesor

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.mail,
    required this.password,
    required this.fechaNacimiento,
    this.isProfesor = false,
    this.isAlumno = false,
    this.isAdmin = true,
    this.conectado = false,
    this.foto,
    this.descripcion,
    this.disponibilidad,
    this.asignaturasImparte,
    this.location,
    this.mediaValoraciones,
    this.historialClases,
    this.reviews,
  });

  // Getters para latitud y longitud
  double get lat => location?['coordinates']?[1] ?? 0.0;
  double get lng => location?['coordinates']?[0] ?? 0.0;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['nombre'] ?? 'Sin nombre',
      username: json['username'] ?? 'Sin username',
      mail: json['email'] ?? 'Sin email',
      password: '',
      fechaNacimiento: json['fechaNacimiento'] ?? 'No especificada',
      isProfesor: json['isProfesor'] ?? false,
      isAlumno: json['isAlumno'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      conectado: json['conectado'] ?? false,
      foto: json['foto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      disponibilidad: (json['disponibilidad'] as List?)
          ?.map((item) => {
                'dia': item['dia'].toString(),
                'turno': item['turno'].toString(),
              })
          .toList(),
      asignaturasImparte: (json['asignaturasImparte'] as List?)?.map((item) {
        if (item is Map<String, dynamic>) {
          return AsignaturaModel.fromJson(item);
        } else {
          return AsignaturaModel(
              id: item.toString(), nombre: 'Sin nombre', nivel: '');
        }
      }).toList(),
      location: json['location'] ?? {},
      mediaValoraciones: json['mediaValoraciones']?.toDouble(),
      historialClases: (json['historialClases'] as List?)
          ?.map((claseJson) => ClaseModel.fromJson(claseJson))
          .toList(),
      reviews: (json['reviews'] as List?)
          ?.map((reviewJson) => ReviewModel.fromJson(reviewJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': name,
      'username': username,
      'email': mail,
      'password': password,
      'fechaNacimiento': fechaNacimiento,
      'isProfesor': isProfesor,
      'isAlumno': isAlumno,
      'isAdmin': isAdmin,
      'conectado': conectado,
      'foto': foto,
      'descripcion': descripcion,
      'disponibilidad': disponibilidad,
      'asignaturasImparte': asignaturasImparte?.map((e) => e.toJson()).toList(),
      'location': location,
      'mediaValoraciones': mediaValoraciones,
      'historialClases': historialClases?.map((clase) => clase.toJson()).toList(),
      'reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return '''
    UserModel {
      id: $id,
      name: $name,
      username: $username,
      mail: $mail,
      fechaNacimiento: $fechaNacimiento,
      isProfesor: $isProfesor,
      isAlumno: $isAlumno,
      isAdmin: $isAdmin,
      conectado: $conectado,
      foto: $foto,
      descripcion: $descripcion,
      disponibilidad: $disponibilidad,
      asignaturasImparte: ${asignaturasImparte?.map((item) => item.toString()).toList()},
      location: $location,
      mediaValoraciones: $mediaValoraciones,
      historialClases: $historialClases,
      reviews: $reviews
    }
    ''';
  }
}
