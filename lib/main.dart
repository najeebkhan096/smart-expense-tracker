import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screen/auth_wrapper.dart'; // Auth wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyApEf4GT-_md6XaCmP-deDU61HGDsxzbME",
    authDomain: "smartexpensetracker-10a29.firebaseapp.com",
    projectId: "smartexpensetracker-10a29",
    storageBucket: "smartexpensetracker-10a29.firebasestorage.app",
    messagingSenderId: "561615090696",
    appId: "1:561615090696:web:38aded78e46fd134640dbd",
    measurementId: "G-7CGQ16XESD",
  );

  await Firebase.initializeApp(options: firebaseConfig);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
