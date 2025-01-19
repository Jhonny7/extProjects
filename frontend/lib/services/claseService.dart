import 'package:dio/dio.dart';
import '../models/clase.dart';
import '../models/review.dart';

class ClaseService {
  final Dio dio = Dio();
  final String baseUrl = 'http://localhost:3000/api/clases';

  Future<List<ClaseModel>> getClasesPorAlumno(String alumnoId) async {
    final response = await dio.get('$baseUrl/$alumnoId/alumno');
    return (response.data as List).map((json) => ClaseModel.fromJson(json)).toList();
  }

  // Crear una clase
    Future<void> crearClase(Map<String, dynamic> data) async {
    try {
        final response = await dio.post(baseUrl, data: data);
        if (response.statusCode != 201) {
        throw Exception('Error al crear la clase');
        }
    } catch (e) {
        throw Exception('Error al conectar con el servidor: $e');
    }
    }
}


