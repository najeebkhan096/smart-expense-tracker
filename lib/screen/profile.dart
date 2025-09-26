import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modal/user_modal.dart';
import '../../services/firebase_service.dart';
import '../modal/currency_modal.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;
  final FirebaseService _firebaseService = FirebaseService();

  ProfilePage({super.key, required this.user});

  void _logout(BuildContext context) async {
    await _firebaseService.logout(); // Implement logout in FirebaseService
    Navigator.of(context).pushReplacementNamed('/login'); // Adjust route
  }

  void _editProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/edit_profile', arguments: user);
  }

  void _changeCurrency(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: CurrencyManager.currencies.map((currency) {
            return ListTile(
              title: Text('${currency.code} (${currency.symbol})'),
              onTap: () async {
                await _firebaseService.updateUserCurrency(
                  user.id,
                  currency.code,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Currency updated to ${currency.code}'),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade200,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : 'U',
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            title: 'Name',
            subtitle: user.name,
            icon: Icons.person,
          ),
          _buildInfoTile(
            title: 'Email',
            subtitle: user.email,
            icon: Icons.email,
          ),
          _buildInfoTile(
            title: 'Currency',
            subtitle: user.currencyCode ?? 'PKR',
            icon: Icons.attach_money,
          ),
          const Divider(height: 32, thickness: 1),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.deepPurple),
            title: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            onTap: () => _editProfile(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.currency_exchange,
              color: Colors.deepPurple,
            ),
            title: Text(
              'Change Currency',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            onTap: () => _changeCurrency(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
