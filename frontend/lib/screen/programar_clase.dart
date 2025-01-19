import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userModelController.dart';
import '../controllers/asignaturaController.dart';
import '../controllers/userListController.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ProgramarClasePage extends StatefulWidget {
  @override
  _ProgramarClasePageState createState() => _ProgramarClasePageState();
}

class _ProgramarClasePageState extends State<ProgramarClasePage> {
  final _formKey = GlobalKey<FormState>();
  final UserModelController userModelController = Get.find<UserModelController>();
  final AsignaturaController asignaturaController = Get.find<AsignaturaController>();
  final UserListController userListController = Get.find<UserListController>();

  String? selectedAsignaturaId;
  String? selectedAlumnoId;
  String? descripcion;
  DateTime? fechaHoraInicio;
  int? duracion;
  String searchQuery = ''; // Para manejar la búsqueda de alumnos

  @override
  void initState() {
    super.initState();
    if (userModelController.user.value.isProfesor) {
      asignaturaController.fetchAllAsignaturas();
      userListController.fetchUsers();
    } else {
      userModelController.fetchHistorialClases(userModelController.user.value.id);
    }
  }

  Future<void> _programarClase() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (fechaHoraInicio == null || duracion == null) {
        Get.snackbar('Error', 'Por favor, completa todos los campos.');
        return;
      }

      final Map<String, dynamic> claseData = {
        'asignatura': selectedAsignaturaId,
        'descripcion': descripcion,
        'fecha': fechaHoraInicio!.toIso8601String(),
        'duracion': duracion,
        'profesor': userModelController.user.value.id,
        'alumno': selectedAlumnoId,
      };

      final success = await userModelController.programarClase(claseData);

      if (success) {
        Get.back();
        Get.snackbar('Éxito', 'Clase programada correctamente.');
      } else {
        Get.snackbar('Error', 'No se pudo programar la clase.');
      }
    } else {
      Get.snackbar('Error', 'Por favor, completa todos los campos.');
    }
  }

  Future<void> _crearReview(String claseId) async {
    final TextEditingController contenidoController = TextEditingController();
    int puntuacion = 5; // Puntuación por defecto

    // Mostrar diálogo para capturar contenido y puntuación
    await Get.defaultDialog(
      title: "Dejar Review",
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contenidoController,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: puntuacion,
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} estrellas'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      puntuacion = value;
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back(result: true);
        },
        child: const Text('Guardar'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back(result: false);
        },
        child: const Text('Cancelar'),
      ),
    );

    if (contenidoController.text.isNotEmpty) {
      final Map<String, dynamic> reviewData = {
        "contenido": contenidoController.text,
        "puntuacion": puntuacion,
        "autor": userModelController.user.value.id,
        "clase": claseId,
      };

      final success = await userModelController.crearReview(reviewData);

      if (success) {
        Get.snackbar('Éxito', 'Review creada correctamente.');
        userModelController.fetchHistorialClases(userModelController.user.value.id);
      } else {
        Get.snackbar('Error', 'No se pudo crear la review.');
      }
    } else {
      Get.snackbar('Error', 'El contenido no puede estar vacío.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProfesor = userModelController.user.value.isProfesor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isProfesor ? 'Programar Clase' : 'Historial de Clases'),
      ),
      body: isProfesor ? _buildProfesorView() : _buildAlumnoView(),
    );
  }

  Widget _buildProfesorView() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dropdown para seleccionar asignatura con nivel
            Obx(() {
              if (asignaturaController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return DropdownButtonFormField<String>(
                value: selectedAsignaturaId,
                items: asignaturaController.asignaturas
                    .map((asignatura) => DropdownMenuItem(
                          value: asignatura.id,
                          child: Text(
                              '${asignatura.nombre} (${asignatura.nivel})'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedAsignaturaId = value;
                }),
                decoration: const InputDecoration(labelText: 'Asignatura'),
                validator: (value) =>
                    value == null ? 'Selecciona una asignatura' : null,
              );
            }),

            // Campo de búsqueda dinámico y Dropdown unificado
            Obx(() {
              if (userListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Buscar alumno'),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (searchQuery.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedAlumnoId,
                      items: userListController.userList
                          .where((user) =>
                              user.isAlumno &&
                              user.name.toLowerCase().contains(searchQuery))
                          .map((alumno) => DropdownMenuItem(
                                value: alumno.id,
                                child: Text(alumno.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedAlumnoId = value;
                      }),
                      decoration: const InputDecoration(labelText: 'Alumno'),
                      validator: (value) =>
                          value == null ? 'Selecciona un alumno' : null,
                    ),
                ],
              );
            }),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              onSaved: (value) => descripcion = value,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Duración (minutos)'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || int.tryParse(value) == null
                      ? 'Ingresa un número válido'
                      : null,
              onSaved: (value) => duracion = int.tryParse(value!),
            ),

            ListTile(
              title: Text(fechaHoraInicio == null
                  ? 'Seleccionar Fecha y Hora'
                  : fechaHoraInicio!.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    setState(() {
                      fechaHoraInicio = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),

            ElevatedButton(
              onPressed: _programarClase,
              child: const Text('Programar Clase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlumnoView() {
    return Obx(() {
      if (userModelController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final historial = userModelController.user.value.historialClases ?? [];

      if (historial.isEmpty) {
        return const Center(
          child: Text('No tienes clases en tu historial.'),
        );
      }

      final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

      return ListView.builder(
        itemCount: historial.length,
        itemBuilder: (context, index) {
          final clase = historial[index];
          final yaTieneReview = clase.review != null;
          final estadoFinalizada = clase.estado == 'finalizada';

          // Usa directamente clase.fecha como DateTime
          final fechaFormateada = clase.fecha != null
              ? dateFormat.format(clase.fecha!)
              : 'Fecha no disponible';

          return Card(
            child: ListTile(
              title: Text(clase.nombreAsignatura),
              subtitle: Text(
                  'Estado: ${clase.estado}\nFecha: $fechaFormateada'),
              trailing: estadoFinalizada && !yaTieneReview
                  ? ElevatedButton(
                      onPressed: () => _crearReview(clase.id),
                      child: const Text('Dejar Review'),
                    )
                  : null,
            ),
          );
        },
      );
    });
  }
}
