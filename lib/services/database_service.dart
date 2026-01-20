import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:she_secure/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get activityLogsCollection => _firestore.collection('activity_logs');
  CollectionReference get deviceLogsCollection => _firestore.collection('device_logs');
  CollectionReference get sosAlertsCollection => _firestore.collection('sos_alerts');

  // User Operations
  Future<void> createUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Activity Logging
  Future<void> logActivity({
    required String userId,
    required String event,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await activityLogsCollection.add({
        'userId': userId,
        'event': event,
        'description': description ?? event,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'appVersion': '1.0.0',
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Device Logging
  Future<void> logDeviceCommand({
    required String deviceId,
    required String command,
    String? response,
    bool isSuccess = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      await deviceLogsCollection.add({
        'userId': user?.uid,
        'deviceId': deviceId,
        'command': command,
        'response': response,
        'isSuccess': isSuccess,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging device command: $e');
    }
  }

  // SOS Alert Logging
  Future<void> logSOSAlert({
    required double latitude,
    required double longitude,
    String? address,
    String? triggeredBy,
    Map<String, dynamic>? sensorData,
  }) async {
    try {
      final user = _auth.currentUser;
      await sosAlertsCollection.add({
        'userId': user?.uid,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'triggeredBy': triggeredBy ?? 'manual',
        'sensorData': sensorData ?? {},
        'status': 'active',
        'responded': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging SOS alert: $e');
    }
  }

  // Admin Operations
  Stream<QuerySnapshot> getAllUsers() {
    return usersCollection.snapshots();
  }

  Stream<QuerySnapshot> getActivityLogs({int limit = 100}) {
    return activityLogsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> getDeviceLogs({String? deviceId, int limit = 100}) {
    Query query = deviceLogsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (deviceId != null) {
      query = query.where('deviceId', isEqualTo: deviceId);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot> getSOSAlerts({String? userId, int limit = 100}) {
    Query query = sosAlertsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots();
  }

  // User-specific data
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return usersCollection.doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getUserActivityLogs(String userId, {int limit = 50}) {
    return activityLogsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserSOSAlerts(String userId, {int limit = 50}) {
    return sosAlertsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get user info
      final user = await getUser(userId);
      if (user == null) throw 'User not found';

      // Get activity count
      final activityQuery = await activityLogsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      final activityCount = activityQuery.count;

      // Get SOS alerts count
      final sosQuery = await sosAlertsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      final sosCount = sosQuery.count;

      // Get device logs count
      final deviceQuery = await deviceLogsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      final deviceCount = deviceQuery.count;

      return {
        'user': user,
        'activityCount': activityCount,
        'sosCount': sosCount,
        'deviceCount': deviceCount,
        'joinedSince': user.createdAt,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Total users
      final usersQuery = await usersCollection.count().get();
      final totalUsers = usersQuery.count;

      // Total activity logs
      final activityQuery = await activityLogsCollection.count().get();
      final totalActivities = activityQuery.count;

      // Total SOS alerts
      final sosQuery = await sosAlertsCollection.count().get();
      final totalSOS = sosQuery.count;

      // Total device logs
      final deviceQuery = await deviceLogsCollection.count().get();
      final totalDeviceLogs = deviceQuery.count;

      // Active users (logged in last 7 days)
      final weekAgo = DateTime.now().subtract(Duration(days: 7));
      final activeUsersQuery = await activityLogsCollection
          .where('event', isEqualTo: 'login')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      final activeUsers = activeUsersQuery.docs
          .map((doc) => doc['userId'])
          .toSet()
          .length;

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalActivities': totalActivities,
        'totalSOS': totalSOS,
        'totalDeviceLogs': totalDeviceLogs,
        'generatedAt': DateTime.now(),
      };
    } catch (e) {
      print('Error getting admin stats: $e');
      rethrow;
    }
  }

  // Update SOS Alert Status
  Future<void> updateSOSAlertStatus(String alertId, String status) async {
    try {
      await sosAlertsCollection.doc(alertId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating SOS alert status: $e');
      rethrow;
    }
  }

  // Delete old logs (admin only)
  Future<void> cleanupOldLogs(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      // Delete old activity logs
      final oldActivityLogs = await activityLogsCollection
          .where('timestamp', isLessThan: cutoffTimestamp)
          .get();

      for (var doc in oldActivityLogs.docs) {
        await doc.reference.delete();
      }

      // Delete old device logs
      final oldDeviceLogs = await deviceLogsCollection
          .where('timestamp', isLessThan: cutoffTimestamp)
          .get();

      for (var doc in oldDeviceLogs.docs) {
        await doc.reference.delete();
      }

      // Log cleanup activity
      await logActivity(
        userId: 'system',
        event: 'cleanup_old_logs',
        description: 'Cleaned up logs older than $daysToKeep days',
        metadata: {
          'activityLogsDeleted': oldActivityLogs.docs.length,
          'deviceLogsDeleted': oldDeviceLogs.docs.length,
        },
      );
    } catch (e) {
      print('Error cleaning up old logs: $e');
      rethrow;
    }
  }
}