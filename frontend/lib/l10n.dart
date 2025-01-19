import 'dart:ui';
import 'package:flutter/material.dart';

// Clase que gestiona la localización
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Mapa de traducciones para diferentes idiomas
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'helloWorld': 'Hello World',
      'login': 'Log In',
      'identifier': 'Email or Username',
      'password': 'Password',
      'loginButton': 'Log In',
      'noAccount': "Don't have an account? Register",
      'register': 'Register',
      'fullName': 'Full Name',
      'username': 'Username',
      'email': 'Email',
      'birthdate': 'Birthdate',
      'confirmPassword': 'Confirm Password',
      'home': 'Home',
      'classes_for_day': 'Classes for {day}:',
      'notification_title': 'Notification',
      'event_time_message': 'It\'s time for the event: {eventName}',
      'add_class': 'Add class',
      'class_name_label': 'Class name',
      'select_time_label': 'Select time:',
      'cancel': 'Cancel',
      'save': 'Save',
      'subjects_progress': 'Subjects progress:',
      'notes': 'NOTES',
      'write_notes_hint': 'Write your notes...',
      'search_users': 'Search Users',
      'profile': 'Profile',
      'subject': 'Subject',
      'level': 'Level',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'shift': 'Shift',
      'morning': 'Morning',
      'afternoon': 'Afternoon',
      'no_users_found': 'No users found.',
      'role_teacher': 'Teacher',
      'role_student': 'Student',
      'valoraciones': 'Ratings',
      'asignaturas': 'Subjects',
      'alumnos': 'Students',
      'descripcion': 'Description',
      'sin_descripcion': 'No description',
      'sin_asignaturas': 'No subjects assigned',
      'disponibilidad': 'Availability',
      'sin_disponibilidad': 'No availability set',
      'historial_clases': 'Class History',
      'historial_clases_alumno': 'This will show the student\'s class history.',
      'iniciar_chat': 'Start Chat',
      "select_role": "Select Your Role",
      "select_role_message": "Please select your role to continue:",
      "i_am_teacher": "I am a Teacher",
     "i_am_student": "I am a Student",
      "role_note": "Note: After selecting your role, we recommend updating your profile with information such as availability, description, and subjects of interest.",
      "user_profile": "User Profile",
  "ratings": "Ratings",
  "subjects": "Subjects",
  "students": "Students",
  "description": "Description",
  "no_description": "No description available",
  "subjects": "Subjects",
  "no_level_specified": "No level specified",
  "no_subjects_assigned": "No subjects assigned",
  "availability": "Availability",
  "no_availability_configured": "No availability configured",
  "class_history": "Class History",
  "class_history_description": "This is where the student's class history will be displayed.",
  "settings": "Settings",
  "update_data": "Update Data",
      },
    'es': {
      'helloWorld': 'Hola Mundo',
      'login': 'Iniciar Sesión',
      'identifier': 'Correo o Nombre de Usuario',
      'password': 'Contraseña',
      'loginButton': 'Iniciar Sesión',
      'noAccount': '¿No tienes cuenta? Regístrate',
      'register': 'Registrarse',
      'fullName': 'Nombre Completo',
      'username': 'Nombre de Usuario',
      'email': 'Correo Electrónico',
      'birthdate': 'Fecha de Nacimiento',
      'confirmPassword': 'Confirmar Contraseña',
      'home': 'Inicio',
      'classes_for_day': 'Clases para el {day}:',
      'notification_title': 'Notificación',
      'event_time_message': 'Es hora para el evento: {eventName}',
      'add_class': 'Agregar clase',
      'class_name_label': 'Nombre de la clase',
      'select_time_label': 'Selecciona la hora:',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'subjects_progress': 'Progreso de las asignaturas:',
      'notes': 'NOTAS',
      'write_notes_hint': 'Escribe tus notas...',
      'search_users': 'Buscar Usuarios',
      'profile': 'Perfil',
      'subject': 'Asignatura',
      'level': 'Nivel',
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'shift': 'Turno',
      'morning': 'Mañana',
      'afternoon': 'Tarde',
      'no_users_found': 'No se encontraron usuarios.',
      'role_teacher': 'Profesor',
      'role_student': 'Estudiante',
      'valoraciones': 'Valoraciones',
      'asignaturas': 'Asignaturas',
      'alumnos': 'Alumnos',
      'descripcion': 'Descripción',
      'sin_descripcion': 'Sin descripción',
      'sin_asignaturas': 'No tiene asignaturas asignadas',
      'disponibilidad': 'Disponibilidad',
      'sin_disponibilidad': 'No ha configurado su disponibilidad',
      'historial_clases': 'Historial de Clases',
      'historial_clases_alumno': 'Aquí se mostrará el historial de clases del alumno.',
      'iniciar_chat': 'Iniciar Chat',
       "select_role": "Selecciona tu Rol",
        "select_role_message": "Por favor, selecciona tu rol para continuar:",
        "i_am_teacher": "Soy Profesor",
        "i_am_student": "Soy Estudiante",
        "role_note": "Nota: Después de seleccionar tu rol, te recomendamos actualizar tu perfil con información como disponibilidad, descripción y asignaturas de interés.",
        "user_profile": "Perfil de Usuario",
  "ratings": "Valoraciones",
  "subjects": "Asignaturas",
  "students": "Alumnos",
  "description": "Descripción",
  "no_description": "Sin descripción",
  "subjects": "Asignaturas",
  "no_subjects_assigned": "No tienes asignaturas asignadas",
  "availability": "Disponibilidad",
  "no_availability_configured": "No has configurado tu disponibilidad",
  "class_history": "Historial de Clases",
  "class_history_description": "Aquí se mostrará el historial de clases del alumno.",
  "settings": "Configuración",
  "update_data": "Actualizar Datos",
    },
  };

  // Método para obtener la traducción de una clave
  String? translate(String key) {
    return _localizedValues[locale.languageCode]?[key];
  }

  // Método estático 'of' para acceder a las localizaciones
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Delegado requerido por Flutter para las localizaciones
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

// Delegado que carga las traducciones según el idioma
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Idiomas soportados
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Carga la clase de localización para el idioma actual
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
