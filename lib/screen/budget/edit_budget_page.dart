import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modal/budget_modal.dart';
import '../../modal/user_modal.dart';
import '../../services/firebase_service.dart';

class EditBudgetPage extends StatefulWidget {
  final Budget budget;

  const EditBudgetPage({super.key, required this.budget});

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();

  List<AppUser> allUsers = [];
  List<String> selectedMemberIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.budget.title;
    selectedMemberIds = widget.budget.members.map((e) => e.id).toList();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final snapshot = await _firebaseService.getAllUsers();
    setState(() {
      allUsers = snapshot;
    });
  }

  void _saveBudget() async {
    if (_titleController.text.trim().isEmpty || selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title and select members')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Map selected IDs to AppUser objects
    final updatedMembers = allUsers
        .where((user) => selectedMemberIds.contains(user.id))
        .toList();

    final updatedBudget = widget.budget.copyWith(
      title: _titleController.text.trim(),
      members: updatedMembers,
    );

    await _firebaseService.updateBudget(budget: updatedBudget);

    if (mounted) Navigator.pop(context);

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Edit Budget', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Budget Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white70,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView(
                    children: allUsers.map((user) {
                      final isSelected = selectedMemberIds.contains(user.id);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(user.name, style: GoogleFonts.poppins()),
                        subtitle: Text(user.email, style: GoogleFonts.poppins(fontSize: 12)),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedMemberIds.add(user.id);
                            } else {
                              selectedMemberIds.remove(user.id);
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Save Changes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
