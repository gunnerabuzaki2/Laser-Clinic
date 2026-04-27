// =============================================================================
//  main.dart
//  Entry point for the Laser Clinic Manager desktop application.
//
//  HOW TO RUN:
//  1. Fill in your Supabase URL and Anon Key in lib/core/supabase_config.dart
//  2. Run: flutter pub get
//  3. Run: flutter run -d windows   (or -d linux)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';
import 'core/theme.dart';
import 'features/patients/presentation/screens/patient_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase — replace the placeholders in supabase_config.dart
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    // ProviderScope enables Riverpod throughout the widget tree
    const ProviderScope(
      child: LaserClinicApp(),
    ),
  );
}

class LaserClinicApp extends StatelessWidget {
  const LaserClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Clinic Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const PatientDashboardScreen(),
    );
  }
}
