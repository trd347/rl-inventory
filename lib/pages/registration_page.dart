import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  final Function onRegistration;

  RegistrationPage(
      {required this.onRegistration}); // Aggiungi la funzione nel costruttore

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isTermsAccepted = false;

  void _register() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String birthDate = _birthDateController.text;
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (_isTermsAccepted &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        birthDate.isNotEmpty &&
        username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstName', firstName);
      await prefs.setString('lastName', lastName);
      await prefs.setString('username', username);
      await prefs.setString('email', email);

      widget
          .onRegistration(); // Chiama la funzione di registrazione passata dal MyApp
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isTermsAccepted
              ? 'Per favore, compila tutti i campi correttamente.'
              : 'Devi accettare i Termini e Condizioni.'),
        ),
      );
    }
  }

  // Funzione per la formattazione della data di nascita
  void _formatBirthDate(String value) {
    final currentText = value.replaceAll('/', '');
    String formattedText = '';

    if (currentText.length >= 2) {
      String day = currentText.substring(0, 2);
      int dayInt = int.tryParse(day) ?? 0;
      if (dayInt > 31) {
        day = '31';
      }
      formattedText = '$day/';
    } else {
      formattedText = currentText;
    }

    if (currentText.length >= 4) {
      String month = currentText.substring(2, 4);
      int monthInt = int.tryParse(month) ?? 0;
      if (monthInt > 12) {
        month = '12';
      }
      formattedText += '$month/';
    } else {
      if (currentText.length > 2) {
        formattedText += currentText.substring(2);
      }
    }

    if (currentText.length >= 8) {
      String year = currentText.substring(4, 8);
      int yearInt = int.tryParse(year) ?? 1900;
      int currentYear = DateTime.now().year;
      if (yearInt < 1900) {
        year = '1900';
      } else if (yearInt > currentYear) {
        year = currentYear.toString();
      }
      formattedText += year;
    } else {
      if (currentText.length > 4) {
        formattedText += currentText.substring(4);
      }
    }

    _birthDateController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrazione'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Cognome'),
            ),
            TextField(
              controller: _birthDateController,
              decoration:
                  InputDecoration(labelText: 'Data di Nascita (dd/mm/yyyy)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                _formatBirthDate(value);
              },
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Conferma Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isTermsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isTermsAccepted = value ?? false;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/terms');
                  },
                  child: Text(
                    'Accetto i Termini e Condizioni',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrati'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hai già un account? Accedi'),
            ),
          ],
        ),
      ),
    );
  }
}
