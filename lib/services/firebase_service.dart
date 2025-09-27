import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../modal/budget_modal.dart';
import '../modal/expense_modal.dart';
import '../modal/user_modal.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- USERS ----------------
  /// Get all users in the system
  Future<List<AppUser>> getAllUsers() async {
    try {
      print('Fetching all users from Firestore...');
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => AppUser.fromJson(json: doc.data(), id: doc.id))
          .toList();
      print('Fetched ${users.length} users');
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // ---------------- BUDGETS ----------------
  /// Add a new budget to top-level collection
  Future<void> addBudget({required Budget budget}) async {
    try {
      print('Adding budget: ${budget.title} with ID: ${budget.id}');
      final budgetRef = _firestore.collection('budgets').doc(budget.id);
      await budgetRef.set(budget.toMap());
      print('Budget added successfully');
    } on FirebaseException catch (e) {
      print('FirebaseException in addBudget: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in addBudget: $e');
      rethrow;
    }
  }

  /// Update a budget
  Future<void> updateBudget({required Budget budget}) async {
    try {
      print('Updating budget ID: ${budget.id}');
      final budgetRef = _firestore.collection('budgets').doc(budget.id);
      await budgetRef.update(budget.toMap());
      print('Budget updated successfully');
    } on FirebaseException catch (e) {
      print('FirebaseException in updateBudget: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in updateBudget: $e');
      rethrow;
    }
  }

  /// Delete a budget completely
  Future<void> deleteBudget(String budgetId) async {
    try {
      print('Deleting budget ID: $budgetId');
      final budgetRef = _firestore.collection('budgets').doc(budgetId);
      await budgetRef.delete();
      print('Budget deleted successfully');
    } on FirebaseException catch (e) {
      print('FirebaseException in deleteBudget: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in deleteBudget: $e');
      rethrow;
    }
  }

  /// Stream budgets where the user is a member
  Stream<List<Budget>> getUserBudgetsStream(String uid) {
    print('Streaming budgets for user ID: $uid');
    return _firestore
        .collection('budgets')
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final budgets = snapshot.docs
              .map((doc) => Budget.fromMap(doc.id, doc.data()))
              .toList();
          print('Streaming ${budgets.length} budgets for user $uid');
          return budgets;
        });
  }

  // ---------------- EXPENSES ----------------
  /// Add expense to a budget
  Future<void> addExpense({
    required String budgetId,
    required Expense expense,
  }) async {
    try {
      print('Adding expense: ${expense.title} to budget ID: $budgetId');
      await _firestore
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toJson());
      print('Expense added successfully');
    } on FirebaseException catch (e) {
      print('FirebaseException in addExpense: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in addExpense: $e');
      rethrow;
    }
  }

  /// Get all expenses of a budget
  Future<List<Expense>> getExpenses({required String budgetId}) async {
    try {
      print('Fetching expenses for budget ID: $budgetId');
      final snapshot = await _firestore
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .get();

      final expenses = snapshot.docs
          .map((doc) => Expense.fromJson(json: doc.data(), id: doc.id))
          .toList();
      print('Fetched ${expenses.length} expenses');
      return expenses;
    } catch (e) {
      print('Error in getExpenses: $e');
      return [];
    }
  }

  /// Stream expenses of a budget
  Stream<List<Expense>> getExpensesStream(String budgetId) {
    print('Streaming expenses for budget ID: $budgetId');
    return _firestore
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .snapshots()
        .map((snapshot) {
          final expenses = snapshot.docs
              .map((doc) => Expense.fromJson(json: doc.data(), id: doc.id))
              .toList();
          print('Streaming ${expenses.length} expenses for budget $budgetId');
          return expenses;
        });
  }

  // New: updateExpense
  Future<void> updateExpense({
    required String budgetId,
    required Expense expense,
  }) async {
    await _firestore
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toJson());
  }

  /// Delete an expense by its ID under a specific budget
  Future<void> deleteExpense({
    required String budgetId,
    required String expenseId,
  }) async {
    try {
      await _firestore
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting expense: $e');
    }
  }

  // ---------------- SETTLEMENTS ----------------
  /// Add settlement to a budget
  Future<void> addSettlement({
    required String budgetId,
    required String paidBy,
    required String paidTo,
    required double amount,
    required DateTime createdAt,
  }) async {
    try {
      print(
        'Adding settlement of $amount from $paidBy to $paidTo in budget $budgetId',
      );
      final settlementRef = _firestore
          .collection('budgets')
          .doc(budgetId)
          .collection('settlements')
          .doc();

      await settlementRef.set({
        'id': settlementRef.id,
        'paidBy': paidBy,
        'paidTo': paidTo,
        'amount': amount,
        'createdAt': Timestamp.fromDate(createdAt),
      });
      print('Settlement added successfully');
    } catch (e) {
      print('Error in addSettlement: $e');
      rethrow;
    }
  }

  /// Logout the current user
  /// Logout the current user (including Google Sign-In)
  Future<void> logout() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      // Sign out from Google if signed in
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      googleSignIn.initialize(
        clientId:
            '561615090696-22b0uded1s21o7pg065lgb553ul59qs4.apps.googleusercontent.com',
      );
      try {
        await googleSignIn.signOut();
        print('Google user signed out');
      } catch (e) {
        print('Error signing out Google user: $e');
      }

      // Sign out from Firebase
      await _auth.signOut();

      print('Firebase user signed out');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  /// Example: Update user's currency in Firestore
  Future<void> updateUserCurrency(String userId, String currencyCode) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'currencyCode': currencyCode,
    });
  }
}
