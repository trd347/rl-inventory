import 'dart:convert'; // Per la codifica e decodifica base64
import 'dart:typed_data';
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
  Uint8List? _profileImage;
  Uint8List? _coverImage;
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
        _profileImage = base64Decode(encodedProfileImage);
      }

      String? encodedCoverImage = prefs.getString('coverImage');
      if (encodedCoverImage != null) {
        _coverImage = base64Decode(encodedCoverImage);
      }
    });
  }

  // Salva le immagini in SharedPreferences come base64
  Future<void> _saveProfileImage(Uint8List imageBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedImage = base64Encode(imageBytes);
    prefs.setString('profileImage', encodedImage);
  }

  Future<void> _saveCoverImage(Uint8List imageBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedImage = base64Encode(imageBytes);
    prefs.setString('coverImage', encodedImage);
  }

  // Salva il nome utente e la bio
  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _username);
    prefs.setString('bio', _bio);
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
          Uint8List imageBytes = await pickedFile.readAsBytes();
          setState(() {
            if (isProfile) {
              _profileImage = imageBytes;
              _saveProfileImage(imageBytes);
            } else {
              _coverImage = imageBytes;
              _saveCoverImage(imageBytes);
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
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
                          image: MemoryImage(_coverImage!),
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
                  backgroundImage: _profileImage != null
                      ? MemoryImage(_profileImage!)
                      : null,
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Username'),
                    controller: TextEditingController(text: _username),
                    onChanged: (value) {
                      _username = value;
                      _saveProfileData();
                    },
                  ),
                  SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(labelText: 'Bio'),
                    controller: TextEditingController(text: _bio),
                    onChanged: (value) {
                      _bio = value;
                      _saveProfileData();
                    },
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
