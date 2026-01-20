import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';
import 'package:she_secure/models/device_model.dart';

class DevicePicker extends StatefulWidget {
  const DevicePicker({super.key});

  @override
  DevicePickerState createState() => DevicePickerState();
}

class DevicePickerState extends State<DevicePicker> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
      await bluetoothManager.getPairedDevices();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDeviceModel device) async {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

    try {
      await bluetoothManager.connectToDevice(device);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name} successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // Detailed error message for the user
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.split('Exception:').last.trim();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $errorMsg'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _connectToDevice(device),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    final pairedDevices = bluetoothManager.availableDevices;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paired Devices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Select your SheSecure hardware to connect',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          Flexible(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPairedDevices,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
                : pairedDevices.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bluetooth_disabled, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No paired devices found',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please pair your hardware in phone settings first',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
                : Scrollbar(
                  child: ListView.builder(
              shrinkWrap: true,
              itemCount: pairedDevices.length,
              itemBuilder: (context, index) {
                final device = pairedDevices[index];
                // Check if THIS specific device is currently connecting
                final isThisDeviceConnecting = bluetoothManager.isConnecting && 
                                              bluetoothManager.connectingAddress == device.address;
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: device.isConnected 
                        ? const BorderSide(color: Colors.green, width: 1)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.bluetooth,
                      color: device.isConnected ? Colors.green : primaryColor,
                    ),
                    title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(device.address, style: const TextStyle(fontSize: 11)),
                    trailing: isThisDeviceConnecting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : device.isConnected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                      onPressed: bluetoothManager.isConnecting 
                          ? null 
                          : () => _connectToDevice(device),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Connect'),
                    ),
                  ),
                );
              },
            ),
                ),
          ),
          
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: primaryColor),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ensure your SheSecure device is nearby and powered on.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
