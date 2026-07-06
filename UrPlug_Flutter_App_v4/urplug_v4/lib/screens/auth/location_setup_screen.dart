import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../models/zone.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/zone_picker_widget.dart';
import '../home/home_screen.dart';

/// Shown immediately after the first OTP sign-in, before the home screen.
/// Lets the consumer set their location (district, division, parish, landmark)
/// which drives the zone-based provider matching engine throughout the app.
///
/// The user may also skip and set it later from Profile → Edit Location.
class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  ZoneAddress? _selectedZone;
  bool _saving = false;

  void _goHome() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _save() async {
    if (_selectedZone == null) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    pv.Provider.of<AppState>(context, listen: false)
        .setConsumerZone(_selectedZone!);
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pin_drop_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Set Your Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                    'Ur Plug uses your district, division, and parish — '
                    'not GPS — to show you service providers near you. '
                    'No tracking, no battery drain.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.45),
                  ),
                ],
              ),
            ),

            // ── Zone picker ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where are you located?',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Select your region, district, division, and parish. '
                      'You can change this any time from your profile.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55)),
                    ),
                    const SizedBox(height: 20),
                    ZonePickerWidget(
                      onChanged: (zone) =>
                          setState(() => _selectedZone = zone),
                      showLandmark: false,
                    ),
                  ],
                ),
              ),
            ),

            // ── Action buttons ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedZone == null || _saving)
                          ? null
                          : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save & Continue'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _goHome,
                      child: Text(
                        'Skip for now — set later from Profile',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
