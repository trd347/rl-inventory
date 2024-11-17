import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryManager extends ChangeNotifier {
  static final InventoryManager _instance = InventoryManager._internal();

  factory InventoryManager() {
    return _instance;
  }

  InventoryManager._internal();

  // Carica i contenitori dall'archiviazione locale
  Future<List<Map<String, dynamic>>> loadContainers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('containers');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(jsonList);
    }
    return [];
  }

  // Salva i contenitori nell'archiviazione locale
  Future<void> saveContainers(List<Map<String, dynamic>> containers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(containers);
    await prefs.setString('containers', jsonString);
    notifyListeners(); // Notifica i listener dopo aver salvato i contenitori
  }

  // Carica gli oggetti dall'archiviazione locale
  Future<List<Map<String, dynamic>>> loadObjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('objects');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(jsonList);
    }
    return [];
  }

  // Salva gli oggetti nell'archiviazione locale
  Future<void> saveObjects(List<Map<String, dynamic>> objects) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(objects);
    await prefs.setString('objects', jsonString);
    notifyListeners(); // Notifica i listener dopo aver salvato gli oggetti
  }

  // Carica l'inventario completo
  Future<Map<String, dynamic>> loadInventoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Caricamento dei contenitori
    String? containersJson = prefs.getString('containers');
    List<dynamic> containersList =
        containersJson != null ? json.decode(containersJson) : [];
    List<Map<String, dynamic>> containers =
        List<Map<String, dynamic>>.from(containersList);

    // Caricamento degli oggetti
    String? objectsJson = prefs.getString('objects');
    List<dynamic> objectsList =
        objectsJson != null ? json.decode(objectsJson) : [];
    List<Map<String, dynamic>> objects =
        List<Map<String, dynamic>>.from(objectsList);

    // Caricamento degli oggetti nei contenitori
    String? objectsInContainersJson = prefs.getString('objectsInContainers');
    Map<String, dynamic> objectsInContainers = objectsInContainersJson != null
        ? json.decode(objectsInContainersJson)
        : {};

    return {
      'containers': containers,
      'objects': objects,
      'objectsInContainers': objectsInContainers,
    };
  }

  // Aggiunge un nuovo contenitore
  Future<void> addContainer(String name, String description) async {
    List<Map<String, dynamic>> containers = await loadContainers();
    containers.add({
      'name': name,
      'description': description,
      'objects': [],
      'isConnected': false,
    });
    await saveContainers(containers);
  }

  // Aggiunge un nuovo oggetto
  Future<void> addObject(String name, String description) async {
    List<Map<String, dynamic>> objects = await loadObjects();
    objects.add({
      'name': name,
      'description': description,
    });
    await saveObjects(objects);
  }

  // Aggiunge un oggetto a un contenitore
  Future<void> addObjectToContainer(
      String containerName, String objectName) async {
    List<Map<String, dynamic>> containers = await loadContainers();
    for (var container in containers) {
      if (container['name'] == containerName) {
        List<String> objects = List<String>.from(container['objects']);
        if (!objects.contains(objectName)) {
          objects.add(objectName);
        }
        container['objects'] = objects;
        break;
      }
    }
    await saveContainers(containers);
    notifyListeners(); // Notifica i listener dopo aver salvato i contenitori aggiornati
  }

  // Rimuove un oggetto da un contenitore
  Future<void> removeObjectFromContainer(
      String containerName, String objectName) async {
    List<Map<String, dynamic>> containers = await loadContainers();
    for (var container in containers) {
      if (container['name'] == containerName) {
        List<String> objects = List<String>.from(container['objects']);
        objects.remove(objectName);
        container['objects'] = objects;
        break;
      }
    }
    await saveContainers(containers);
    notifyListeners(); // Notifica i listener dopo aver rimosso un oggetto
  }

  // Rimuove un contenitore dall'inventario
  Future<void> removeContainer(String containerName) async {
    List<Map<String, dynamic>> containers = await loadContainers();
    containers.removeWhere((container) => container['name'] == containerName);
    await saveContainers(containers);
    notifyListeners(); // Notifica i listener dopo aver rimosso un contenitore
  }

  // Rimuove un oggetto dall'inventario
  Future<void> removeObject(String objectName) async {
    List<Map<String, dynamic>> objects = await loadObjects();
    objects.removeWhere((object) => object['name'] == objectName);
    await saveObjects(objects);
    notifyListeners(); // Notifica i listener dopo aver rimosso un oggetto
  }
}
