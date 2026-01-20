class BluetoothDeviceModel {
  final String name;
  final String address;
  final bool isConnected;
  final String? type;
  final int? bondState;
  final int? rssi;

  BluetoothDeviceModel({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.type,
    this.bondState,
    this.rssi,
  });

  factory BluetoothDeviceModel.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothDeviceModel(
      name: map['name'] ?? 'Unknown',
      address: map['address'],
      isConnected: map['isConnected'] ?? false,
      type: map['type'],
      bondState: map['bondState'],
    );
  }
}

class DeviceCommand {
  final String id;
  final String command;
  final DateTime timestamp;
  final String? response;
  final bool isSuccess;

  DeviceCommand({
    required this.id,
    required this.command,
    required this.timestamp,
    this.response,
    this.isSuccess = false,
  });
}