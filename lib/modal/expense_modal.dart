import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';

/// ----------------------
/// Expense Model
/// ----------------------
class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final AppUser paidBy;
  final List<AppUser> splitAmong; // list of AppUser
  final DateTime createdAt;
  final String? notes;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    required this.createdAt,
    this.notes,
  });

  Expense copyWith({
    String? id,
    String? groupId,
    String? title,
    double? amount,
    AppUser? paidBy,
    List<AppUser>? splitAmong,
    DateTime? createdAt,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  /// Create Expense from Firestore map
  factory Expense.fromJson({required Map<String, dynamic> json, required String id}) {
    final createdAtValue = json['createdAt'];

    DateTime parsedDate;
    if (createdAtValue is Timestamp) {
      parsedDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      parsedDate = DateTime.parse(createdAtValue);
    } else {
      throw Exception('Invalid createdAt value');
    }

    return Expense(
      id: id,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: AppUser.fromJson(
        id: (json['paidBy'] as Map<String, dynamic>)['id'] ?? '',
        json: Map<String, dynamic>.from(json['paidBy']),
      ),
      splitAmong: json['splitAmong'] != null
          ? List<AppUser>.from(
        (json['splitAmong'] as List).map(
              (u) => AppUser.fromJson(
            id: (u as Map<String, dynamic>)['id'] ?? '',
            json: Map<String, dynamic>.from(u),
          ),
        ),
      )
          : [],
      createdAt: parsedDate,
      notes: json['notes'] as String?,
    );
  }

  /// Convert Expense to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'paidBy': paidBy.toJson(),
      'splitAmong': splitAmong.map((u) => u.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }
}
