import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final List<String> preferences;
  final int loyaltyPoints;
  final bool isActive;
  final Timestamp createdAt;

  CustomerModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.preferences,
    required this.createdAt,
    this.loyaltyPoints = 0,
    this.isActive = true,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      preferences: List<String>.from(map['preferences'] ?? []),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'loyaltyPoints': loyaltyPoints,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
