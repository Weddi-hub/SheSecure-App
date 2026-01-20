import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/models/user_model.dart';
import 'package:she_secure/services/auth_service.dart';
import 'package:she_secure/services/bluetooth_service.dart';
import 'package:she_secure/services/theme_service.dart';
import 'package:she_secure/screens/auth/login_screen.dart';
import 'package:she_secure/widgets/profile_popup.dart';
import 'package:she_secure/widgets/settings_popup.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_isLoading ? 'Loading...' : (_currentUser?.fullName ?? 'User Name')),
            accountEmail: Text(_isLoading ? '' : (_currentUser?.email ?? 'user@example.com')),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (_currentUser?.profileImage != null && _currentUser!.profileImage!.isNotEmpty)
                  ? NetworkImage(_currentUser!.profileImage!)
                  : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : (_currentUser?.profileImage == null || _currentUser!.profileImage!.isEmpty)
                      ? Icon(Icons.person, size: 40, color: themeProvider.primaryColor)
                      : null,
            ),
            decoration: BoxDecoration(color: themeProvider.primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              if (_currentUser != null) {
                final navigator = Navigator.of(context);
                navigator.pop();
                showDialog(
                  context: navigator.context,
                  barrierDismissible: false,
                  builder: (context) => ProfilePopup(user: _currentUser!),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              showDialog(
                context: navigator.context,
                barrierDismissible: false,
                builder: (context) => const SettingsPopup(),
              );
            },
          ),
          const Divider(),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutConfirmation(context, authService, bluetoothManager),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(
      BuildContext context,
      AuthService authService,
      BluetoothManager bluetoothManager
      ) {
    final primaryColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close drawer
              await _logout(context, authService, bluetoothManager);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(
      BuildContext context,
      AuthService authService,
      BluetoothManager bluetoothManager
      ) async {
    try {
      if (bluetoothManager.isConnected) {
        await bluetoothManager.disconnect();
      }

      await authService.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
