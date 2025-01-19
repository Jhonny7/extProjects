import 'package:get/get.dart';
import '../models/asignaturaModel.dart';
import '../services/userService.dart';

class AsignaturaController extends GetxController {
  final UserService userService = Get.put(UserService());
  var asignaturas = <AsignaturaModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Método para cargar asignaturas del usuario logueado
  Future<void> fetchAsignaturas(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final asignaturasData = await userService.getAsignaturasByUser(userId);
      asignaturas.assignAll(asignaturasData);
    } catch (e) {
      errorMessage.value = 'Error al cargar las asignaturas';
    } finally {
      isLoading.value = false;
    }
  }

  // Método para cargar todas las asignaturas de la base de datos
  Future<void> fetchAllAsignaturas() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final asignaturasData = await userService.getAllAsignaturas();
      asignaturas.assignAll(asignaturasData);
    } catch (e) {
      errorMessage.value = 'Error al cargar todas las asignaturas';
    } finally {
      isLoading.value = false;
    }
  }

  // Método para actualizar las asignaturas del usuario
  Future<void> updateAsignaturas(String userId, List<String> asignaturaIds) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await userService.updateAsignaturas(userId, asignaturaIds);
      await fetchAsignaturas(userId); // Recargar asignaturas después de actualizar
    } catch (e) {
      errorMessage.value = 'Error al actualizar las asignaturas';
    } finally {
      isLoading.value = false;
    }
  }
}
