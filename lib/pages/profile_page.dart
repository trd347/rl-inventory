import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _coverImage;

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        if (isProfile) {
          _profileImage = pickedFile;
        } else {
          _coverImage = pickedFile;
        }
      });
    } else {
      // Mostra un messaggio all'utente se il permesso è negato
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permesso per accedere alle foto negato.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla schermata precedente
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery, true),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(File(_profileImage!.path))
                    : null,
                child: _profileImage == null ? Icon(Icons.camera_alt) : null,
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery, false),
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey,
                child: _coverImage != null
                    ? Image.file(File(_coverImage!.path), fit: BoxFit.cover)
                    : Icon(Icons.camera_alt),
              ),
            ),
            // Sezione per le impostazioni account
            ElevatedButton(
              onPressed: () {
                // Naviga alla pagina di impostazioni account
                Navigator.pushNamed(context, '/account_settings');
              },
              child: Text('Impostazioni Account'),
            ),
            // Aggiungi qui ulteriori pulsanti o funzionalità se necessario
          ],
        ),
      ),
    );
  }
}
