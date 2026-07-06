import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../models/chat_and_jobs.dart';
import '../../models/zone.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../admin/admin_login_screen.dart';
import '../provider/provider_dashboard_screen.dart';
import '../../widgets/zone_picker_widget.dart';
import 'provider_registration_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = pv.Provider.of<AppState>(context);
    final user = app.currentUser;

    if (app.mode == AppMode.provider && user.isRegisteredProvider) {
      return const ProviderDashboardScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // ── User card ──────────────────────────────────────────────────
          Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryGreenLight,
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0] : '?',
                style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(user.maskedPhone,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6))),
              ],
            ),
          ]),

          const SizedBox(height: 16),

          // ── Location summary ───────────────────────────────────────────
          _LocationSummaryTile(zone: user.homeZone),

          const SizedBox(height: 16),

          // ── Provider toggle ────────────────────────────────────────────
          if (user.isRegisteredProvider)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.storefront_outlined,
                    color: AppColors.primaryGreen),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Switch to Provider Mode',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Switch(
                  value: app.mode == AppMode.provider,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (_) => app.toggleMode(),
                ),
              ]),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (_) => const ProviderRegistrationScreen())),
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Register as a Service Provider'),
              ),
            ),

          const SizedBox(height: 16),
          const Divider(),

          _ProfileTile(
              icon: Icons.edit_location_alt_outlined,
              label: 'Edit My Location',
              onTap: () => _showLocationEditor(context, app)),
          _ProfileTile(
              icon: Icons.bookmark_border,
              label: 'My Saved Providers',
              onTap: () {}),
          _ProfileTile(
              icon: Icons.star_border,
              label: 'My Reviews',
              onTap: () {}),

          const Divider(),

          _ProfileTile(
              icon: Icons.dark_mode_outlined,
              label: 'Theme',
              onTap: () => _showThemeSheet(context, app)),
          _ProfileTile(
              icon: Icons.person_add_alt_outlined,
              label: 'Invite a Friend',
              onTap: () {}),

          // ── About — contains the secret admin tap ──────────────────────
          _AboutTile(),

          const Divider(),

          _ProfileTile(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: () {},
              isDestructive: true),
        ],
      ),
    );
  }

  void _showLocationEditor(BuildContext context, AppState app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationEditorSheet(app: app),
    );
  }

  void _showThemeSheet(BuildContext context, AppState app) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: app.themeMode,
              onChanged: (v) { app.setThemeMode(v!); Navigator.pop(context); },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: app.themeMode,
              onChanged: (v) { app.setThemeMode(v!); Navigator.pop(context); },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: app.themeMode,
              onChanged: (v) { app.setThemeMode(v!); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location summary tile ─────────────────────────────────────────────────
class _LocationSummaryTile extends StatelessWidget {
  final ZoneAddress? zone;
  const _LocationSummaryTile({this.zone});

  @override
  Widget build(BuildContext context) {
    final hasZone = zone != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasZone
            ? AppColors.primaryGreenLight
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasZone
              ? AppColors.primaryGreen.withValues(alpha: 0.25)
              : AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(children: [
        Icon(
          hasZone ? Icons.location_on_outlined : Icons.location_off_outlined,
          color: hasZone ? AppColors.primaryGreen : AppColors.warning,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasZone ? 'Your location is set' : 'No location set',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: hasZone
                      ? AppColors.primaryGreenDark
                      : AppColors.warning,
                ),
              ),
              if (hasZone && zone!.landmark != null)
                Text(zone!.landmark!,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreenDark))
              else if (!hasZone)
                const Text(
                  'Set your location so we can match you with nearby providers.',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Location editor bottom sheet ─────────────────────────────────────────
class _LocationEditorSheet extends StatefulWidget {
  final AppState app;
  const _LocationEditorSheet({required this.app});

  @override
  State<_LocationEditorSheet> createState() => _LocationEditorSheetState();
}

class _LocationEditorSheetState extends State<_LocationEditorSheet> {
  ZoneAddress? _zone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _zone = widget.app.currentUser.homeZone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Update Your Location',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Your district, division, and parish drive all nearby-provider '
              'results. No GPS is used.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 20),
            ZonePickerWidget(
              initial: _zone,
              onChanged: (z) => setState(() => _zone = z),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_zone == null || _saving) ? null : () async {
                  setState(() => _saving = true);
                  await Future.delayed(
                      const Duration(milliseconds: 400));
                  if (!mounted) return;
                  widget.app.setConsumerZone(_zone!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Location updated.'),
                        backgroundColor: AppColors.success),
                  );
                },
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── About tile — secret admin tap ────────────────────────────────────────
class _AboutTile extends StatefulWidget {
  @override
  State<_AboutTile> createState() => _AboutTileState();
}

class _AboutTileState extends State<_AboutTile> {
  int _tapCount = 0;
  DateTime? _firstTap;
  static const _requiredTaps = 7;
  static const _windowSeconds = 3;

  void _handleTap() {
    final now = DateTime.now();
    if (_firstTap == null ||
        now.difference(_firstTap!).inSeconds > _windowSeconds) {
      _firstTap = now;
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _firstTap = null;
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: const Text('About Ur Plug',
          style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: _handleTap,
    );
  }
}

// ─── Generic profile list tile ──────────────────────────────────────────────
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;
  final Color? textColor;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface;
    final ic = isDestructive ? AppColors.danger : (iconColor ?? base);
    final tc = isDestructive ? AppColors.danger : (textColor ?? base);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: ic),
      title: Text(label,
          style: TextStyle(color: tc, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
