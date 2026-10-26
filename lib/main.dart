//firebase 1

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/student_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom green color seed
    const primaryGreen = Color(0xFF0F8A17);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        useMaterial3: true,
      ),
      home: const FirebaseHomePage(),
    );
  }
}

class FirebaseHomePage extends StatelessWidget {
  const FirebaseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF0F8A17);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Firebase',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done, size: 80, color: primaryGreen),
            const SizedBox(height: 16),
            const Text(
              'Firebase connected successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Create Student"),
            ),
          ],
        ),
      ),
    );
  }
}