import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';
import 'currency_modal.dart'; // Import the CurrencyManager

/// ----------------------
/// Split Type Enum
/// ----------------------
enum SplitType {
  equal,      // Split equally among all participants
  exact,      // Split by exact amounts
  percentage, // Split by percentage
  share,      // Split by shares
}

/// ----------------------
/// Expense Model
/// ----------------------
class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String currencyCode; // e.g., PKR, USD, QAR
  final AppUser paidBy;
  final List<AppUser> splitAmong; // list of AppUser
  final DateTime createdAt;
  final String? notes;
  final SplitType splitType; // ← Added SplitType

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    this.currencyCode = 'PKR', // default currency
    required this.paidBy,
    required this.splitAmong,
    required this.createdAt,
    this.notes,
    this.splitType = SplitType.equal, // default split type
  });

  Expense copyWith({
    String? id,
    String? groupId,
    String? title,
    double? amount,
    String? currencyCode,
    AppUser? paidBy,
    List<AppUser>? splitAmong,
    DateTime? createdAt,
    String? notes,
    SplitType? splitType,
  }) {
    return Expense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      splitType: splitType ?? this.splitType,
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

    // Convert string from Firestore to SplitType enum
    SplitType parsedSplitType = SplitType.equal;
    if (json['splitType'] != null) {
      parsedSplitType = SplitType.values.firstWhere(
            (e) => e.toString() == 'SplitType.${json['splitType']}',
        orElse: () => SplitType.equal,
      );
    }

    return Expense(
      id: id,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] ?? 'PKR',
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
      splitType: parsedSplitType,
    );
  }

  /// Convert Expense to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'currencyCode': currencyCode,
      'paidBy': paidBy.toJson(),
      'splitAmong': splitAmong.map((u) => u.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'splitType': splitType.toString().split('.').last, // store as string
    };
  }

  /// Get amount converted to base currency (PKR)
  double get amountInBase => CurrencyManager.toBase(amount, currencyCode);

  /// Format amount with currency symbol
  String get formattedAmount => CurrencyManager.format(amount, currencyCode);
}
