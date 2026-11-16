import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StudentInformationApp());
}

class StudentInformationApp extends StatelessWidget {
  const StudentInformationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF0C5132);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Information App',
      theme: ThemeData(
        colorSchemeSeed: deepGreen,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: deepGreen),
              ),
            );
          }
          // Kung nakalog-in, ipakita ang DashboardPage; kung hindi, LoginPage
          return snapshot.hasData ? const DashboardPage() : const LoginPage();
        },
      ),
    );
  }
}