import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modal/user_modal.dart';
import '../services/user_service.dart';
import 'home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Web: use signInWithPopup
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithPopup(googleProvider);

      final user = userCredential.user;
      if (user != null) {
        // Save user to Firestore
        final appUser = AppUser(
          id: user.uid,
          name: user.displayName ?? 'No Name',
          email: user.email ?? '',
          profilePic: user.photoURL,
        );
        await UserService().saveUser(user: appUser);

        // Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => signInWithGoogle(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
