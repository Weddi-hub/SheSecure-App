import 'package:flutter/material.dart';

class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String activityLogsCollection = 'activity_logs';
  static const String deviceLogsCollection = 'device_logs';
  static const String sosAlertsCollection = 'sos_alerts';

  // Bluetooth Constants
  static const String targetDeviceName = 'SheSecure_Device';
  static const String serviceUUID = '00001101-0000-1000-8000-00805F9B34FB';

  // Map Constants
  static const double defaultMapZoom = 15.0;
  static const double sosMapZoom = 18.0;

  // Shared Preferences Keys
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefUserRole = 'user_role';
  static const String prefDeviceAddress = 'device_address';
  static const String prefIsLoggedIn = 'is_logged_in';

  // Time Constants
  static const int recordingDuration = 10000; // 10 seconds
  static const int sosTimeout = 30000; // 30 seconds
  static const int vibrationDuration = 500; // 500ms

  // Sensor Constants
  static const double shakeThreshold = 20.0;

  // Command Constants
  static final List<Map<String, dynamic>> deviceCommands = [
    {
      'label': 'STATUS',
      'command': 'STATUS',
      'icon': Icons.info_outline,
      'color': 0xFF4285F4,
      'description': 'Get device status and sensor readings'
    },
    const {
      'label': 'GET GPS',
      'command': 'GPS',
      'icon': Icons.location_on,
      'color': 0xFF34A853,
      'description': 'Fetch current GPS coordinates'
    },
    const {
      'label': 'SOS ALERT',
      'command': 'SOS',
      'icon': Icons.warning,
      'color': 0xFFEA4335,
      'description': 'Trigger emergency alert'
    },
    const {
      'label': 'START REC',
      'command': 'REC',
      'icon': Icons.mic,
      'color': 0xFFFBBC05,
      'description': 'Start audio recording'
    },
    const {
      'label': 'STOP REC',
      'command': 'STOP',
      'icon': Icons.stop,
      'color': 0xFF8E44AD,
      'description': 'Stop audio recording'
    },
    const {
      'label': 'TEST VIB',
      'command': 'VIBRATE',
      'icon': Icons.vibration,
      'color': 0xFF17A589,
      'description': 'Test vibration motor'
    },
  ];

  // Admin Module Constants
  static const List<String> adminRoles = ['admin', 'super_admin'];

  // API Keys
  static const String geoapifyApiKey = 'dea8a92cf5c44127bd9facb4f761a3f2';

  // URLs
  static const String privacyPolicyUrl = 'https://yoursite.com/privacy';
  static const String termsUrl = 'https://yoursite.com/terms';
  static const String supportEmail = 'support@shesecure.com';

  // App Version
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
}

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String sosHistory = '/sos-history';
  static const String deviceManagement = '/device-management';
}

class ImageAssets {
  static const String logo = 'assets/images/logo.png';
  static const String splash = 'assets/images/splash.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emergency = 'assets/images/emergency.png';
  static const String safety = 'assets/images/safety.png';
}

class AppStrings {
  static const String appName = 'SheSecure';
  static const String appTagline = 'Your Personal Safety Companion';
  static const String welcomeMessage = 'Welcome to SheSecure';
  static const String safetyFirst = 'Safety First, Always';
  static const String emergencyContact = 'Emergency Contacts';
  static const String quickActions = 'Quick Actions';
  static const String deviceStatus = 'Device Status';
  static const String connected = 'Connected';
  static const String disconnected = 'Disconnected';
  static const String connecting = 'Connecting...';
  static const String searchDevices = 'Searching for devices...';
  static const String noDevices = 'No devices found';
  static const String pairFirst = 'Please pair device in settings first';
  static const String connectionSuccess = 'Device connected successfully';
  static const String connectionFailed = 'Connection failed';
  static const String sendingCommand = 'Sending command...';
  static const String commandSent = 'Command sent successfully';
  static const String commandFailed = 'Failed to send command';
  static const String gpsUpdated = 'GPS location updated';
  static const String sosActivated = 'SOS Alert Activated!';
  static const String recordingStarted = 'Recording started (10 seconds)';
  static const String recordingStopped = 'Recording stopped';
  static const String deviceNotFound = 'Device not found';
  static const String bluetoothOff = 'Bluetooth is turned off';
  static const String locationOff = 'Location services are disabled';
  static const String permissionsRequired = 'Permissions required';
  static const String enableBluetooth = 'Please enable Bluetooth';
  static const String enableLocation = 'Please enable location services';
  static const String grantPermissions = 'Please grant required permissions';
  static const String adminDashboard = 'Admin Dashboard';
  static const String userManagement = 'User Management';
  static const String deviceLogs = 'Device Logs';
  static const String activityLogs = 'Activity Logs';
  static const String generateReport = 'Generate Report';
}