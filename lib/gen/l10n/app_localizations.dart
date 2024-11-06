import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'RL Inventory',
      'login': 'Login',
      'email_label': 'Email',
      'password_label': 'Password',
      'login_button': 'Login',
      'register_button': 'Register',
      'welcome_message': 'Welcome!',
      'login_error_message': 'Please enter your email and password.',
    },
    'it': {
      'app_title': 'Inventario RL',
      'login': 'Accesso',
      'email_label': 'Email',
      'password_label': 'Password',
      'login_button': 'Accedi',
      'register_button': 'Registrati',
      'welcome_message': 'Benvenuto!',
      'login_error_message': 'Inserisci email e password.',
    },
    'es': {
      'app_title': 'Inventario RL',
      'login': 'Iniciar sesión',
      'email_label': 'Correo electrónico',
      'password_label': 'Contraseña',
      'login_button': 'Iniciar sesión',
      'register_button': 'Registrarse',
      'welcome_message': '¡Bienvenido!',
      'login_error_message':
          'Por favor ingrese su correo electrónico y contraseña.',
    },
    'fr': {
      'app_title': 'Inventaire RL',
      'login': 'Connexion',
      'email_label': 'Email',
      'password_label': 'Mot de passe',
      'login_button': 'Connexion',
      'register_button': 'S\'inscrire',
      'welcome_message': 'Bienvenue!',
      'login_error_message':
          'Veuillez entrer votre email et votre mot de passe.',
    },
  };

  static var delegate;

  String? translate(String key) {
    return _localizedValues[locale.languageCode]?[key];
  }

  String get loginTitle => translate('login') ?? 'Login';
  String get emailLabel => translate('email_label') ?? 'Email';
  String get passwordLabel => translate('password_label') ?? 'Password';
  String get loginButton => translate('login_button') ?? 'Login';
  String get registerButton => translate('register_button') ?? 'Register';
  String get welcomeMessage => translate('welcome_message') ?? 'Welcome!';
  String get loginErrorMessage =>
      translate('login_error_message') ?? 'Login error!';
}
