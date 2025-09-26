// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../modal/user_modal.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Sign in with Google
//   Future<AppUser?> signInWithGoogle() async {
//     UserCredential userCredential;
//
//     if (kIsWeb) {
//       // Web login
//       GoogleAuthProvider googleProvider = GoogleAuthProvider();
//       userCredential = await _auth.signInWithPopup(googleProvider);
//     } else {
//       // Mobile login
//
//     }
//
//     final user = userCredential.user;
//     if (user == null) return null;
//
//     final appUser = AppUser(
//       uid: user.uid,
//       name: user.displayName ?? 'No Name',
//       email: user.email ?? '',
//       photoUrl: user.photoURL,
//     );
//
//     await _firestore.collection('users').doc(user.uid).set(
//       appUser.toMap(),
//       SetOptions(merge: true),
//     );
//
//     return appUser;
//   }
//
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
//
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
// }
