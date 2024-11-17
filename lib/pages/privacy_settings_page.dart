import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsPage extends StatefulWidget {
  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profilePrivate = false; // Valore di esempio
  bool _shareDataWithThirdParties = false; // Valore di esempio
  bool _useBiometricAuth = false;
  bool _allowLocationAccess =
      false; // Nuova opzione per consentire l'accesso alla posizione
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilePrivate = prefs.getBool('profilePrivate') ?? false;
      _shareDataWithThirdParties =
          prefs.getBool('shareDataWithThirdParties') ?? false;
      _useBiometricAuth = prefs.getBool('useBiometricAuth') ?? false;
      _allowLocationAccess = prefs.getBool('allowLocationAccess') ?? false;
    });
  }

  Future<void> _savePrivacySettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profilePrivate', _profilePrivate);
    await prefs.setBool(
        'shareDataWithThirdParties', _shareDataWithThirdParties);
    await prefs.setBool('useBiometricAuth', _useBiometricAuth);
    await prefs.setBool('allowLocationAccess', _allowLocationAccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Make Profile Private'),
              value: _profilePrivate,
              onChanged: (bool value) {
                setState(() {
                  _profilePrivate = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Share Data with Third Parties'),
              value: _shareDataWithThirdParties,
              onChanged: (bool value) {
                setState(() {
                  _shareDataWithThirdParties = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Allow Location Access'),
              value: _allowLocationAccess,
              onChanged: (bool value) {
                setState(() {
                  _allowLocationAccess = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Use Biometric Authentication'),
              value: _useBiometricAuth,
              onChanged: (bool value) async {
                bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
                if (canCheckBiometrics) {
                  setState(() {
                    _useBiometricAuth = value;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Biometric authentication is not available on this device.')),
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                _savePrivacySettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Privacy settings saved successfully.')),
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
