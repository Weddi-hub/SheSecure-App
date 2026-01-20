import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';
import 'package:she_secure/screens/bluetooth/device_picker.dart';
import 'package:she_secure/widgets/hardware_status_panel.dart';
import 'package:she_secure/widgets/connection_status.dart';
import 'package:she_secure/screens/home/map_section.dart';
import 'package:she_secure/widgets/app_drawer.dart';
import '../../widgets/command_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('She Secure'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // 1. Map Section
                Expanded(
                  flex: 7,
                  child: MapSection(
                    deviceLocation: bluetoothManager.deviceLocation,
                  ),
                ),

                // 2. Hardware Feedback Panel
                const HardwareStatusPanel(),

                // 3. Hardware Controls Grid
                const Expanded(
                  flex: 4,
                  child: CommandPanel(),
                ),

                // 4. Connection Status Bar
                const ConnectionStatusBar(),
              ],
            ),

            // Bluetooth Floating Button - Custom Positioned
            Positioned(
              top: 250,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _showDevicePicker(context);
                },
                backgroundColor: bluetoothManager.isConnected ? Colors.green : Colors.blue,
                tooltip: 'Connect Device',
                child: Icon(
                  bluetoothManager.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDevicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DevicePicker(),
    );
  }
}
