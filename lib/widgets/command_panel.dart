import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';
import 'package:she_secure/services/database_service.dart';

class CommandPanel extends StatefulWidget {
  const CommandPanel({super.key});

  @override
  State<CommandPanel> createState() => _CommandPanelState();
}

class _CommandPanelState extends State<CommandPanel> {
  final List<Map<String, dynamic>> _commands = [
    {
      'label': 'STATUS',
      'command': 'STATUS',
      'icon': Icons.info,
      'color': Colors.blue,
    },
    {
      'label': 'GPS',
      'command': 'GPS',
      'icon': Icons.location_on,
      'color': Colors.green,
    },
    {
      'label': 'SOS',
      'command': 'SOS',
      'icon': Icons.warning,
      'color': Colors.red,
    },
    {
      'label': 'RECORD',
      'command': 'REC',
      'icon': Icons.mic,
      'color': Colors.orange,
    },
    {
      'label': 'STOP',
      'command': 'STOP',
      'icon': Icons.stop,
      'color': null, // Will use theme primary color
    },
    {
      'label': 'VIBRATE',
      'command': 'VIB',
      'icon': Icons.vibration,
      'color': Colors.teal,
    },
  ];

  bool _isSending = false;
  final DatabaseService _dbService = DatabaseService();

  Future<void> _sendCommand(String command) async {
    if (_isSending) return;

    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

    if (!bluetoothManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect device first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      switch (command) {
        case 'STATUS': 
          await bluetoothManager.getDeviceStatus(); 
          break;
        case 'GPS': 
          await bluetoothManager.getDeviceLocationCommand(); 
          break;
        case 'SOS': 
          await bluetoothManager.triggerSOS(); 
          break;
        case 'VIB': 
          await bluetoothManager.triggerVibration(); 
          break;
        case 'REC': 
          await bluetoothManager.startRecording(); 
          break;
        case 'STOP': 
          await bluetoothManager.stopRecording(); 
          break;
        case 'PLAY':
          bluetoothManager.playLastRecording();
          break;
        default: 
          await bluetoothManager.sendCommand(command);
      }

      await _dbService.logDeviceCommand(
        deviceId: bluetoothManager.connectedDevice?.address ?? 'unknown',
        command: command,
        isSuccess: true,
      );
    } catch (e) {
      debugPrint('Error sending command: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  'Hardware Controls',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              if (bluetoothManager.hasLastRecording)
                TextButton.icon(
                  onPressed: () => _sendCommand('PLAY'),
                  icon: const Icon(Icons.play_arrow, size: 14),
                  label: const Text('Listen to Recording', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: primaryColor,
                  ),
                ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.4,
              ),
              itemCount: _commands.length,
              itemBuilder: (context, index) {
                final cmd = _commands[index];
                final isConnected = bluetoothManager.isConnected;
                final isRecording = cmd['command'] == 'REC' && bluetoothManager.isRecording;
                
                final iconColor = isRecording ? Colors.red : (cmd['color'] ?? primaryColor);
                final label = isRecording ? 'RECORDING...' : cmd['label'];
                
                return Card(
                  elevation: isConnected ? 1 : 0,
                  margin: EdgeInsets.zero,
                  color: isConnected ? Colors.white : Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  child: InkWell(
                    onTap: (isConnected && !_isSending) ? () => _sendCommand(cmd['command']) : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isRecording ? Icons.fiber_manual_record : cmd['icon'], 
                          size: 18, 
                          color: isConnected ? iconColor : Colors.grey[400]
                        ),
                        const SizedBox(height: 1),
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: isConnected ? (isRecording ? Colors.red : Colors.black87) : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
