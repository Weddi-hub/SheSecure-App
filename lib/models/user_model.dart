import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;
  final String? profileImage;
  final List<String>? connectedDevices;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.profileImage,
    this.connectedDevices,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullName: map['fullName'],
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profileImage: map['profileImage'],
      connectedDevices: List<String>.from(map['connectedDevices'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
      'connectedDevices': connectedDevices ?? [],
    };
  }
}