import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';

class Budget {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<AppUser> members;
  final List<String> memberIds; // added for Firestore queries

  Budget({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.members,
    required this.memberIds,
  });

  /// Create Budget from Firestore document
  factory Budget.fromMap(String id, Map<String, dynamic> map) {
    final membersList = map['members'] != null
        ? List<AppUser>.from(
      (map['members'] as List).map((userMap) {
        final userData = Map<String, dynamic>.from(userMap);
        return AppUser.fromJson(
          id: userData['id'] ?? '',
          json: userData,
        );
      }),
    )
        : [];

    final memberIdsList = map['memberIds'] != null
        ? List<String>.from(map['memberIds'])
        : membersList.map((u) => u.id).toList();

    return Budget(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      members: membersList,
      memberIds: memberIdsList,
    );
  }

  /// Convert Budget to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members.map((user) => user.toJson()).toList(),
      'memberIds': memberIds.isNotEmpty ? memberIds : members.map((u) => u.id).toList(),
    };
  }

  /// CopyWith method for immutability
  Budget copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    List<AppUser>? members,
    List<String>? memberIds,
  }) {
    final updatedMembers = members ?? this.members;
    return Budget(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      members: updatedMembers,
      memberIds: memberIds ?? updatedMembers.map((u) => u.id).toList(),
    );
  }
}
