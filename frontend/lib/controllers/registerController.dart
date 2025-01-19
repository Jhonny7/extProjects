import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/userModel.dart';
import '../services/userService.dart';

class RegisterController extends GetxController {
  final UserService userService = Get.put(UserService());

  final nameController = TextEditingController(); // Nuevo controlador para nombre completo
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final mailController = TextEditingController();
  final birthdateController = TextEditingController(); // Controlador de fecha de nacimiento

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void signUp() async {
    if (nameController.text.isEmpty || // Validar nombre completo
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        mailController.text.isEmpty ||
        birthdateController.text.isEmpty) { // Validar fecha de nacimiento
      errorMessage.value = 'Todos los campos son obligatorios';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Las contraseñas no coinciden';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!GetUtils.isEmail(mailController.text)) {
      errorMessage.value = 'Correo electrónico no válido';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      String fechaNacimiento = birthdateController.text; // Obtener fecha seleccionada

      UserModel newUser = UserModel(
        id: '0',
        name: nameController.text, // Incluir nombre completo
        username: usernameController.text,
        mail: mailController.text,
        password: passwordController.text,
        fechaNacimiento: fechaNacimiento,
        isProfesor: false,
        isAlumno: false,
        isAdmin: false,
      );

      final response = await userService.createUser(newUser);

      if (response == 201 || response == 204) {
        Get.snackbar('Éxito', 'Usuario registrado correctamente',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed('/login');
      } else {
        errorMessage.value = 'Error durante el registro.';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Error en signUp: $e");
      errorMessage.value = 'No se pudo conectar con el servidor.';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
