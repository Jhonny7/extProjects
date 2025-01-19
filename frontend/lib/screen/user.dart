import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/localeController.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:get/get.dart';
import '../controllers/userModelController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/userController.dart';
import '../controllers/authController.dart';
import 'dart:html' as html;
import '../helpers/image_picker_helper.dart';
import '../services/cloudinary_service.dart';
import '../screen/upload_image_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n.dart';
import '../controllers/localeController.dart';
import 'dart:html' as html;
import '../helpers/image_picker_helper.dart';
import '../services/cloudinary_service.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserModelController userModelController =
      Get.find<UserModelController>();

  final ThemeController themeController = Get.find<ThemeController>();

  final UserController userController = Get.put(UserController());

  final LocaleController localeController = Get.find<LocaleController>();

  final ImagePickerHelper _imagePicker = ImagePickerHelper();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final _userService = UserService();

  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

  Future<void> _loadProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImageUrl');
    });
  }

  Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', url);
  }

  Future<void> _selectAndUploadProfileImage() async {
    final user = userModelController.user.value;

    final imageBase64 = await _imagePicker.pickImage();
    if (imageBase64 != null) {
      String? imageUrl = await _cloudinaryService.uploadImage(imageBase64);
      print("esta es la url$imageUrl");
      await _userService.updateUser(userId: user.id, data: {'foto': imageUrl});
      if (imageUrl != null) {
        setState(() {
          user.foto = imageUrl;
          userModelController.user.value.foto = imageUrl;
          _profileImageUrl = imageUrl;
        });
        _saveProfileImageUrl(imageUrl);
      } else {
        Get.snackbar('Error', 'No se pudo subir la imagen.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Actualizar los datos del usuario al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      final userId = authController.getUserId;
      if (userId.isNotEmpty) {
        userController.fetchUserById(userId);

        if (userModelController.user.value.isProfesor) {
          userModelController.fetchReviews(userId);
        } else if (userModelController.user.value.isAlumno) {
          userModelController.fetchHistorialClases(userId);
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('user_profile') ??
            'Perfil de Usuario'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.language, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {
              if (localeController.currentLocale.value.languageCode == 'es') {
                localeController.changeLanguage('en');
              } else {
                localeController.changeLanguage('es');
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectAndUploadProfileImage,
        child: const Icon(Icons.upload),
        tooltip: 'Subir foto de perfil',
      ),
      body: Obx(() {
        final user = userModelController.user.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Cabecera con avatar y descripción
              _buildUserHeader(theme, user),

              // Lógica para mostrar vistas específicas según el rol
              if (user.isProfesor) ...[
                _buildProfesorView(theme, user),
              ] else if (user.isAlumno) ...[
                _buildAlumnoView(theme, user),
              ],

              // Botones de configuración
              const SizedBox(height: 20),
              _buildConfigButtons(theme),
            ],
          ),
        );
      }),
    );
  }

  // Header compartido para ambos roles
  Widget _buildUserHeader(ThemeData theme, dynamic user) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.8),
                theme.primaryColorDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.foto != null && user.foto!.isNotEmpty
                      ? NetworkImage(user.foto!)
                      : null,
                  child: user.foto == null || user.foto!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.mail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (user.descripcion != null && user.descripcion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      user.descripcion!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Vista específica para profesores
  Widget _buildProfesorView(ThemeData theme, dynamic user) {
    final alumnosUnicos = user.reviews != null
        ? user.reviews!.map((review) => review.nombreAlumno).toSet().length
        : 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatisticCard(
                theme,
                Icons.star,
                'Media Valoraciones',
                user.mediaValoraciones?.toStringAsFixed(1) ?? '0.0',
              ),
              _buildStatisticCard(
                theme,
                Icons.book,
                'Asignaturas',
                '${user.asignaturasImparte?.length ?? 0}',
              ),
              _buildStatisticCard(
                theme,
                Icons.group,
                'Alumnos Ayudados',
                '$alumnosUnicos',
              ),
            ],
          ),
        ),

        // Sección de Asignaturas
        _buildSectionContainer(
          theme,
          'Asignaturas',
          user.asignaturasImparte != null && user.asignaturasImparte!.isNotEmpty
              ? Column(
                  children: user.asignaturasImparte!.map<Widget>((asignatura) {
                    return ListTile(
                      leading: Icon(Icons.book, color: theme.iconTheme.color),
                      title: Text(asignatura.nombre),
                      subtitle: Text('Nivel: ${asignatura.nivel}'),
                    );
                  }).toList(),
                )
              : Text('No tienes asignaturas registradas.',
                  style: theme.textTheme.bodyMedium),
        ),

        // Sección de Disponibilidad
        _buildSectionContainer(
          theme,
          'Disponibilidad',
          user.disponibilidad != null && user.disponibilidad!.isNotEmpty
              ? Column(
                  children: user.disponibilidad!.map<Widget>((dispo) {
                    return ListTile(
                      leading:
                          Icon(Icons.access_time, color: theme.iconTheme.color),
                      title: Text('Día: ${dispo['dia']}'),
                      subtitle: Text('Turno: ${dispo['turno']}'),
                    );
                  }).toList(),
                )
              : Text('No tienes disponibilidad registrada.',
                  style: theme.textTheme.bodyMedium),
        ),

        // Reviews
        _buildSectionContainer(
          theme,
          'Reviews Recibidas',
          user.reviews != null && user.reviews!.isNotEmpty
              ? Column(
                  children: user.reviews!.map<Widget>((review) {
                    return ListTile(
                      title: Text(
                          'Alumno: ${review.nombreAlumno ?? "Desconocido"}'),
                      subtitle: Text('Comentario: ${review.comentario}'),
                      trailing: Text('Puntuación: ${review.puntuacion}'),
                    );
                  }).toList(),
                )
              : Text('No tienes reviews registradas.',
                  style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  // Vista específica para alumnos
  Widget _buildAlumnoView(ThemeData theme, dynamic user) {
    return Column(
      children: [
        // Historial de Clases
        _buildSectionContainer(
          theme,
          'Historial de Clases',
          user.historialClases != null && user.historialClases!.isNotEmpty
              ? Column(
                  children: user.historialClases!.map<Widget>((clase) {
                    return ListTile(
                      title: Text('Asignatura: ${clase.nombreAsignatura}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado: ${clase.estado}'),
                          Text('Fecha: ${clase.fecha ?? "No registrada"}'),
                          Text(
                              'Profesor: ${clase.nombreProfesor ?? "No registrado"}'),
                        ],
                      ),
                      trailing:
                          clase.estado == 'finalizada' && clase.review == null
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Lógica para realizar una review
                                  },
                                  child: const Text('Hacer Review'),
                                )
                              : null,
                    );
                  }).toList(),
                )
              : Text('No tienes clases registradas.',
                  style: theme.textTheme.bodyMedium),
        ),

        // Asignaturas
        _buildSectionContainer(
          theme,
          'Asignaturas',
          user.asignaturasImparte != null && user.asignaturasImparte!.isNotEmpty
              ? Column(
                  children: user.asignaturasImparte!.map<Widget>((asignatura) {
                    return ListTile(
                      leading: Icon(Icons.book, color: theme.iconTheme.color),
                      title: Text(asignatura.nombre),
                      subtitle: Text('Nivel: ${asignatura.nivel}'),
                    );
                  }).toList(),
                )
              : Text('No tienes asignaturas registradas.',
                  style: theme.textTheme.bodyMedium),
        ),

        // Disponibilidad
        _buildSectionContainer(
          theme,
          'Disponibilidad',
          user.disponibilidad != null && user.disponibilidad!.isNotEmpty
              ? Column(
                  children: user.disponibilidad!.map<Widget>((dispo) {
                    return ListTile(
                      leading:
                          Icon(Icons.access_time, color: theme.iconTheme.color),
                      title: Text('Día: ${dispo['dia']}'),
                      subtitle: Text('Turno: ${dispo['turno']}'),
                    );
                  }).toList(),
                )
              : Text('No tienes disponibilidad registrada.',
                  style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  // Botones de configuración
  Widget _buildConfigButtons(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/settings_general')!.then((_) {
                final authController = Get.find<AuthController>();
                final userId = authController.getUserId;
                if (userId.isNotEmpty) {
                  userController.fetchUserById(userId);
                }
              });
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configuración'),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/settings_asignaturas')!.then((_) {
                final authController = Get.find<AuthController>();
                final userId = authController.getUserId;
                if (userId.isNotEmpty) {
                  userController.fetchUserById(userId);
                }
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Actualizar Datos'),
          ),
        ],
      ),
    );
  }

  // Tarjeta para estadísticas
  Widget _buildStatisticCard(
      ThemeData theme, IconData icon, String label, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 120,
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Contenedor de sección
  Widget _buildSectionContainer(ThemeData theme, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
