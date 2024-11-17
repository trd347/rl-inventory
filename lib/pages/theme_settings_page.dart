import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSettingsPage extends StatefulWidget {
  final Function(dynamic, dynamic) onThemeChanged;

  ThemeSettingsPage({required this.onThemeChanged});

  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.orange;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
      _secondaryColor =
          Color(prefs.getInt('secondaryColor') ?? Colors.orange.value);
    });
    _applyTheme();
  }

  Future<void> _saveThemeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setInt('secondaryColor', _secondaryColor.value);
  }

  void _updatePrimaryColor(Color color) {
    setState(() {
      _primaryColor = color;
    });
    _applyTheme();
    _saveThemeSettings();
  }

  void _updateSecondaryColor(Color color) {
    setState(() {
      _secondaryColor = color;
    });
    _applyTheme();
    _saveThemeSettings();
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _applyTheme();
    _saveThemeSettings();
  }

  void _applyTheme() {
    widget.onThemeChanged(
      _isDarkMode
          ? ThemeData.dark()
          : ThemeData.light().copyWith(
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
      _secondaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            title: Text('Primary Color'),
            trailing: CircleAvatar(
              backgroundColor: _primaryColor,
            ),
            onTap: () async {
              Color? color = await _pickColor(context, _primaryColor);
              if (color != null) _updatePrimaryColor(color);
            },
          ),
          ListTile(
            title: Text('Secondary Color'),
            trailing: CircleAvatar(
              backgroundColor: _secondaryColor,
            ),
            onTap: () async {
              Color? color = await _pickColor(context, _secondaryColor);
              if (color != null) _updateSecondaryColor(color);
            },
          ),
        ],
      ),
    );
  }

  Future<Color?> _pickColor(BuildContext context, Color initialColor) async {
    Color selectedColor = initialColor;
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Select'),
              onPressed: () => Navigator.of(context).pop(selectedColor),
            ),
          ],
        );
      },
    );
  }
}
