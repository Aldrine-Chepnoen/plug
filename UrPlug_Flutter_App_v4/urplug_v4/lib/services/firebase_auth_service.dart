// firebase_auth_service.dart
//
// DEMO / FlutLab mode — no Firebase packages required.
//
// Firebase is excluded from pubspec.yaml so the app compiles cleanly in
// FlutLab without RequireJS errors or pub.dev 400 failures.
//
// This service is a fully self-contained mock:
//   • sendOtp()   → always succeeds after a short delay (no SMS sent).
//   • verifyOtp() → accepts code "123456" for any number, rejects others.
//   • isSignedIn  → tracks sign-in state in memory.
//
// For production (native Android / iOS):
//   1. Add firebase_auth to pubspec.yaml
//   2. Replace this file with the Firebase implementation in
//      docs/firebase_auth_service_production.dart (provided separately).

class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  static const _validCode = '123456';
  bool _signedIn = false;

  bool get isSignedIn => _signedIn;

  /// Step 1 — simulate sending OTP.
  /// Always calls [onCodeSent] after a short delay.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorMessage) onError,
  }) async {
    // Basic validation
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.length < 10) {
      onError('Phone number too short. Try: +256 772 123456');
      return;
    }

    // Simulate network round-trip
    await Future.delayed(const Duration(milliseconds: 900));
    onCodeSent('demo-token-${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Step 2 — verify the OTP the user typed.
  /// Returns true if code == "123456", false otherwise.
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (smsCode.trim() == _validCode) {
      _signedIn = true;
      return true;
    }
    return false;
  }

  /// Sign out.
  Future<void> signOut() async {
    _signedIn = false;
  }
}
