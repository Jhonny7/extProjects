import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registerController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart';
import '../l10n.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController registerController = Get.put(RegisterController());
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localization?.translate('register') ?? 'Register'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.textTheme.bodyLarge?.color,
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: themeController.themeMode.value == ThemeMode.dark
                        ? [const Color(0xFF6366F1), const Color(0xFF3B82F6)]
                        : [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  size: 50,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Campo Nombre Completo
            _buildTextField(
              controller: registerController.nameController,
              label: localization?.translate('fullName') ?? 'Full Name',
              icon: Icons.person,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Campo Nombre de Usuario
            _buildTextField(
              controller: registerController.usernameController,
              label: localization?.translate('username') ?? 'Username',
              icon: Icons.person_outline,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Campo Correo Electrónico
            _buildTextField(
              controller: registerController.mailController,
              label: localization?.translate('email') ?? 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Selector de Fecha de Nacimiento
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: registerController.birthdateController,
                  decoration: InputDecoration(
                    labelText: localization?.translate('birthdate') ?? 'Birthdate',
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Campo Contraseña
            _buildTextField(
              controller: registerController.passwordController,
              label: localization?.translate('password') ?? 'Password',
              icon: Icons.lock,
              obscureText: true,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Campo Confirmar Contraseña
            _buildTextField(
              controller: registerController.confirmPasswordController,
              label: localization?.translate('confirmPassword') ?? 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              theme: theme,
            ),
            const SizedBox(height: 24),

            // Botón para Registrarse
            Obx(() {
              if (registerController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: theme.primaryColor),
                );
              } else {
                return ElevatedButton(
                  onPressed: registerController.signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.primaryColor,
                  ),
                  child: Text(
                    localization?.translate('register') ?? 'Register',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      registerController.birthdateController.text = formattedDate;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        labelStyle: theme.textTheme.bodyMedium,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }
}
