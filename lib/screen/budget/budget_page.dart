import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modal/budget_modal.dart';
import '../../modal/currency_modal.dart';
import '../../modal/expense_modal.dart';
import '../../services/firebase_service.dart';
import '../expense/add_expense.dart';
import '../expense/edit_expense.dart';

class BudgetDetailPage extends StatelessWidget {
  final Budget budget;
  final String userCurrency; // ← added

  const BudgetDetailPage({
    super.key,
    required this.budget,
    required this.userCurrency, // ← required
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          budget.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<Expense>>(
              stream: _firebaseService.getExpensesStream(budget.id),
              builder: (context, snapshot) {
                double total = 0;
                // Convert each expense to the user's selected currency
                total = snapshot.data!
                    .map(
                      (e) => CurrencyManager.convert(
                        e.amount,
                        from: e.currencyCode ?? 'PKR',
                        to: userCurrency,
                      ),
                    )
                    .fold(0.0, (prev, element) => prev + element);

                return Center(
                  child: Text(
                    'Total: ${CurrencyManager.format(total, userCurrency)}', // ← use userCurrency
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firebaseService.getExpensesStream(budget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No expenses added yet.',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final expenses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final color = Colors.primaries[index % Colors.primaries.length];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.shade300, color.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    expense.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Paid by: ${expense.paidBy.name}\nSplit among: ${expense.splitAmong.map((e) => e.name).join(', ')}',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyManager.format(
                          expense.amount,
                          expense.currencyCode ??
                              userCurrency, // ← use userCurrency
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditExpensePage(
                                  budget: budget,
                                  expense: expense,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            await _firebaseService.deleteExpense(
                              budgetId: budget.id,
                              expenseId: expense.id,
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddExpensePage(budget: budget)),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
