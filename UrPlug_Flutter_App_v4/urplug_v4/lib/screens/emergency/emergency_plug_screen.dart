import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/service_category.dart';
import '../../theme/app_colors.dart';
import '../../widgets/provider_card.dart';
import '../provider/public_provider_profile_screen.dart';

class EmergencyPlugScreen extends StatefulWidget {
  const EmergencyPlugScreen({super.key});

  @override
  State<EmergencyPlugScreen> createState() => _EmergencyPlugScreenState();
}

class _EmergencyPlugScreenState extends State<EmergencyPlugScreen> {
  bool _alertSent = false;

  Future<void> _confirmCategory() async {
    final category = await showModalBottomSheet<ServiceCategory>(
      context: context,
      builder: (_) => _CategoryPicker(),
    );
    if (category == null) return;
    setState(() => _alertSent = true);
    // TODO (production): push via FCM to available Gold + Standard providers in the
    // consumer's zone; SMS fallback where data connectivity is poor.
  }

  @override
  Widget build(BuildContext context) {
    if (_alertSent) {
      final responders = MockData.providers.take(3).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Plug')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primaryGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Alert sent to available providers nearby. You choose who to contact — no one is auto-assigned.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Responding providers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            ...responders.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProviderCard(
                    provider: p,
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => PublicProviderProfileScreen(providerId: p.id)),
                    ),
                  ),
                )),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.danger, size: 44),
              const SizedBox(height: 12),
              const Text('Emergency Plug', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Instantly alert available providers near you for urgent needs. '
                'You stay in control — you pick who to contact.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _confirmCategory,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x33E0433D), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos_rounded, color: Colors.white, size: 40),
                      SizedBox(height: 6),
                      Text('SOS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What do you need urgently?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DefaultCategories.all.map((c) {
                return ActionChip(
                  avatar: Icon(c.icon, size: 16),
                  label: Text(c.label),
                  onPressed: () => Navigator.of(context).pop(c),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
