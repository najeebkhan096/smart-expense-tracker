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
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithPopup(googleProvider);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or illustration
              const Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 100,
                color: Colors.deepPurple.shade400,
              ),
              const SizedBox(height: 20),

              // App Title
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const Spacer(),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => signInWithGoogle(context),
                  icon: Image.asset(
                    'images/google.webp',
                    height: 24,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
