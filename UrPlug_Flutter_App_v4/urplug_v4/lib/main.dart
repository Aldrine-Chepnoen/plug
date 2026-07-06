import 'package:flutter/material.dart';
import 'app.dart';

// ── Firebase note ────────────────────────────────────────────────────────────
// Firebase is excluded from pubspec.yaml for FlutLab compatibility.
// The app runs in full demo mode: any phone number + OTP "123456".
//
// To integrate real Firebase for a production build:
//   1. Add firebase_core, firebase_auth, cloud_firestore to pubspec.yaml
//   2. Run: flutterfire configure  (generates firebase_options.dart)
//   3. Uncomment the Firebase.initializeApp call below
//   4. Update lib/services/firebase_auth_service.dart (demo stubs → real auth)
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase.initializeApp — uncomment for production:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const UrPlugApp());
}
