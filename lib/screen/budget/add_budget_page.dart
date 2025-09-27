import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modal/budget_modal.dart';
import '../../modal/user_modal.dart';
import '../../services/firebase_service.dart';
import '../../utility/colors.dart';

class AddBudgetPage extends StatefulWidget {
  final String currentUserId; // pass logged-in user id here
  const AddBudgetPage({super.key, required this.currentUserId});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  List<AppUser> allUsers = [];
  List<String> selectedMemberIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final snapshot = await _firebaseService.getAllUsers();
    setState(() {
      allUsers = snapshot;
      // select the logged-in user by default
      if (!selectedMemberIds.contains(widget.currentUserId)) {
        selectedMemberIds.add(widget.currentUserId);
      }
    });
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate() || selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and select members')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final selectedMembers = allUsers
        .where((user) => selectedMemberIds.contains(user.id))
        .toList();

    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      createdAt: DateTime.now(),
      members: selectedMembers,
      memberIds: selectedMembers.map((u) => u.id).toList(),
      description: _descriptionController.text.trim(),
    );

    try {
      await _firebaseService.addBudget(budget: budget);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving budget: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Add Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 Form Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Budget Title',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Enter title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Members Selection with Checkboxes
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Members",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  allUsers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: allUsers.map((user) {
                      final isSelected =
                      selectedMemberIds.contains(user.id);
                      return CheckboxListTile(
                        title: Text(user.name,
                            style: GoogleFonts.poppins()),
                        subtitle: Text(user.email,
                            style: GoogleFonts.poppins(fontSize: 12)),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedMemberIds.add(user.id);
                            } else {
                              if (user.id != widget.currentUserId) {
                                selectedMemberIds.remove(user.id);
                              }
                            }
                          });
                        },
                        controlAffinity:
                        ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 Save Button
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                ),
                onPressed: _saveBudget,
                child: Text(
                  'Save Budget',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
