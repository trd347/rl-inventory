import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSettingsPage extends StatefulWidget {
  @override
  _BiometricSettingsPageState createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends State<BiometricSettingsPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
        );
        if (authenticated) {
          setState(() {
            _isBiometricEnabled = true;
          });
          await prefs.setBool('isBiometricEnabled', true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Biometric authentication is not available on this device')),
        );
      }
    } else {
      setState(() {
        _isBiometricEnabled = false;
      });
      await prefs.setBool('isBiometricEnabled', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Enable Biometric Login'),
              value: _isBiometricEnabled,
              onChanged: (value) {
                _toggleBiometric(value);
              },
            ),
            if (!_isBiometricEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Biometric login allows you to use your fingerprint or face to securely log in.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
