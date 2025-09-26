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

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePic,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  factory AppUser.fromJson({required Map<String, dynamic> json, required String id}) {
    return AppUser(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profilePic: json['profilePic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
    };
  }
}

/// ----------------------
/// Balance Model
/// ----------------------
class Balance {
  final String id;
  final String groupId;
  final String userId;
  final double balance;

  Balance({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.balance,
  });

  Balance copyWith({
    String? id,
    String? groupId,
    String? userId,
    double? balance,
  }) {
    return Balance(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
    );
  }

  factory Balance.fromJson({required Map<String, dynamic> json}) {
    return Balance(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'balance': balance,
    };
  }
}

/// ----------------------
/// Settlement Model
/// ----------------------
class Settlement {
  final String id;
  final String groupId;
  final String paidBy;
  final String paidTo;
  final double amount;
  final DateTime createdAt;

  Settlement({
    required this.id,
    required this.groupId,
    required this.paidBy,
    required this.paidTo,
    required this.amount,
    required this.createdAt,
  });

  Settlement copyWith({
    String? id,
    String? groupId,
    String? paidBy,
    String? paidTo,
    double? amount,
    DateTime? createdAt,
  }) {
    return Settlement(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      paidBy: paidBy ?? this.paidBy,
      paidTo: paidTo ?? this.paidTo,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Settlement.fromJson({required Map<String, dynamic> json}) {
    final createdAtValue = json['createdAt'];
    DateTime parsedDate;

    if (createdAtValue is Timestamp) {
      parsedDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      parsedDate = DateTime.parse(createdAtValue);
    } else {
      throw Exception('Invalid createdAt value');
    }

    return Settlement(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      paidBy: json['paidBy'] as String,
      paidTo: json['paidTo'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'paidBy': paidBy,
      'paidTo': paidTo,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
