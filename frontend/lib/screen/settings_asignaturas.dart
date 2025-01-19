import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../controllers/asignaturaController.dart';
import '../controllers/userController.dart';
import '../controllers/userModelController.dart';

class SettingsAsignaturasPage extends StatefulWidget {
  @override
  _SettingsAsignaturasPageState createState() =>
      _SettingsAsignaturasPageState();
}

class _SettingsAsignaturasPageState extends State<SettingsAsignaturasPage> {
  final AsignaturaController asignaturaController =
      Get.put(AsignaturaController());
  final UserModelController userModelController =
      Get.find<UserModelController>();
  final UserController userController = Get.put(UserController());

  final List<String> selectedAsignaturas = [];
  final List<Map<String, String>> disponibilidad = [];

  @override
  void initState() {
    super.initState();
    asignaturaController.fetchAllAsignaturas();
    disponibilidad.addAll(userModelController.user.value.disponibilidad ?? []);
  }

  Future<void> saveSettings() async {
    try {
      // Actualizar asignaturas
      await asignaturaController.updateAsignaturas(
        userModelController.user.value.id,
        selectedAsignaturas,
      );

      // Actualizar disponibilidad
      await userController.updateDisponibilidad(
        userModelController.user.value.id,
        disponibilidad,
      );

      userModelController.setUser(
        id: userModelController.user.value.id,
        name: userModelController.user.value.name,
        username: userModelController.user.value.username,
        mail: userModelController.user.value.mail,
        password: '',
        fechaNacimiento: userModelController.user.value.fechaNacimiento,
        isProfesor: userModelController.user.value.isProfesor,
        isAlumno: userModelController.user.value.isAlumno,
        isAdmin: userModelController.user.value.isAdmin,
        conectado: true,
        foto: userModelController.user.value.foto,
        descripcion: userModelController.user.value.descripcion,
        disponibilidad: disponibilidad,
      );

      Get.snackbar('Éxito', 'Configuración actualizada');

      // Redirigir a la pantalla de perfil
      Get.offNamed('/usuarios');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo guardar la configuración: $e');
    }
  }

  void showMultiSelectDialog() {
    final asignaturas = asignaturaController.asignaturas.map((asignatura) {
      return MultiSelectItem<String>(
        asignatura.id,
        "${asignatura.nombre} (${asignatura.nivel})",
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return MultiSelectDialog(
          items: asignaturas,
          initialValue: selectedAsignaturas,
          title: const Text("Seleccionar Asignaturas"),
          onConfirm: (values) {
            setState(() {
              selectedAsignaturas.clear();
              selectedAsignaturas.addAll(values.cast<String>());
            });
          },
          searchable: true, // Permitir búsqueda en el selector
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaturas y Disponibilidad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botón para abrir selector múltiple
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Seleccionar Asignaturas'),
              onPressed: showMultiSelectDialog,
            ),

            // Mostrar asignaturas seleccionadas
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedAsignaturas
                  .map((id) {
                    final asignatura = asignaturaController.asignaturas
                        .firstWhereOrNull((a) => a.id == id);
                    return Chip(
                      label: Text(
                        asignatura != null
                            ? "${asignatura.nombre} (${asignatura.nivel})"
                            : 'Desconocida',
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedAsignaturas.remove(id);
                        });
                      },
                    );
                  })
                  .toList(),
            ),

            const SizedBox(height: 20),

            // Desplegable para disponibilidad
            Expanded(
              child: ListView.builder(
                itemCount: disponibilidad.length,
                itemBuilder: (context, index) {
                  final Map<String, String> disponibilidadItem =
                      disponibilidad[index];
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Día'),
                          value: disponibilidadItem['dia'],
                          items: const [
                            DropdownMenuItem(value: 'Lunes', child: Text('Lunes')),
                            DropdownMenuItem(value: 'Martes', child: Text('Martes')),
                            DropdownMenuItem(
                                value: 'Miércoles', child: Text('Miércoles')),
                            DropdownMenuItem(value: 'Jueves', child: Text('Jueves')),
                            DropdownMenuItem(value: 'Viernes', child: Text('Viernes')),
                            DropdownMenuItem(value: 'Sábado', child: Text('Sábado')),
                            DropdownMenuItem(value: 'Domingo', child: Text('Domingo')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                disponibilidad[index]['dia'] = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Turno'),
                          value: disponibilidadItem['turno'],
                          items: const [
                            DropdownMenuItem(value: 'Mañana', child: Text('Mañana')),
                            DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                disponibilidad[index]['turno'] = value;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            disponibilidad.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Botón para añadir nueva disponibilidad
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Añadir disponibilidad'),
              onPressed: () {
                setState(() {
                  disponibilidad.add({'dia': 'Lunes', 'turno': 'Mañana'});
                });
              },
            ),

            const SizedBox(height: 20),

            // Botón para guardar
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
