// =============================================================================
//  features/auth/presentation/widgets/auth_wrapper.dart
//  Listens to Supabase Auth state and routes to either Login or Dashboard.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../screens/login_screen.dart';
import '../../../patients/presentation/screens/patient_dashboard_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        // If we have a session, show the main dashboard
        if (authState.session != null) {
          return const PatientDashboardScreen();
        }
        // Otherwise, force them to log in
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Auth Error: $error', 
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
    );
  }
}
