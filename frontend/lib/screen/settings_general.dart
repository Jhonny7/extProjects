import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userModelController.dart';
import '../services/userService.dart';

class SettingsGeneralPage extends StatefulWidget {
  @override
  _SettingsGeneralPageState createState() => _SettingsGeneralPageState();
}

class _SettingsGeneralPageState extends State<SettingsGeneralPage> {
  final UserModelController userModelController = Get.find<UserModelController>();
  final UserService userService = UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = userModelController.user.value;
    nameController.text = user.name;
    usernameController.text = user.username;
    descriptionController.text = user.descripcion ?? '';
  }

  Future<void> updateUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Las contraseñas no coinciden');
      return;
    }

    try {
      final response = await userService.updateUser(
        userId: userModelController.user.value.id,
        data: {
          'nombre': nameController.text,
          'username': usernameController.text,
          'descripcion': descriptionController.text,
          if (passwordController.text.isNotEmpty) 'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        userModelController.setUser(
          id: userModelController.user.value.id,
          name: nameController.text,
          username: usernameController.text,
          mail: userModelController.user.value.mail,
          password: '',
          fechaNacimiento: userModelController.user.value.fechaNacimiento,
          isProfesor: userModelController.user.value.isProfesor,
          isAlumno: userModelController.user.value.isAlumno,
          isAdmin: userModelController.user.value.isAdmin,
          conectado: true,
          foto: userModelController.user.value.foto,
          descripcion: descriptionController.text,
        );
        Get.snackbar('Éxito', 'Datos actualizados correctamente');

        // Redirigir a la pantalla de perfil
        Get.offNamed('/usuarios');
      } else {
        Get.snackbar('Error', 'No se pudieron actualizar los datos');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un problema: $e');
    }
  }

  Future<void> confirmDeleteAccount() async {
    // Mostrar un cuadro de diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Si el usuario confirma, llama a la función de eliminación
      await deleteAccount();
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await userService.deleteUser(userModelController.user.value.id);
      if (response == 204 || response == 200) {
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Error', 'No se pudo eliminar la cuenta');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un problema: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración General'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Nueva Contraseña'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: updateUser,
                    child: Text('Actualizar'),
                  ),
                  ElevatedButton(
                    onPressed: confirmDeleteAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Eliminar Cuenta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
