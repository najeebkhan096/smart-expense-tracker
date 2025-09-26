import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';

class Budget {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<AppUser> members;
  final List<String> memberIds;

  Budget({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.members,
    required this.memberIds,
  }) {
    // Debug: print when a Budget instance is created
    print('Budget Created: id=$id, title=$title, description=$description');
    print('Members: ${members.map((u) => u.name).toList()}');
    print('Member IDs: $memberIds');
    print('Created At: $createdAt');
  }

  /// Create Budget from Firestore document
  factory Budget.fromMap(String id, Map<String, dynamic> map) {
    print('Budget.fromMap called with id=$id and map=$map');

    // Handle members
    final membersList = map['members'] != null
        ? (map['members'] as List).map((userMap) {
            final userData = Map<String, dynamic>.from(userMap);
            final user = AppUser.fromJson(
              id: userData['id'] ?? '',
              json: userData,
            );
            print('Parsed Member: ${user.name}, id=${user.id}');
            return user;
          }).toList()
        : <AppUser>[];

    // Handle memberIds
    final memberIdsList = map['memberIds'] != null
        ? List<String>.from(map['memberIds'])
        : membersList.map((u) => u.id).toList();

    // Handle createdAt
    DateTime createdAtDate;
    if (map['createdAt'] is Timestamp) {
      createdAtDate = (map['createdAt'] as Timestamp).toDate();
      print('Parsed createdAt from Timestamp: $createdAtDate');
    } else if (map['createdAt'] is String) {
      createdAtDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      print('Parsed createdAt from String: $createdAtDate');
    } else {
      createdAtDate = DateTime.now();
      print('createdAt missing or invalid, using now: $createdAtDate');
    }
    print("all well");
    return Budget(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: createdAtDate,
      members: membersList,
      memberIds: memberIdsList,
    );
  }

  /// Convert Budget to Firestore data
  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members.map((user) => user.toJson()).toList(),
      'memberIds': memberIds.isNotEmpty
          ? memberIds
          : members.map((u) => u.id).toList(),
    };

    print('Budget.toMap called: $map');
    return map;
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
    final newBudget = Budget(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      members: updatedMembers,
      memberIds: memberIds ?? updatedMembers.map((u) => u.id).toList(),
    );

    print(
      'Budget.copyWith called. New Budget: id=${newBudget.id}, title=${newBudget.title}',
    );
    return newBudget;
  }
}
