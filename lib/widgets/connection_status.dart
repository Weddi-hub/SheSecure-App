import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';

class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: bluetoothManager.isConnected ? Colors.green[50] : Colors.red[50],
      child: Row(
        children: [
          Icon(
            bluetoothManager.isConnected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled,
            color: bluetoothManager.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bluetoothManager.isConnected
                      ? 'Device Connected'
                      : 'Device Disconnected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: bluetoothManager.isConnected ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (bluetoothManager.isConnected && bluetoothManager.connectedDevice != null)
                  Text(
                    bluetoothManager.connectedDevice!.name ?? bluetoothManager.connectedDevice!.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          if (bluetoothManager.isConnected)
            OutlinedButton(
              onPressed: () => bluetoothManager.disconnect(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Disconnect'),
            ),
        ],
      ),
    );
  }
}
