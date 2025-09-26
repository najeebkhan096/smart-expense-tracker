import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/modal/user_modal.dart';
import '../../modal/budget_modal.dart';
import '../../modal/expense_modal.dart';
import '../../services/firebase_service.dart';

class AddExpensePage extends StatefulWidget {
  final Budget budget;

  const AddExpensePage({super.key, required this.budget});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();

  AppUser? _paidBy;
  List<AppUser> _splitAmong = []; // store AppUser objects
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _splitAmong = List.from(widget.budget.members);
    _paidBy = widget.budget.members.isNotEmpty ? widget.budget.members.first : null;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() ||
        _splitAmong.isEmpty ||
        _paidBy == null) {
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
      amount: double.parse(_amountController.text.trim()),
      paidBy: _paidBy!,
      splitAmong: _splitAmong,
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
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Expense Title',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Enter amount';
                          if (double.tryParse(val) == null)
                            return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AppUser>(
                        value: _paidBy,
                        decoration: InputDecoration(
                          labelText: 'Paid By',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: widget.budget.members
                            .map(
                              (appUser) => DropdownMenuItem(
                            value: appUser,
                            child: Text(appUser.name),
                          ),
                        )
                            .toList(),
                        onChanged: (val) => setState(() => _paidBy = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white70,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      children: widget.budget.members.map((user) {
                        final isSelected = _splitAmong.contains(user);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(user.name, style: GoogleFonts.poppins()),
                          subtitle: Text(user.email),
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
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveExpense,
                  child: Text(
                    'Save Expense',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
