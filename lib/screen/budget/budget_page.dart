import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';
import 'package:smart_expense_tracker/utility/colors.dart';
import '../../modal/budget_modal.dart';
import '../../modal/currency_modal.dart';
import '../../modal/expense_modal.dart';
import '../../services/firebase_service.dart';
import '../expense/add_expense.dart';

class BudgetDetailPage extends StatelessWidget {
  final Budget budget;
  final String userCurrency;
  final AppUser appUser;

  const BudgetDetailPage({
    super.key,
    required this.budget,
    required this.userCurrency,
    required this.appUser,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        title: Text(
          budget.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firebaseService.getExpensesStream(budget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data ?? [];

          // 🔹 Total spent (all expenses converted to user currency)
          double totalSpent = 0;
          for (var e in expenses) {
            totalSpent += CurrencyManager.convert(
              e.amount,
              from: e.currencyCode,
              to: userCurrency,
            );
          }

          // 🔹 Total owed (for current logged-in user only)
          double totalOwed = 0;
          for (var e in expenses) {
            if (e.splitType == SplitType.equal) {
              if (e.splitAmong.any((u) => u.email == appUser.email)) {
                totalOwed += CurrencyManager.convert(
                  e.amount / e.splitAmong.length,
                  from: e.currencyCode,
                  to: userCurrency,
                );
              }
            }
            // 🔹 Handle other split types later if needed
          }

          double netDebt = totalSpent - totalOwed;

          return Column(
            children: [
              SizedBox(height: 20),
              // 🔹 Banner / Summary Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Budget Summary",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBannerItem(
                          "Members",
                          "${budget.members.length}",
                          Colors.white,
                        ),
                        _buildBannerItem(
                          "Total Spent",
                          CurrencyManager.format(totalSpent, userCurrency),
                          Colors.white,
                        ),
                        _buildBannerItem(
                          "You Owe",
                          CurrencyManager.format(totalOwed, userCurrency),
                          Colors.white70,
                        ),
                        _buildBannerItem(
                          "Net Debt",
                          CurrencyManager.format(netDebt, userCurrency),
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses added yet.',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final color =
                              Colors.primaries[index % Colors.primaries.length];

                          // 🔹 Calculate shares for equal split
                          Map<String, double> shares = {};
                          if (expense.splitType == SplitType.equal) {
                            final shareAmount =
                                expense.amount / expense.splitAmong.length;
                            for (var user in expense.splitAmong) {
                              shares[user.email] = CurrencyManager.convert(
                                shareAmount,
                                from: expense.currencyCode,
                                to: userCurrency,
                              );
                            }
                          }

                          return Card(
                            color: Colors.white,
                            elevation: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                expense.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Paid by: ${expense.paidBy.name}',
                                style: GoogleFonts.poppins(
                                  color: Colors.black45,
                                ),
                              ),
                              trailing: Text(
                                CurrencyManager.format(
                                  CurrencyManager.convert(
                                    expense.amount,
                                    from: expense.currencyCode,
                                    to: userCurrency,
                                  ),
                                  userCurrency,
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // 🔹 Expanded details
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (expense.notes != null &&
                                          expense.notes!.isNotEmpty)
                                        Text(
                                          "Notes: ${expense.notes}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Split Type: ${expense.splitType.name}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Currency: ${expense.currencyCode}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Created At: ${expense.createdAt.toLocal()}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const Divider(color: Colors.white38),
                                      Text(
                                        "Members & Shares:",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      ...expense.splitAmong.map((u) {
                                        final share = shares[u.email] ?? 0;
                                        return Text(
                                          "• ${u.name} - ${CurrencyManager.format(share, userCurrency)}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black45,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AddExpensePage(budget: budget, currentUser: appUser),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBannerItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
