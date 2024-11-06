import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import per notifiche locali
import 'package:rl_inventory/gen/l10n/app_localizations.dart';
import 'package:rl_inventory/gen/l10n/app_localizations_delegate.dart';
import 'package:rl_inventory/pages/about_page.dart';
import 'package:rl_inventory/pages/account_settings_page.dart';
import 'package:rl_inventory/pages/containers_page.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Inizializza il plugin delle notifiche
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp(
    isDarkMode: isDarkMode,
    isLoggedIn: isLoggedIn,
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp(
      {required this.isDarkMode,
      required this.isLoggedIn,
      required this.flutterLocalNotificationsPlugin});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _isLoggedIn = widget.isLoggedIn;
  }

  void toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  void setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    setState(() {
      _isLoggedIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RL Inventory',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFFC107), // Giallo ambra
          secondary: Color(0xFF1976D2), // Azzurro scuro
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFFC107), // Giallo ambra per i bottoni
          textTheme: ButtonTextTheme.primary, // Testo in colore primario
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1976D2), // Azzurro scuro per FAB
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFC107), // Giallo ambra per la AppBar
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1976D2), // Azzurro scuro per la nav bar
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFFFC107), // Giallo ambra
          secondary: Color(0xFF1976D2), // Azzurro scuro
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFFC107), // Giallo ambra per i bottoni
          textTheme: ButtonTextTheme.primary, // Testo in colore primario
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1976D2), // Azzurro scuro per FAB
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFC107), // Giallo ambra per la AppBar
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1976D2), // Azzurro scuro per la nav bar
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginPage(
              onLogin: () {
                setLoggedIn(true);
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(
                        flutterLocalNotificationsPlugin:
                            widget.flutterLocalNotificationsPlugin,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                    ));
              },
            ),
        '/home': (context) => HomeScreen(
              flutterLocalNotificationsPlugin:
                  widget.flutterLocalNotificationsPlugin,
            ),
        '/registration': (context) => RegistrationPage(
              onRegistration: () {
                setLoggedIn(true);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/account-settings': (context) => AccountSettingsPage(
              onThemeChanged: (bool) {},
            ),
        '/settings': (context) => SettingsPage(
              flutterLocalNotificationsPlugin:
                  widget.flutterLocalNotificationsPlugin,
            ),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        const AppLocalizationsDelegate(),
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('it', ''),
        const Locale('es', ''),
        const Locale('fr', ''),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  HomeScreen({required this.flutterLocalNotificationsPlugin});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = widget.flutterLocalNotificationsPlugin;
  }

  // Lista delle pagine
  final List<Widget> _pages = [
    HomePage(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      updateInventory: () {},
    ),
    ContainersPage(updateInventory: () {}),
    ObjectsPage(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      onObjectsUpdated: (objects) {},
    ),
    ProfilePage(),
    SettingsPage(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RL Inventory'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Containers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Objects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF1976D2), // Azzurro scuro
        onTap: _onItemTapped,
      ),
    );
  }
}
