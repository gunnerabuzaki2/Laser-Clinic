import 'package:supabase_flutter/supabase_flutter.dart';

String formatErrorMessage(Object error) {
  final errorStr = error.toString().toLowerCase();

  // Network / Connection errors
  if (errorStr.contains('socketexception') ||
      errorStr.contains('failed host lookup') ||
      errorStr.contains('connection refused') ||
      errorStr.contains('network is unreachable') ||
      errorStr.contains('handshake error')) {
    return 'Please check your internet connection and try again.';
  }

  // Supabase specific errors
  if (error is PostgrestException) {
    if (error.code == '23505') {
      return 'This record already exists.';
    }
    // Add more specific PostgrestException checks if needed
    return 'A server error occurred. Please try again later.';
  }

  if (error is AuthException) {
    return error.message; // Auth exceptions usually have decent messages
  }

  // App-specific validations
  if (errorStr.contains('phone number already exists')) {
    return 'A patient with this phone number already exists.';
  }

  // Generic fallback
  return 'An unexpected error occurred. Please try again or contact support.';
}
