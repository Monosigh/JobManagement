import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'views/login_page.dart';
import 'database/database_helper.dart';

void main() async {
  // Ensure Flutter binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for web and desktop platforms only
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Initialize for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // For mobile platforms (Android/iOS), use the default sqflite factory

  // Initialize database and ensure user profile exists
  final dbHelper = DatabaseHelper();
  await dbHelper.ensureUserProfileExists();

  runApp(const JobManagementApp());
}

class JobManagementApp extends StatelessWidget {
  const JobManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Management for Workshop Mechanics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
