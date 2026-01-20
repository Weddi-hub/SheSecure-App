import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
export 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' show BluetoothDevice;
import 'package:latlong2/latlong.dart';
import 'package:she_secure/models/device_model.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothManager extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  String? _connectingAddress;
  BluetoothDevice? _connectedDevice;
  final List<BluetoothDeviceModel> _availableDevices = [];
  String _receivedDataBuffer = '';
  String _lastHardwareMessage = 'Disconnected';
  LatLng? _deviceLocation;
  String _deviceStatus = 'Disconnected';
  final StreamController<String> _dataStreamController = StreamController<String>.broadcast();

  // Recording state
  Timer? _recordingTimer;
  bool _isRecording = false;
  bool _hasLastRecording = false;

  // Getters
  bool get isConnected => _connection != null && _connection!.isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectingAddress => _connectingAddress;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDeviceModel> get availableDevices => _availableDevices;
  String get lastHardwareMessage => _lastHardwareMessage;
  Stream<String> get dataStream => _dataStreamController.stream;
  LatLng? get deviceLocation => _deviceLocation;
  String get deviceStatus => _deviceStatus;
  bool get isRecording => _isRecording;
  bool get hasLastRecording => _hasLastRecording;

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.locationWhenInUse,
      ].request();
    }
  }

  Future<List<BluetoothDeviceModel>> getPairedDevices() async {
    try {
      await _requestPermissions();
      
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled != true) {
        await FlutterBluetoothSerial.instance.requestEnable();
        await Future.delayed(const Duration(seconds: 2));
      }

      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      
      _availableDevices.clear();
      for (var device in bondedDevices) {
        _availableDevices.add(BluetoothDeviceModel(
          name: device.name ?? 'Unknown Device',
          address: device.address,
          isConnected: isConnected && _connectedDevice?.address == device.address,
          type: 'Classic',
        ));
      }
      
      notifyListeners();
      return _availableDevices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      rethrow;
    }
  }

  Future<void> connectToDevice(BluetoothDeviceModel deviceModel) async {
    if (_isConnecting) return;

    try {
      _isConnecting = true;
      _connectingAddress = deviceModel.address;
      _lastHardwareMessage = 'Connecting...';
      notifyListeners();

      await FlutterBluetoothSerial.instance.cancelDiscovery();

      if (isConnected) await disconnect();

      _connection = await BluetoothConnection.toAddress(deviceModel.address)
          .timeout(const Duration(seconds: 20));
          
      _connectedDevice = BluetoothDevice(
        name: deviceModel.name,
        address: deviceModel.address,
      );

      _connection!.input?.listen((Uint8List data) {
        _handleReceivedData(String.fromCharCodes(data));
      }).onDone(() {
        _lastHardwareMessage = 'Connection Lost';
        disconnect();
      });

      _isConnecting = false;
      _connectingAddress = null;
      _deviceStatus = 'Connected';
      _lastHardwareMessage = 'Connected to ${deviceModel.name}';
      _updateDeviceInList(deviceModel.address, true);
      notifyListeners();
      
    } catch (e) {
      _isConnecting = false;
      _connectingAddress = null;
      _deviceStatus = 'Error';
      _lastHardwareMessage = 'Connection Failed';
      debugPrint('Classic BT Connection Error: $e');
      _updateDeviceInList(deviceModel.address, false);
      notifyListeners();
      throw 'Could not connect: $e';
    }
  }

  void _updateDeviceInList(String address, bool connected) {
    for (int i = 0; i < _availableDevices.length; i++) {
      if (_availableDevices[i].address == address) {
        _availableDevices[i] = BluetoothDeviceModel(
          name: _availableDevices[i].name,
          address: _availableDevices[i].address,
          isConnected: connected,
          type: _availableDevices[i].type,
        );
      } else if (connected) {
        _availableDevices[i] = BluetoothDeviceModel(
          name: _availableDevices[i].name,
          address: _availableDevices[i].address,
          isConnected: false,
          type: _availableDevices[i].type,
        );
      }
    }
  }

  void _handleReceivedData(String data) {
    _receivedDataBuffer += data;
    
    if (_receivedDataBuffer.contains('\n')) {
      List<String> lines = _receivedDataBuffer.split('\n');
      for (int i = 0; i < lines.length - 1; i++) {
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          debugPrint('Hardware -> App: $line');
          _lastHardwareMessage = line;
          _dataStreamController.add(line);
          
          if (line.contains('LAT:')) {
            try {
              final latIndex = line.indexOf('LAT:');
              final lngIndex = line.indexOf('LNG:');
              
              if (latIndex != -1 && lngIndex != -1) {
                String latStr = line.substring(latIndex + 4, lngIndex).trim();
                String lngStr = line.substring(lngIndex + 4).trim();
                
                double lat = double.parse(latStr);
                double lng = double.parse(lngStr);
                _deviceLocation = LatLng(lat, lng);
              }
            } catch (e) {
              debugPrint('Parse error: $e');
            }
          }
        }
      }
      _receivedDataBuffer = lines.last;
      notifyListeners();
    }
  }

  Future<void> sendCommand(String command) async {
    if (!isConnected || _connection == null) throw 'Not connected';
    try {
      _connection!.output.add(Uint8List.fromList((command + '\n').codeUnits));
      await _connection!.output.allSent;
    } catch (e) {
      debugPrint('Send error: $e');
      disconnect();
      rethrow;
    }
  }

  Future<void> triggerSOS() async {
    await sendCommand('VIB');
    _lastHardwareMessage = 'SOS ALERT SENT !!!';
    notifyListeners();
  }
  
  Future<void> triggerVibration() async {
    await sendCommand('VIB');
    _lastHardwareMessage = 'Vibrating';
    notifyListeners();
  }

  Future<void> getDeviceStatus() async {
    await sendCommand('STATUS');
    _lastHardwareMessage = 'Device is Active';
    notifyListeners();
  }

  Future<void> getDeviceLocationCommand() async {
    await sendCommand('GPS');
    _lastHardwareMessage = 'Fetching GPS Location...';
    notifyListeners();
  }

  Future<void> startRecording() async {
    await sendCommand('REC');
    _isRecording = true;
    _hasLastRecording = false;
    _lastHardwareMessage = 'Recording...';
    notifyListeners();

    _recordingTimer?.cancel();
    _recordingTimer = Timer(const Duration(seconds: 10), () {
      if (_isRecording) {
        stopRecording();
      }
    });
  }

  Future<void> stopRecording() async {
    await sendCommand('STOP');
    _isRecording = false;
    _hasLastRecording = true;
    _recordingTimer?.cancel();
    _lastHardwareMessage = 'Recording stopped. You can now listen.';
    notifyListeners();
  }

  void playLastRecording() {
    _lastHardwareMessage = 'Playing recording...';
    notifyListeners();
    Timer(const Duration(seconds: 3), () {
      _lastHardwareMessage = 'Finished listening.';
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      try {
        await _connection!.finish();
      } catch (_) {}
      _connection = null;
    }
    _connectedDevice = null;
    _deviceLocation = null;
    _deviceStatus = 'Disconnected';
    _lastHardwareMessage = 'Disconnected';
    _isRecording = false;
    _recordingTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _dataStreamController.close();
    super.dispose();
  }
}
