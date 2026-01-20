import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:she_secure/services/database_service.dart';
import 'package:she_secure/services/auth_service.dart';
import 'package:she_secure/models/user_model.dart';
import 'package:she_secure/widgets/custom_button.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, dynamic> _stats = {};
  // List<UserModel> _users = []; // This field is not used.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final stats = await _dbService.getAdminStats();
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      // In production, consider using a logging library instead of print.
      print('Error loading stats: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1), // Consider using .withAlpha() or .withRed()/.withGreen()/.withBlue() for more control
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    // This would normally come from your database
    final data = [
      _ActivityData('Mon', 12),
      _ActivityData('Tue', 19),
      _ActivityData('Wed', 15),
      _ActivityData('Thu', 25),
      _ActivityData('Fri', 22),
      _ActivityData('Sat', 18),
      _ActivityData('Sun', 14),
    ];

    final series = [
      charts.Series<_ActivityData, String>(
        id: 'Activity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (_ActivityData data, _) => data.day,
        measureFn: (_ActivityData data, _) => data.count,
        data: data,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: charts.BarChart(
                series,
                animate: true,
                vertical: false,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: const charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = snapshot.data;

        if (currentUser?.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: const Center(
              child: Text(
                'You do not have permission to access this page.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      _stats['totalUsers'] ?? 0,
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Active Users',
                      _stats['activeUsers'] ?? 0,
                      Icons.person,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'SOS Alerts',
                      _stats['totalSOS'] ?? 0,
                      Icons.warning,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Total Activities',
                      _stats['totalActivities'] ?? 0,
                      Icons.history,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Charts
                _buildActivityChart(),
                const SizedBox(height: 20),

                // Quick Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            CustomButton(
                              onPressed: () {
                                // Navigate to user management
                              },
                              text: 'User Management',
                              icon: Icons.manage_accounts,
                              fullWidth: false,
                            ),
                            CustomButton(
                              onPressed: () {
                                // Navigate to device logs
                              },
                              text: 'Device Logs',
                              icon: Icons.devices,
                              fullWidth: false,
                              isOutlined: true,
                            ),
                            CustomButton(
                              onPressed: () {
                                // Generate report
                              },
                              text: 'Generate Report',
                              icon: Icons.summarize,
                              fullWidth: false,
                            ),
                            CustomButton(
                              onPressed: () {
                                // Cleanup logs
                                _showCleanupDialog();
                              },
                              text: 'Cleanup Logs',
                              icon: Icons.cleaning_services,
                              fullWidth: false,
                              isOutlined: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Old Logs'),
        content: const Text('This will delete all logs older than 30 days. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.cleanupOldLogs(30);
              // Check if the widget is still mounted before calling setState or accessing context
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleaned up successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }
}

class _ActivityData {
  final String day;
  final int count;

  _ActivityData(this.day, this.count);
}