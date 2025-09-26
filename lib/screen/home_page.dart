import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/screen/budget/edit_budget_page.dart';
import 'package:smart_expense_tracker/screen/profile.dart';
import '../modal/budget_modal.dart';
import '../modal/user_modal.dart';
import '../services/firebase_service.dart';
import 'budget/add_budget_page.dart';
import 'budget/budget_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  FirebaseService get _firebaseService => FirebaseService();

  /// Stream for current logged-in user
  Stream<AppUser?> get currentUserStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? AppUser.fromJson(json: doc.data()!, id: doc.id)
              : null,
        );
  }

  /// Delete budget
  Future<void> _deleteBudget(BuildContext context, Budget budget) async {
    try {
      debugPrint('Deleting budget: ${budget.title} (${budget.id})');
      await _firebaseService.deleteBudget(budget.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted budget: ${budget.title}')),
      );
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting budget: $e')));
    }
  }

  /// Edit budget
  void _editBudget(BuildContext context, Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBudgetPage(budget: budget)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: currentUserStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Scaffold(body: Center(child: Text("User not found")));
        }

        final appUser = userSnapshot.data!;
        debugPrint('Current user: ${appUser.name}, id=${appUser.id}');

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            title: Text(
              'Hello, ${appUser.name}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(user: appUser),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: appUser.profilePic != null
                        ? CachedNetworkImageProvider(appUser.profilePic!)
                        : null,
                    child: appUser.profilePic == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: StreamBuilder<List<Budget>>(
              stream: _firebaseService.getUserBudgetsStream(appUser.id),
              builder: (context, budgetSnapshot) {
                if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!budgetSnapshot.hasData || budgetSnapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No budgets yet.\nTap + to create one!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final budgets = budgetSnapshot.data!;
                debugPrint(
                  'Streaming ${budgets.length} budgets for user ${appUser.id}',
                );

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final color =
                        Colors.primaries[index % Colors.primaries.length];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BudgetDetailPage(budget: budget, userCurrency: appUser.currencyCode,),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [color.shade300, color.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Members: ${budget.members.length}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total:',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editBudget(context, budget);
                                } else if (value == 'delete') {
                                  _deleteBudget(context, budget);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AddBudgetPage()));
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
