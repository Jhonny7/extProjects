import 'package:get/get.dart';
import '../models/clase.dart';
import '../services/claseService.dart';

class ClaseController extends GetxController {
  final ClaseService claseService = Get.put(ClaseService());
  var clases = <ClaseModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Obtener el historial de clases de un alumno
  Future<void> fetchClases(String alumnoId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final clasesData = await claseService.getClasesPorAlumno(alumnoId);
      clases.assignAll(clasesData);
    } catch (e) {
      errorMessage.value = 'Error al cargar las clases';
    } finally {
      isLoading.value = false;
    }
  }

  // Crear una clase
    Future<void> crearClase(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
        await claseService.crearClase(data);
        Get.snackbar('Éxito', 'Clase creada correctamente');
    } catch (e) {
        errorMessage.value = 'Error al crear la clase: $e';
        Get.snackbar('Error', errorMessage.value);
    } finally {
        isLoading.value = false;
    }
    }

}
