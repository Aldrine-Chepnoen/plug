import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../models/service_category.dart';
import '../../models/zone.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/zone_picker_widget.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedCategories = {};
  final _descController      = TextEditingController();
  final _nationalIdController= TextEditingController();
  final _contactController   = TextEditingController();
  ZoneAddress? _selectedZone;
  bool _submitting      = false;
  bool _wantsGoldTier   = false;
  bool _zoneError       = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one service category.')),
      );
      return;
    }
    if (_selectedZone == null) {
      setState(() => _zoneError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete your location (all 4 levels).')),
      );
      return;
    }
    setState(() => _submitting = true);

    // TODO (production): submit to Firestore — store National ID securely,
    // create provider row as Standard tier by default; if _wantsGoldTier,
    // create a verification-queue entry for admin document review.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() => _submitting = false);
    final app = pv.Provider.of<AppState>(context, listen: false);
    app.updateConsumer(displayName: app.currentUser.displayName, zone: _selectedZone);
    app.completeProviderRegistration('p1');
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_wantsGoldTier
            ? 'Registered! Your Gold Tier documents are pending admin review.'
            : 'You\'re registered as a Standard Tier provider.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register as a Provider')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Service categories ──────────────────────────────────────
            const Text('Service categories',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              'Tick every category your business covers.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: DefaultCategories.all.map((c) {
                final selected = _selectedCategories.contains(c.id);
                return FilterChip(
                  avatar: Icon(c.icon, size: 16),
                  label: Text(c.label),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    v ? _selectedCategories.add(c.id)
                      : _selectedCategories.remove(c.id);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // ── Business description ────────────────────────────────────
            const Text('Business description',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Describe your services, experience and what makes you stand out...',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 22),

            // ── Your Service Location ───────────────────────────────────
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text('Your service location',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ]),
            const SizedBox(height: 6),
            Text(
              'Consumers near your selected area will see you first in search '
              'results. Select Region → District → Division → Parish, then '
              'add a local landmark to help customers find you.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            if (_zoneError) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.error_outline,
                      color: AppColors.danger, size: 16),
                  SizedBox(width: 8),
                  Text('Please complete all location fields.',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 13)),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            ZonePickerWidget(
              showLandmark: true,
              initial: pv.Provider.of<AppState>(context, listen: false)
                  .currentUser
                  .homeZone,
              onChanged: (zone) {
                setState(() {
                  _selectedZone = zone;
                  _zoneError = false;
                });
              },
            ),
            const SizedBox(height: 22),

            // ── Contact & ID ────────────────────────────────────────────
            const Text('Contact & identity',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined),
                labelText: 'National ID number',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined),
                labelText: 'Contact phone number',
                hintText: '+256 7XX XXX XXX',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 22),

            // ── Gold Tier ───────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Row(children: [
                  const Icon(Icons.verified_outlined,
                      color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  const Text('Apply for Gold Tier',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
                subtitle: const Text(
                  'Requires URA TIN, URSB certificate, or trading licence '
                  'for admin review. Gold providers rank first in all searches.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _wantsGoldTier,
                activeColor: AppColors.gold,
                onChanged: (v) => setState(() => _wantsGoldTier = v),
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Registration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _nationalIdController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
