import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../data/mock_data.dart';
import '../../models/provider_profile.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../models/zone.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/zone_picker_widget.dart';
import '../../widgets/tier_badge.dart';
import '../chat/chat_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final app = pv.Provider.of<AppState>(context);
    final provider = app.myProviderProfile;

    if (provider == null) {
      return const Scaffold(
          body: Center(child: Text('Provider profile not found.')));
    }

    final reviews =
        MockData.reviews.where((r) => r.providerId == provider.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => app.toggleMode(),
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text('Consumer Mode'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Header
          Row(children: [
            Expanded(
              child: Text(provider.name,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800)),
            ),
            TierBadge(tier: provider.tier),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            StarRating(
                rating: provider.ratingAverage,
                reviewCount: provider.ratingCount),
            const SizedBox(width: 14),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: provider.isOpenForWork
                    ? AppColors.openDot
                    : AppColors.closedDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              provider.isOpenForWork ? 'Open for work' : 'Closed',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Switch(
              value: provider.isOpenForWork,
              activeTrackColor: AppColors.primaryGreen,
              onChanged: (_) => setState(() {}),
            ),
          ]),

          const SizedBox(height: 18),
          _DashboardGrid(provider: provider),
          const SizedBox(height: 22),

          // Analytics
          const Text('Analytics',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            _StatCard(label: 'Profile views', value: '312'),
            const SizedBox(width: 10),
            _StatCard(label: 'Chats started', value: '48'),
            const SizedBox(width: 10),
            _StatCard(label: 'Avg. rating', value: provider.ratingAverage.toStringAsFixed(1)),
          ]),
          const SizedBox(height: 22),

          // Description
          const Text('Business description',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.businessDescription),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showEditDescriptionSheet(context, provider),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Service Area ─────────────────────────────────────────────
          const Text('Service area',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'This is where Ur Plug shows you to consumers first. '
            'Keep it accurate so you get matched with nearby jobs.',
            style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          _ServiceAreaCard(provider: provider),
          const SizedBox(height: 22),

          // Reviews
          Row(children: [
            const Text('Your reviews',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const Spacer(),
            Text('Only admins can remove reviews',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ]),
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            Text('No reviews yet.',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55)))
          else
            ...reviews.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(r.consumerDisplayName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          StarRating(rating: r.stars.toDouble(), size: 13),
                        ]),
                        const SizedBox(height: 6),
                        Text(r.comment),
                        if (r.providerResponse == null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  _showResponseSheet(context, r.id),
                              child: const Text('Post a response'),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Your response: ${r.providerResponse}',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showEditDescriptionSheet(BuildContext context, ProviderProfile provider) {
    final ctrl = TextEditingController(text: provider.businessDescription);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit description',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResponseSheet(BuildContext context, String reviewId) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Post a response',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Write your response...')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard grid ──────────────────────────────────────────────────────────
class _DashboardGrid extends StatelessWidget {
  final ProviderProfile provider;
  const _DashboardGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.add_photo_alternate_outlined, 'Upload Services',
          () => _toast(context, 'Portfolio upload coming soon')),
      (Icons.delete_outline, 'Remove Uploads',
          () => _toast(context, 'Remove uploads coming soon')),
      (Icons.calendar_month_outlined, 'Availability Calendar',
          () => _toast(context, 'Availability calendar coming soon')),
      (Icons.chat_bubble_outline, 'Chat Inbox',
          () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (_) => ChatScreen(
                  providerId: provider.id,
                  providerName: provider.name,
                ),
              ))),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: items.map((item) {
        return InkWell(
          onTap: item.$3,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(item.$1, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.$2,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12.5)),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primaryGreenDark)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}

// ── Service Area Card ─────────────────────────────────────────────────────────
class _ServiceAreaCard extends StatelessWidget {
  final ProviderProfile provider;
  const _ServiceAreaCard({required this.provider});

  String _zoneName(String id) {
    try {
      return MockData.zones.firstWhere((z) => z.id == id).name;
    } catch (_) {
      return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zone = provider.zone;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
            child: Row(children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Current service area',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              ),
              TextButton.icon(
                onPressed: () => _showServiceAreaEditor(context),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Update'),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                _ZoneRow(Icons.public_outlined, 'Region',
                    _zoneName(zone.regionId)),
                _ZoneRow(Icons.location_city_outlined, 'District',
                    _zoneName(zone.districtId)),
                _ZoneRow(Icons.place_outlined, 'Division',
                    _zoneName(zone.divisionId)),
                _ZoneRow(Icons.where_to_vote_outlined, 'Parish',
                    _zoneName(zone.parishId)),
                if (zone.landmark != null && zone.landmark!.isNotEmpty)
                  _ZoneRow(Icons.storefront_outlined, 'Landmark',
                      zone.landmark!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceAreaEditor(BuildContext context) {
    ZoneAddress? newZone = provider.zone;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, sc) => StatefulBuilder(
          builder: (ctx2, setS) => Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(children: [
                  const Expanded(
                    child: Text('Update service area',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx2),
                    child: const Text('Cancel'),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Update your service area so consumers searching '
                  'in your district find you first.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx2)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      ZonePickerWidget(
                        initial: provider.zone,
                        showLandmark: true,
                        onChanged: (z) => setS(() => newZone = z),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: newZone == null
                              ? null
                              : () {
                                  Navigator.pop(ctx2);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Service area updated. '
                                        'Consumers in your area will now find you.'),
                                  ));
                                },
                          child: const Text('Save service area'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zone display row ──────────────────────────────────────────────────────────
class _ZoneRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ZoneRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.primaryGreen.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
