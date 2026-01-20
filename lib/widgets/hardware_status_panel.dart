import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';

class HardwareStatusPanel extends StatelessWidget {
  const HardwareStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LATEST HARDWARE FEEDBACK',
            style: TextStyle(
              fontSize: 9, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey, 
              letterSpacing: 1.0
            ),
          ),
          const SizedBox(height: 4),
          
          StreamBuilder<String>(
            stream: bluetoothManager.dataStream,
            builder: (context, snapshot) {
              String displayMsg = bluetoothManager.lastHardwareMessage;
              Color msgColor = Colors.black87;
              FontWeight weight = FontWeight.normal;

              if (displayMsg.contains('SOS') || displayMsg.contains('!!!')) {
                msgColor = Colors.red;
                weight = FontWeight.bold;
              } else if (displayMsg.contains('GPS') || displayMsg.contains('LAT')) {
                msgColor = Colors.green;
              } else if (displayMsg.contains('REC')) {
                msgColor = Colors.orange;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: msgColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: msgColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notification_important_outlined, size: 14, color: msgColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        displayMsg,
                        style: TextStyle(
                          fontSize: 13,
                          color: msgColor,
                          fontWeight: weight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
