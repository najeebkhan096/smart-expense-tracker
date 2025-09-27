import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';
import '../../modal/budget_modal.dart';
import '../../modal/currency_modal.dart';
import '../../modal/expense_modal.dart';
import '../../services/firebase_service.dart';
import '../../utility/colors.dart';

class AddExpensePage extends StatefulWidget {
  final Budget budget;
  final AppUser currentUser;

  const AddExpensePage({
    super.key,
    required this.budget,
    required this.currentUser,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();

  AppUser? _paidBy;
  List<AppUser> _splitAmong = [];
  bool _isLoading = false;

  String _selectedCurrency = 'PKR';
  SplitType _selectedSplitType = SplitType.equal;

  @override
  void initState() {
    super.initState();
    // 🔹 Initially all members selected for splitting
    _splitAmong = List.from(widget.budget.members);
    _paidBy = widget.currentUser;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.budget.id,
      title: _titleController.text.trim(),
      amount: _amountController.text.isNotEmpty
          ? double.parse(_amountController.text.trim())
          : 0.0,
      currencyCode: _selectedCurrency,
      paidBy: _paidBy!,
      splitAmong: _splitAmong,
      splitType: _selectedSplitType,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await _firebaseService.addExpense(
        budgetId: widget.budget.id,
        expense: expense,
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Add Expense',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Title & Amount
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Expense Title',
                          prefixIcon: const Icon(Icons.title),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) =>
                        val == null || val.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter amount';
                          if (double.tryParse(val) == null) return 'Enter valid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 ExpansionTile for Additional Details
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              color: AppColors.card,
              child: ExpansionTile(
                title: Text("More Details",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Description / Notes (optional)',
                      prefixIcon: const Icon(Icons.note),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Currency
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: const Icon(Icons.currency_exchange),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: CurrencyManager.currencies
                        .map((c) => DropdownMenuItem(
                        value: c.code,
                        child: Text('${c.code} (${c.symbol})')))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                  ),
                  const SizedBox(height: 12),

                  // Paid By
                  DropdownButtonFormField<AppUser>(
                    value: _paidBy,
                    decoration: InputDecoration(
                      labelText: 'Paid By',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: widget.budget.members
                        .map((user) =>
                        DropdownMenuItem(value: user, child: Text(user.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _paidBy = val),
                  ),
                  const SizedBox(height: 12),

                  // Split Type
                  DropdownButtonFormField<SplitType>(
                    value: _selectedSplitType,
                    decoration: InputDecoration(
                      labelText: 'Split Type',
                      prefixIcon: const Icon(Icons.call_split),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: SplitType.values
                        .map((st) =>
                        DropdownMenuItem(value: st, child: Text(st.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSplitType = val!),
                  ),
                  const SizedBox(height: 12),

                  // Split Among Members
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    color: AppColors.inputBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: widget.budget.members.map((user) {
                          final isSelected = _splitAmong.contains(user);

                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(user.name,
                                style: GoogleFonts.poppins()),
                            subtitle: Text(user.email,
                                style: GoogleFonts.poppins(fontSize: 12)),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _splitAmong.add(user);
                                } else {
                                  _splitAmong.remove(user);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveExpense,
                child: Text('Save Expense',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
