import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rl_inventory/gen/l10n/app_localizations.dart';
import 'package:rl_inventory/gen/l10n/app_localizations_delegate.dart';
import 'package:rl_inventory/pages/about_page.dart';
import 'package:rl_inventory/pages/account_settings_page.dart';
import 'package:rl_inventory/pages/containers_page.dart';
import 'package:rl_inventory/pages/custom_drawer.dart';
import 'package:rl_inventory/pages/groups_page.dart';
import 'package:rl_inventory/pages/help_support_page.dart';
import 'package:rl_inventory/pages/home_page.dart';
import 'package:rl_inventory/pages/login_page.dart';
import 'package:rl_inventory/pages/notification_settings_page.dart';
import 'package:rl_inventory/pages/objects_page.dart';
import 'package:rl_inventory/pages/password_recovery_page.dart';
import 'package:rl_inventory/pages/privacy_settings_page.dart';
import 'package:rl_inventory/pages/profile_page.dart';
import 'package:rl_inventory/pages/registration_page.dart';
import 'package:rl_inventory/pages/register_page.dart';
import 'package:rl_inventory/pages/settings_page.dart';
import 'package:rl_inventory/pages/tag_configuration_page.dart';
import 'package:rl_inventory/pages/tag_management_page.dart';
import 'package:rl_inventory/pages/tags_page.dart';
import 'package:rl_inventory/pages/terms_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RL Inventory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Iniziamo con la LoginPage
      routes: {
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/containers': (context) => ContainersPage(),
        '/groups': (context) => GroupsPage(),
        '/help': (context) => HelpSupportPage(),
        '/terms': (context) => TermsPage(),
        '/registration': (context) => RegistrationPage(),
        '/about': (context) => AboutPage(),
        '/account_settings': (context) => AccountSettingsPage(),
        '/notification_settings': (context) => NotificationSettingsPage(),
        '/objects': (context) => ObjectsPage(),
        '/password_recovery': (context) => PasswordRecoveryPage(),
        '/privacy_settings': (context) => PrivacySettingsPage(),
        '/register': (context) => RegisterPage(),
        '/tag_configuration': (context) => TagConfigurationPage(),
        '/tag_management': (context) => TagManagementPage(),
        '/tags': (context) => TagsPage(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        const AppLocalizationsDelegate(), // Aggiunta del delegato di localizzazione
      ],
      supportedLocales: [
        const Locale('en', ''), // Inglese
        const Locale('it', ''), // Italiano
        const Locale('es', ''), // Spagnolo
        const Locale('fr', ''), // Francese
      ],
    );
  }
}
