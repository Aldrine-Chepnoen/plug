import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'admin_dashboard_screen.dart';

/// Admin login screen — PIN-based access gate.
///
/// Demo PIN (FlutLab / development): 123456
///
/// In production this would check a Firebase custom claim
/// (role == 'admin') on the signed-in user's ID token, so
/// only accounts explicitly granted admin role can enter.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // ── Demo credentials ─────────────────────────────────────────────────────
  // Change these before going to production.
  static const _demoPin = '123456';

  final _pinController = TextEditingController();
  bool _obscure = true;
  bool _checking = false;
  String? _errorMessage;
  int _attempts = 0;
  static const _maxAttempts = 5;

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Enter the admin PIN.');
      return;
    }
    if (_attempts >= _maxAttempts) {
      setState(() => _errorMessage =
          'Too many failed attempts. Restart the app to try again.');
      return;
    }

    setState(() { _checking = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 600)); // simulate check

    if (!mounted) return;

    if (pin == _demoPin) {
      // Success — navigate to admin console
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      _attempts++;
      final remaining = _maxAttempts - _attempts;
      setState(() {
        _checking = false;
        _errorMessage = remaining > 0
            ? 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.'
            : 'Too many failed attempts.';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = _attempts >= _maxAttempts;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 20),
            SizedBox(width: 8),
            Text('Admin Access'),
          ],
        ),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Icon
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue.withValues(alpha: 0.25),
                        blurRadius: 24, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Colors.white, size: 38),
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: Text('Ur Plug Admin Console',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'This area is restricted to platform administrators only.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
              ),

              const SizedBox(height: 36),

              // PIN field
              TextField(
                controller: _pinController,
                obscureText: _obscure,
                keyboardType: TextInputType.number,
                maxLength: 12,
                enabled: !locked && !_checking,
                onSubmitted: (_) => _login(),
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Admin PIN',
                  prefixIcon: const Icon(Icons.lock_outline),
                  counterText: '',
                  errorText: _errorMessage,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off_outlined
                                 : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure ? 'Show PIN' : 'Hide PIN',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: locked || _checking ? null : _login,
                  child: _checking
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Sign in as Admin'),
                ),
              ),

              const SizedBox(height: 28),

              // Demo hint
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Demo / Preview Mode',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreenDark,
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            'PIN: 123456\n\n'
                            'In production, admin access is controlled by '
                            'Firebase custom claims — only accounts with '
                            'role: admin on their ID token can enter.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.primaryGreenDark
                                    .withValues(alpha: 0.85),
                                height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
