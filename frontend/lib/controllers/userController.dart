import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/userService.dart';
import '../controllers/authController.dart';
import '../controllers/userModelController.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart' as dio; // Usar siempre el prefijo dio

class UserController extends GetxController {
  final UserService userService = Get.put(UserService());
  final UserModelController userModelController = Get.find<UserModelController>();

  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

Future<void> logIn() async {
  if (mailController.text.isEmpty || passwordController.text.isEmpty) {
    Get.snackbar('Error', 'Todos los campos son obligatorios',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  isLoading.value = true;

  try {
    print("Iniciando proceso de login...");

    // Verificar permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permisos de ubicación denegados permanentemente. Habilítelos en la configuración.');
    }

    // Obtener las coordenadas del dispositivo
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );

    print("Coordenadas obtenidas: (${position.latitude}, ${position.longitude})");

    // Llamada al servicio de login
    final response = await userService.logIn({
      'identifier': mailController.text, // Correo o username
      'password': passwordController.text,
      'lat': position.latitude.toString(),
      'lng': position.longitude.toString(),
    });

    print("Respuesta del servidor recibida: ${response.data}");

    if (response.statusCode == 200) {
      final userData = response.data['usuario'] ?? {};
      final userId = userData['id'] ?? '0';
      final token = response.data['token'] ?? '';

      // Validar que los datos críticos estén presentes
      if (userId == '0' || token.isEmpty) {
        throw Exception('Datos críticos faltantes en la respuesta del servidor.');
      }

      // Almacenar userId y token en el AuthController
      final authController = Get.find<AuthController>();
      authController.setUserId(userId);
      authController.setToken(token);

      if (authController.getToken.isEmpty) {
        throw Exception('El token devuelto por el servidor es nulo o vacío.');
      }

      print("Token configurado correctamente: ${authController.getToken}");

      // Configurar el usuario en UserModelController
      userModelController.setUser(
        id: userId,
        name: userData['nombre'] ?? 'Desconocido',
        username: userData['username'] ?? 'No especificado',
        mail: userData['email'] ?? 'No especificado',
        password: '', // Nunca asignamos la contraseña desde el backend
        fechaNacimiento: userData['fechaNacimiento'] ?? 'Sin especificar',
        isProfesor: userData['isProfesor'] ?? false,
        isAlumno: userData['isAlumno'] ?? false,
        isAdmin: userData['isAdmin'] ?? false,
        conectado: true,
        foto: userData['foto'] ?? '',
        descripcion: userData['descripcion'] ?? '',
        disponibilidad: (userData['disponibilidad'] as List?)?.map((item) {
          return {
            'dia': item['dia'].toString(),
            'turno': item['turno'].toString(),
          };
        }).toList(),
        asignaturasImparte: userData['asignaturasImparte'] ?? [],
        location: {
          'coordinates': [position.longitude, position.latitude],
        },
      );

      print("Usuario configurado correctamente: ${userModelController.user.value}");
      print("Es profesor: ${userModelController.user.value?.isProfesor}");

      // Comprobar rol y redirigir
      checkRoleAndNavigate();
    } else {
      errorMessage.value =
          response.data['message'] ?? 'Credenciales incorrectas';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    }
  } catch (e) {
    errorMessage.value = 'Error al conectar con el servidor: $e';
    Get.snackbar('Error', errorMessage.value,
        snackPosition: SnackPosition.BOTTOM);
    print("Error durante el login: $e");
  } finally {
    isLoading.value = false;
  }
}


  void checkRoleAndNavigate() {
    final user = userModelController.user.value;

    // Agrega este print para verificar la ruta de navegación
    print('Redirigiendo a: ${!user.isProfesor && !user.isAlumno ? "/roleSelection" : "/home"}');

    if (!user.isProfesor && !user.isAlumno) {
      // Primer inicio de sesión: Redirigir a RoleSelectionPage
      Get.offAllNamed('/roleSelection');
    } else {
      // No es el primer inicio de sesión: Redirigir al Home
      Get.offAllNamed('/home');
    }
  }


  Future<void> updateDisponibilidad(String userId, List<Map<String, String>> disponibilidad) async {
    try {
      final response = await userService.updateDisponibilidad(userId, disponibilidad);
      if (response.statusCode == 200) {
        final userData = response.data['usuario'];
        userModelController.setUser(
          id: userData['_id'],
          name: userData['nombre'] ?? 'Desconocido',
          username: userData['username'] ?? 'No especificado',
          mail: userData['email'] ?? 'No especificado',
          password: '',
          fechaNacimiento: userData['fechaNacimiento'] ?? 'Sin especificar',
          isProfesor: userData['isProfesor'] ?? false,
          isAlumno: userData['isAlumno'] ?? false,
          isAdmin: userData['isAdmin'] ?? false,
          conectado: userData['conectado'] ?? false,
          foto: userData['foto'] ?? '',
          descripcion: userData['descripcion'] ?? '',
          disponibilidad: userData['disponibilidad'],
          asignaturasImparte: userData['asignaturasImparte'],
          location: userData['location'],
        );
        Get.snackbar('Éxito', 'Disponibilidad actualizada correctamente');
      } else {
        Get.snackbar('Error', 'No se pudo actualizar la disponibilidad');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un problema: $e');
    }
  }

  Future<void> fetchUserById(String userId) async {
    try {
      final dio.Response response = await userService.getUserById(userId); // Usar dio.Response
      if (response.statusCode == 200) {
        final userData = response.data;
        if (userData is Map<String, dynamic>) {
          userModelController.setUser(
            id: userData['_id'],
            name: userData['nombre'] ?? 'Desconocido',
            username: userData['username'] ?? 'No especificado',
            mail: userData['email'] ?? 'No especificado',
            password: '', // Nunca asignamos la contraseña desde el backend
            fechaNacimiento: userData['fechaNacimiento'] ?? 'Sin especificar',
            isProfesor: userData['isProfesor'] ?? false,
            isAlumno: userData['isAlumno'] ?? false,
            isAdmin: userData['isAdmin'] ?? false,
            conectado: userData['conectado'] ?? false,
            foto: userData['foto'] ?? '',
            descripcion: userData['descripcion'] ?? '',
            disponibilidad: (userData['disponibilidad'] as List?)?.map((item) {
              return {
                'dia': item['dia'].toString(),
                'turno': item['turno'].toString(),
              };
            }).toList(),
            asignaturasImparte: userData['asignaturasImparte'],
            location: userData['location'],
          );
        } else {
          throw Exception('Datos inesperados en la respuesta del servidor');
        }
      } else {
        throw Exception('Error al obtener los datos del usuario');
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo obtener los datos del usuario: $e');
    }
  }


  Future<void> assignRole(String role) async {
    try {
      final userId = Get.find<AuthController>().getUserId;
      final isProfesor = role == "profesor";
      final isAlumno = role == "alumno";

      // Llamada al servicio para actualizar el rol
      final response = await userService.updateRole(userId, isProfesor, isAlumno);

      if (response.statusCode == 200) {
        // Actualizar el modelo del usuario en el controlador
        userModelController.setUser(
          id: userModelController.user.value.id,
          name: userModelController.user.value.name,
          username: userModelController.user.value.username,
          mail: userModelController.user.value.mail,
          password: userModelController.user.value.password,
          fechaNacimiento: userModelController.user.value.fechaNacimiento,
          isProfesor: isProfesor,
          isAlumno: isAlumno,
          isAdmin: userModelController.user.value.isAdmin,
          conectado: true,
        );

        // Navegar al Home después de asignar el rol
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("Error", "No se pudo asignar el rol. Inténtalo de nuevo.");
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un problema: $e");
    }
  }
}
