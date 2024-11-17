import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';

class BluetoothManager extends ChangeNotifier {
  BluetoothManager(); // Aggiunto costruttore esplicito

  BluetoothConnection? _connection;
  List<BluetoothDiscoveryResult> _discoveredDevices = [];
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDiscoveryResult> get discoveredDevices => _discoveredDevices;
  BluetoothState get bluetoothState => _bluetoothState;

  // Inizializzazione e ascolto dello stato del Bluetooth
  void initializeBluetooth() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      notifyListeners();
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      _bluetoothState = state;
      notifyListeners();
    });
  }

  // Scansione dei dispositivi Bluetooth
  void startScan(Null Function(BluetoothDiscoveryResult result) param0) {
    _discoveredDevices.clear();
    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      _discoveredDevices.add(result);
      notifyListeners(); // Notifica ogni volta che un dispositivo viene trovato
    }).onDone(() {
      debugPrint('Scansione completata.');
      notifyListeners(); // Notifica al termine della scansione
    });
  }

  // Connessione a un dispositivo Bluetooth
  Future<void> connectToDevice(
      BluetoothDevice device, Null Function(bool? isConnected) param1) async {
    try {
      bool? isBonded = await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(device.address);

      if (isBonded ?? false) {
        debugPrint('Dispositivo associato con successo');
        BluetoothConnection connection =
            await BluetoothConnection.toAddress(device.address);
        _connection = connection;
        debugPrint('Connesso a ${device.name}');
        notifyListeners(); // Notifica quando la connessione è stabilita
      } else {
        debugPrint('Impossibile associare il dispositivo');
      }
    } catch (error) {
      debugPrint('Errore durante la connessione: $error');
    }
  }

  // Disconnessione da un dispositivo Bluetooth
  Future<void> disconnectFromDevice() async {
    if (_connection != null) {
      try {
        await _connection!.close();
        _connection = null;
        debugPrint('Disconnessione completata');
        notifyListeners(); // Notifica quando la disconnessione è completata
      } catch (error) {
        debugPrint('Errore durante la disconnessione: $error');
      }
    }
  }

  // Ferma la scansione
  void stopScan() {
    debugPrint('Scansione arrestata');
  }
}
