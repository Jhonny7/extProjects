import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/bottomNavigationBar.dart';
import '../screen/logIn.dart';
import '../screen/register.dart';
import '../screen/user.dart';
import '../screen/home.dart';
import '../screen/programar_clase.dart';
import '../screen/settings_general.dart'; // Importa la pantalla de configuración general
import '../screen/settings_asignaturas.dart'; // Importa la pantalla de configuración de asignaturas
import '../controllers/authController.dart';
import 'screen/perfil.dart';
import '../controllers/userListController.dart';
import '../controllers/userModelController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/userController.dart';
import '../screen/chat.dart';
import '../controllers/socketController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart'; // Asegúrate de tener el LocaleController
import '../screen/mapPage.dart';
import '../screen/roleSelectionPage.dart'; // Importa tu pantalla de selección de rol
import '../controllers/asignaturaController.dart'; // Importa el controlador de asignaturas
import 'l10n.dart'; // Asegúrate de tener esta clase generada
import 'package:flutter_localizations/flutter_localizations.dart'; // Importa las localizaciones globales

void main() {
  // Inicializa los controladores
  Get.put(AuthController());
  Get.put<UserListController>(UserListController());
  Get.put<UserModelController>(UserModelController());
  Get.put(ConnectedUsersController());
  Get.put(SocketController());
  Get.put(ThemeController()); // Registrar el controlador del tema
  Get.put(LocaleController()); // Registrar el controlador de locales
  Get.put(AsignaturaController()); // Registrar el controlador de asignaturas
  Get.put<UserController>(UserController()); // Registrar el UserController

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find(); // Obtiene el controlador del tema
    final LocaleController localeController = Get.find(); // Obtiene el controlador de locales

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Página de inicio
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ), // Tema claro
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1C1C1E),
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C2C2E),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ), // Tema oscuro
        themeMode: themeController.themeMode.value, // Controlador del tema reactivo
        getPages: [
          GetPage(
            name: '/login',
            page: () => LogInPage(),
          ),
          GetPage(
            name: '/register',
            page: () => RegisterPage(),
          ),
          GetPage(
            name: '/home',
            page: () => BottomNavScaffold(child: HomePage()),
          ),
          GetPage(
            name: '/usuarios',
            page: () => BottomNavScaffold(
              child: UserPage(),
            ),
          ),
          GetPage(
            name: '/perfil',
            page: () => PerfilPage(),
          ),
          GetPage(
            name: '/chat',
            page: () => ChatPage(
              receiverId: Get.arguments['receiverId'],
              receiverName: Get.arguments['receiverName'],
            ),
          ),
          GetPage(
            name: '/map',
            page: () => MapPage(),
          ),
          GetPage(
            name: '/roleSelection',
            page: () => RoleSelectionPage(), // Asegúrate de tener esta pantalla implementada
          ),
          // Nuevas rutas añadidas
          GetPage(
            name: '/settings_general',
            page: () => SettingsGeneralPage(),
          ),
          GetPage(
            name: '/programar_clase',
            page: () => ProgramarClasePage(),
          ),
          GetPage(
            name: '/settings_asignaturas',
            page: () => SettingsAsignaturasPage(),
          ),
        ],

        localizationsDelegates: [
          AppLocalizations.delegate, // Delegado de traducciones generado por Flutter
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // Inglés
          const Locale('es', ''), // Español
        ],
        locale: localeController.currentLocale.value, // Controlador para el idioma actual
      );
    });
  }
}
