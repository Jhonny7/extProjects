import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/asignaturaModel.dart';
import '../controllers/authController.dart';

class AsignaturaService {
  final Dio dio = Dio();
  final String baseUrl = 'http://localhost:3000/api/asignaturas'; // Base URL correcta
  final AuthController authController = Get.find<AuthController>();

  // Obtener todas las asignaturas
  Future<List<AsignaturaModel>> getAllAsignaturas() async {
    try {
      final token = authController.getToken; // Obtener el token desde AuthController
      final response = await dio.get(
        baseUrl, // URL para obtener todas las asignaturas
        options: Options(headers: {'auth-token': token}), // Incluir token en la cabecera
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => AsignaturaModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener las asignaturas');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }
}
