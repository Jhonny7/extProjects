import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/userModelController.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:get/get.dart';
import 'dart:html' as html; // Importa html para interactuar con el navegador
import '../services/cloudinary_service.dart';
import '../helpers/image_picker_helper.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  String? _selectedImageBase64; // Para manejar la imagen seleccionada en base64
  String? _uploadedImageUrl; // URL de la imagen subida
  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePickerHelper();
  final _userService = UserService();
  final UserModelController userModelController =
      Get.find<UserModelController>();

  /// Selecciona y sube una imagen a Cloudinary
  Future<void> _selectAndUploadImage() async {
    final imageBase64 = await _imagePicker.pickImage();
    if (imageBase64 != null) {
      setState(() {
        _selectedImageBase64 = imageBase64;
      });
      final user = userModelController.user.value;

      // Subir la imagen a Cloudinary
      String? url = await _cloudinaryService.uploadImage(imageBase64);
      print(url);
      await _userService.updateUser(userId: user.id, data: {'foto': url});
      setState(() {
        user.foto = url;
        userModelController.user.value.foto = url;
        _uploadedImageUrl = url;
      });
    }
  }

  // Función para abrir la URL en el navegador usando dart:html
  void _openInBrowser(String url) {
     html.window.open(url, "_blank"); // Esto abre la URL en una nueva pestaña
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Imagen a Cloudinary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar la imagen seleccionada
            if (_selectedImageBase64 != null)
              Image.network(
                  _selectedImageBase64!), // Mostrar imagen base64 en Web
            SizedBox(height: 20),
            // Mostrar la URL subida
            if (_uploadedImageUrl != null)
              GestureDetector(
                onTap: () => _openInBrowser(
                    _uploadedImageUrl!), // Abre la URL en el navegador
                child: Text(
                  'URL subida: $_uploadedImageUrl',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            ElevatedButton(
              onPressed: _selectAndUploadImage,
              child: Text('Seleccionar y subir imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
