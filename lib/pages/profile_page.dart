import 'dart:convert'; // Per la codifica e decodifica base64
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _coverImage;
  String _username = '';
  String _bio = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Carica le impostazioni salvate
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Username';
      _bio = prefs.getString('bio') ?? 'Bio';

      // Carica le immagini (in formato base64) e decodifica se esistono
      String? encodedProfileImage = prefs.getString('profileImage');
      if (encodedProfileImage != null) {
        _profileImage = File.fromRawPath(base64Decode(encodedProfileImage));
      }

      String? encodedCoverImage = prefs.getString('coverImage');
      if (encodedCoverImage != null) {
        _coverImage = File.fromRawPath(base64Decode(encodedCoverImage));
      }
    });
  }

  // Salva le immagini in SharedPreferences come base64
  Future<void> _saveProfileImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedImage = base64Encode(await image.readAsBytes());
    prefs.setString('profileImage', encodedImage);
  }

  Future<void> _saveCoverImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedImage = base64Encode(await image.readAsBytes());
    prefs.setString('coverImage', encodedImage);
  }

  // Controlla e richiede le autorizzazioni
  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    bool hasPermission = await _checkAndRequestPermissions(source);

    if (hasPermission) {
      try {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            if (isProfile) {
              _profileImage = File(pickedFile.path);
              _saveProfileImage(_profileImage!);
            } else {
              _coverImage = File(pickedFile.path);
              _saveCoverImage(_coverImage!);
            }
          });
        }
      } catch (e) {
        print("Errore nell'aprire la galleria: $e");
      }
    }
  }

  Future<void> _showImageSourceDialog(bool isProfile) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isProfile
              ? 'Cambia Immagine Profilo'
              : 'Cambia Immagine Copertura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Scatta una foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isProfile);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Scegli dalla libreria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isProfile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo'),
        // Rimosso il tasto di ritorno
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceDialog(false),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: _coverImage != null
                      ? DecorationImage(
                          image: FileImage(_coverImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey,
                ),
                child: _coverImage == null
                    ? Center(
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 50))
                    : null,
              ),
            ),
            SizedBox(height: 80),
            Center(
              child: GestureDetector(
                onTap: () => _showImageSourceDialog(true),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? Icon(Icons.camera_alt) : null,
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _bio,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/account-settings');
                },
                child: Text('Impostazioni Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
