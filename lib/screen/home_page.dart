import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/screen/budget/edit_budget_page.dart';
import 'package:smart_expense_tracker/screen/profile.dart';
import 'package:smart_expense_tracker/utility/colors.dart';
import '../modal/budget_modal.dart';
import '../modal/user_modal.dart';
import '../services/firebase_service.dart';
import 'budget/add_budget_page.dart';
import 'budget/budget_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  FirebaseService get _firebaseService => FirebaseService();

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

  Future<void> _deleteBudget(BuildContext context, Budget budget) async {
    try {
      await _firebaseService.deleteBudget(budget.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted budget: ${budget.title}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting budget: $e')));
    }
  }

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

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
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
            decoration: const BoxDecoration(),
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
                            builder: (_) => BudgetDetailPage(
                              budget: budget,
                              userCurrency: appUser.currencyCode,
                              appUser: appUser,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [color.shade400, color.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
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
                                    'Tap to view details',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
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
            backgroundColor: AppColors.primary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddBudgetPage(currentUserId: appUser.id),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
