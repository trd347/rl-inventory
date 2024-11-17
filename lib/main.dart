import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rl_inventory/gen/l10n/app_localizations.dart';
import 'package:rl_inventory/gen/l10n/app_localizations_delegate.dart';
import 'package:rl_inventory/pages/about_page.dart';
import 'package:rl_inventory/pages/account_settings_page.dart';
import 'package:rl_inventory/pages/containers_page.dart' as containers;
import 'package:rl_inventory/pages/groups_page.dart';
import 'package:rl_inventory/pages/help_support_page.dart';
import 'package:rl_inventory/pages/home_page.dart' as home;
import 'package:rl_inventory/pages/login_page.dart';
import 'package:rl_inventory/pages/notification_settings_page.dart';
import 'package:rl_inventory/pages/objects_page.dart' as objects;
import 'package:rl_inventory/pages/password_recovery_page.dart';
import 'package:rl_inventory/pages/privacy_settings_page.dart';
import 'package:rl_inventory/pages/profile_page.dart';
import 'package:rl_inventory/pages/registration_page.dart';
import 'package:rl_inventory/pages/register_page.dart';
import 'package:rl_inventory/pages/settings_page.dart';
import 'package:rl_inventory/pages/terms_page.dart';
import 'package:rl_inventory/pages/container_details.dart';
import 'package:rl_inventory/pages/nfc_manager.dart';
import 'package:rl_inventory/pages/theme_settings_page.dart';
import 'package:rl_inventory/pages/biometric_settings_page.dart';
import 'package:rl_inventory/managers/inventory_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rl_inventory/bluetooth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool useBiometricAuth = prefs.getBool('useBiometricAuth') ?? false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (useBiometricAuth) {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (canCheckBiometrics) {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
      );
      if (!didAuthenticate) {
        isLoggedIn = false;
      }
    } else {
      debugPrint('Biometric authentication is not available.');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryManager()),
        ChangeNotifierProvider(create: (_) => BluetoothManager()),
      ],
      child: MyApp(
        isDarkMode: isDarkMode,
        isLoggedIn: isLoggedIn,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp({
    required this.isDarkMode,
    required this.isLoggedIn,
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late bool _isLoggedIn;
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _isLoggedIn = widget.isLoggedIn;
    _initializeBluetooth();
    _loadThemeColors();
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
      print('Login status aggiornato: \$_isLoggedIn');
    });
  }

  Future<void> _initializeBluetooth() async {
    bool isBluetoothAvailable =
        (await FlutterBluetoothSerial.instance.isAvailable) ?? false;
    if (isBluetoothAvailable) {
      var status = await Permission.bluetooth.request();
      if (status.isGranted) {
        await FlutterBluetoothSerial.instance.requestEnable();
      } else {
        debugPrint('Bluetooth permission denied.');
      }
    } else {
      debugPrint('Bluetooth is not available on this device');
    }
  }

  Future<void> _loadThemeColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
      _secondaryColor =
          Color(prefs.getInt('secondaryColor') ?? Colors.orange.value);
    });
  }

  void _updateThemeColors(Color primary, Color secondary) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', primary.value);
    await prefs.setInt('secondaryColor', secondary.value);
    setState(() {
      _primaryColor = primary;
      _secondaryColor = secondary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RL Inventory',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _secondaryColor,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: _primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _secondaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _primaryColor,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: _secondaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: _secondaryColor,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: _primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _secondaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _primaryColor,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: _secondaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginPage(
              onLogin: () async {
                setLoggedIn(true);
                await Future.delayed(Duration(milliseconds: 500));
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(
                        flutterLocalNotificationsPlugin:
                            widget.flutterLocalNotificationsPlugin,
                        onThemeChanged: _updateThemeColors,
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
                    ),
                  );
                }
              },
            ),
        '/home': (context) => HomeScreen(
              flutterLocalNotificationsPlugin:
                  widget.flutterLocalNotificationsPlugin,
              onThemeChanged: _updateThemeColors,
            ),
        '/registration': (context) => RegistrationPage(
              onRegistration: () async {
                setLoggedIn(true);
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
        '/account-settings': (context) => AccountSettingsPage(
              onThemeChanged: (primary, secondary) {
                _updateThemeColors(primary, secondary);
              },
            ),
        '/settings': (context) => SettingsPage(
              flutterLocalNotificationsPlugin:
                  widget.flutterLocalNotificationsPlugin,
              onThemeChanged: (primaryColor, secondaryColor) {
                _updateThemeColors(primaryColor, secondaryColor);
              },
            ),
        '/terms': (context) => ContainerDetailsPage(
              container: containers.Container(
                  name: '', description: '', objects: [], isConnected: false),
              objects: [],
              onObjectAdded: (object) {},
              onObjectRemoved: (String) {},
              onContainerUpdated: () {},
            ),
        '/nfc-manager': (context) => NFCManagerPage(),
        '/theme-settings': (context) => ThemeSettingsPage(
              onThemeChanged: (primaryColor, secondaryColor) {
                _updateThemeColors(primaryColor, secondaryColor);
              },
            ),
        '/biometric-settings': (context) => BiometricSettingsPage(),
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

class NFCManagerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Manager'),
      ),
      body: Center(
        child: Text('NFC Management Page'),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function(Color, Color) onThemeChanged;

  HomeScreen({
    required this.flutterLocalNotificationsPlugin,
    required this.onThemeChanged,
  });

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

  late final List<Widget> _pages = [
    home.HomePage(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      updateInventory: () async {
        Provider.of<InventoryManager>(context, listen: false)
            .loadInventoryData();
      },
    ),
    containers.ContainersPage(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      onContainersUpdated: (containers) {},
      updateInventory: () async {
        Provider.of<InventoryManager>(context, listen: false)
            .loadInventoryData();
      },
      objects: [],
    ),
    objects.ObjectsPage(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      onObjectsUpdated: (objects) {},
      containers: [],
      updateInventory: () async {
        Provider.of<InventoryManager>(context, listen: false)
            .loadInventoryData();
      },
    ),
    ProfilePage(),
    SettingsPage(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      onThemeChanged: (primaryColor, secondaryColor) {
        widget.onThemeChanged(primaryColor, secondaryColor);
      },
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
        onTap: _onItemTapped,
      ),
    );
  }
}
