import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../theme/app_colors.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '+256 7');
  bool _sending = false;
  String? _fieldError;
  String? _bannerError;

  String? _validate(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.isEmpty) return 'Please enter your phone number.';
    if (!cleaned.startsWith('+')) return 'Include country code, e.g. +256 772 123456';
    if (cleaned.length < 10) return 'Number too short — please check.';
    return null;
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final validationError = _validate(phone);
    if (validationError != null) {
      setState(() { _fieldError = validationError; _bannerError = null; });
      return;
    }
    setState(() { _sending = true; _fieldError = null; _bannerError = null; });

    await FirebaseAuthService.instance.sendOtp(
      phoneNumber: phone.replaceAll(' ', ''),
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _sending = false);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phone,
            verificationId: verificationId,
          ),
        ));
      },
      onError: (message) {
        if (!mounted) return;
        setState(() { _sending = false; _bannerError = message; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              // Logo
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.gold, size: 36),
              ),
              const SizedBox(height: 22),
              Text('Welcome to Ur Plug',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Find trusted local service providers near you\n'
                '— no data-hungry maps needed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              // Demo banner
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.gold, size: 17),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Demo mode — enter any Uganda number, '
                        'then use code 123456 to sign in.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A6300),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Phone field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_fieldError != null || _bannerError != null) {
                    setState(() { _fieldError = null; _bannerError = null; });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+256 772 123456',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  errorText: _fieldError,
                ),
              ),
              // Error banner
              if (_bannerError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 17),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_bannerError!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.danger)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendOtp,
                  child: _sending
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Send OTP'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'By continuing you agree to Ur Plug\'s Terms and '
                'the Uganda Data Protection and Privacy Act 2019.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
