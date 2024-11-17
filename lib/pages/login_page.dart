import 'package:flutter/material.dart';
import 'package:rl_inventory/gen/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart'; // Import per l'autenticazione biometrica

class LoginPage extends StatefulWidget {
  final Function onLogin; // Aggiungi la funzione per gestire il login

  LoginPage({required this.onLogin}); // Includi la funzione nel costruttore

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth =
      LocalAuthentication(); // Istanza per l'autenticazione biometrica

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      // Simuliamo il login per ora
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email); // Salva l'email dell'utente
      await prefs.setBool('isLoggedIn', true); // Salva lo stato di login
      widget.onLogin(); // Chiama la funzione di login passata dal MyApp
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginErrorMessage),
        ),
      );
    }
  }

  void _loginWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // Salva lo stato di login
        widget.onLogin(); // Chiama la funzione di login passata dal MyApp
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication failed: \$e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loginTitle),
        automaticallyImplyLeading:
            false, // Rimuove il tasto per tornare indietro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome in Real Life Inventory",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.emailLabel,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordLabel,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(AppLocalizations.of(context)!.loginButton),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loginWithBiometrics,
              icon: Icon(Icons.fingerprint),
              label: Text('Login with Biometrics'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: Text(AppLocalizations.of(context)!.registerButton),
            ),
          ],
        ),
      ),
    );
  }
}
