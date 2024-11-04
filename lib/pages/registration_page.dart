import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
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

  void _register() {
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
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isTermsAccepted
                ? 'Per favore, compila tutti i campi correttamente.'
                : 'Devi accettare i Termini e Condizioni.')),
      );
    }
  }

  void _formatBirthDate(String value) {
    if (value.length == 2 || value.length == 5) {
      _birthDateController.text = "$value/";
      _birthDateController.selection = TextSelection.fromPosition(
          TextPosition(offset: _birthDateController.text.length));
    }
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
                    Navigator.pushNamed(context,
                        '/terms'); // Naviga alla pagina Termini e Condizioni
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
