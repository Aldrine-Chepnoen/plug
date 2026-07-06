import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../theme/app_colors.dart';
import '../auth/consumer_setup_screen.dart';
import '../home/home_screen.dart';
import 'location_setup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _verifying = false;
  String? _errorMessage;

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Enter the 6-digit code.');
      return;
    }
    setState(() { _verifying = true; _errorMessage = null; });

    final success = await FirebaseAuthService.instance.verifyOtp(
      verificationId: widget.verificationId,
      smsCode: code,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ConsumerSetupScreen(phoneNumber: widget.phoneNumber),
        ),
        (_) => false,
      );
    } else {
      setState(() {
        _verifying = false;
        _errorMessage = 'Incorrect code. Use 123456 in demo mode.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your number')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We sent a 6-digit code to', style: theme.textTheme.bodyLarge),
            Text(widget.phoneNumber,
                style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.gold, size: 17),
                const SizedBox(width: 10),
                Text('Demo mode — enter: 123456',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8A6300),
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofocus: true,
              onChanged: (v) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
                if (v.trim().length == 6) _verify();
              },
              style: const TextStyle(
                  fontSize: 32, letterSpacing: 10, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '──────',
                counterText: '',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifying ? null : _verify,
                child: _verifying
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Verify & Continue'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Change number / Resend'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
