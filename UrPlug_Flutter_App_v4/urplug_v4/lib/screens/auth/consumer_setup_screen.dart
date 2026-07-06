import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../models/zone.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/zone_picker_widget.dart';
import '../home/home_screen.dart';

/// Consumer onboarding screen — appears once after a successful OTP login.
/// Collects:
///   1. Display name
///   2. Location (Region → District → Division → Parish → Landmark)
///
/// This data drives the zone-based matching engine so the consumer sees
/// service providers near them first.
class ConsumerSetupScreen extends StatefulWidget {
  final String phoneNumber;
  const ConsumerSetupScreen({super.key, required this.phoneNumber});

  @override
  State<ConsumerSetupScreen> createState() => _ConsumerSetupScreenState();
}

class _ConsumerSetupScreenState extends State<ConsumerSetupScreen> {
  final _nameController = TextEditingController();
  ZoneAddress? _selectedZone;
  bool _saving = false;
  String? _nameError;

  bool get _canProceed =>
      _nameController.text.trim().length >= 2 && _selectedZone != null;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _nameError = 'Enter your name (at least 2 characters).');
      return;
    }
    if (_selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your location to continue.')),
      );
      return;
    }

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simulate save

    if (!mounted) return;
    final app = pv.Provider.of<AppState>(context, listen: false);
    app.updateConsumer(displayName: name, zone: _selectedZone!);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.person_add_outlined,
                      color: AppColors.primaryGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Almost there!',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primaryGreenDark)),
                        Text(
                          'Tell us your name and where you are so we can '
                          'show you service providers near you.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryGreenDark
                                  .withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Name
              const Text('Your name',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                  setState(() {}); // refresh _canProceed
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: 'e.g. Sarah Nakato',
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 28),

              // Location
              const Text('Your location',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                'Select your area. Ur Plug uses this instead of GPS to '
                'match you with nearby service providers.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 14),

              ZonePickerWidget(
                showLandmark: false,
                onChanged: (zone) {
                  setState(() => _selectedZone = zone);
                },
              ),

              const SizedBox(height: 32),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed && !_saving ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Start exploring Ur Plug'),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _saving
                      ? null
                      : () {
                          // Skip — use default zone; still go to home
                          final app = pv.Provider.of<AppState>(
                              context, listen: false);
                          if (_nameController.text.trim().length >= 2) {
                            app.updateConsumer(
                                displayName: _nameController.text.trim(),
                                zone: null);
                          }
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (_) => false,
                          );
                        },
                  child: Text('Skip for now',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
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
    _nameController.dispose();
    super.dispose();
  }
}
