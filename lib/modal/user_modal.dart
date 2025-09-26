import 'package:cloud_firestore/cloud_firestore.dart';

/// ----------------------
/// User Model
/// ----------------------
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePic;
  final String currencyCode; // e.g., PKR, USD, QAR

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePic,
    this.currencyCode = 'PKR', // default PKR
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    String? currencyCode,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  // Equality based on `id`
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppUser && other.id == id);

  @override
  int get hashCode => id.hashCode;

  factory AppUser.fromJson({
    required Map<String, dynamic> json,
    required String id,
  }) {
    return AppUser(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profilePic: json['profilePic'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'PKR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
      'currencyCode': currencyCode,
    };
  }
}
