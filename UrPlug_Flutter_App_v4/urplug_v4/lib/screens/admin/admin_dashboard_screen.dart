import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/provider_profile.dart';
import '../../models/zone.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.admin_panel_settings_outlined, size: 20),
          SizedBox(width: 8),
          Text('Admin Console'),
        ]),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out of admin',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(children: [
        // Stats bar
        Container(
          color: AppColors.deepBlue.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _StatPill('Providers', '${MockData.providers.length}',
                Icons.storefront_outlined),
            const SizedBox(width: 10),
            _StatPill(
                'Pending',
                '${MockData.providers.where((p) => p.tier == ProviderTier.standard).length}',
                Icons.pending_outlined),
            const SizedBox(width: 10),
            _StatPill('Reviews', '${MockData.reviews.length}',
                Icons.rate_review_outlined),
            const SizedBox(width: 10),
            _StatPill('Jobs', '${MockData.jobPosts.length}',
                Icons.work_outline),
          ]),
        ),
        // Tab bar
        Container(
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _AdminTab('Overview',   Icons.dashboard_outlined,     0, _tab, (i) => setState(() => _tab = i)),
              _AdminTab('Verify',     Icons.verified_user_outlined, 1, _tab, (i) => setState(() => _tab = i)),
              _AdminTab('Reviews',    Icons.rate_review_outlined,   2, _tab, (i) => setState(() => _tab = i)),
              _AdminTab('Users',      Icons.people_outline,         3, _tab, (i) => setState(() => _tab = i)),
              _AdminTab('Zones',      Icons.map_outlined,           4, _tab, (i) => setState(() => _tab = i)),
              _AdminTab('Categories', Icons.category_outlined,      5, _tab, (i) => setState(() => _tab = i)),
            ]),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              _OverviewTab(),
              _VerificationQueueTab(),
              _ReviewsTab(),
              _UsersTab(),
              _ZonesTab(),
              _CategoriesTab(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Overview ────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final sections = [
      ('Verification Queue',  Icons.verified_user_outlined,  'Review Gold Tier document submissions'),
      ('Review Moderation',   Icons.rate_review_outlined,    'Flag or remove abusive reviews'),
      ('User Management',     Icons.people_outline,          'Suspend or remove accounts'),
      ('Zone Configuration',  Icons.map_outlined,            'Add or edit administrative zones'),
      ('Category Management', Icons.category_outlined,       'Add, edit, or remove service categories'),
      ('Platform Analytics',  Icons.bar_chart_outlined,      'Views, chats, registrations over time'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Quick Access'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: sections
              .map((s) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.$2, color: AppColors.primaryGreen, size: 22),
                        const Spacer(),
                        Text(s.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text(s.$3,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55))),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Verification Queue ───────────────────────────────────────────────────────
class _VerificationQueueTab extends StatefulWidget {
  const _VerificationQueueTab();

  @override
  State<_VerificationQueueTab> createState() => _VerificationQueueTabState();
}

class _VerificationQueueTabState extends State<_VerificationQueueTab> {
  late final List<ProviderProfile> _pending = MockData.providers
      .where((p) => p.tier == ProviderTier.standard)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Pending Gold Tier Applications'),
        const SizedBox(height: 10),
        if (_pending.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No pending applications.')))
        else
          ..._pending.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('PENDING',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text(p.businessDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65))),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _pending.remove(p));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${p.name} rejected.'),
                                backgroundColor: AppColors.danger,
                              ));
                            },
                            icon: const Icon(Icons.close,
                                size: 16, color: AppColors.danger),
                            label: const Text('Reject',
                                style: TextStyle(color: AppColors.danger)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.danger)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _pending.remove(p));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('${p.name} approved as Gold Tier.'),
                                backgroundColor: AppColors.success,
                              ));
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

// ─── Reviews ─────────────────────────────────────────────────────────────────
class _ReviewsTab extends StatefulWidget {
  const _ReviewsTab();

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  late final List reviews = List.from(MockData.reviews);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('All Public Reviews'),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          const Center(child: Text('No reviews.'))
        else
          ...reviews.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(r.consumerDisplayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                        Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      i < r.stars
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 14,
                                      color: AppColors.gold,
                                    ))),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.comment),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => reviews.remove(r));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Review removed.')));
                          },
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.danger),
                          label: const Text('Remove',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

// ─── Users ───────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Registered Providers'),
        const SizedBox(height: 10),
        ...MockData.providers.map((p) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreenLight,
                child: Text(p.name[0],
                    style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700)),
              ),
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  p.tier == ProviderTier.gold ? '⭐ Gold Verified' : 'Standard'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'suspend', child: Text('Suspend account')),
                  const PopupMenuItem(
                      value: 'remove', child: Text('Remove account')),
                ],
                onSelected: (v) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${v == 'suspend' ? 'Suspended' : 'Removed'}: ${p.name}'),
                  ));
                },
              ),
            )),
      ],
    );
  }
}

// ─── Zones ───────────────────────────────────────────────────────────────────
class _ZonesTab extends StatelessWidget {
  const _ZonesTab();

  @override
  Widget build(BuildContext context) {
    // MockData.zones is List<Zone> — id, name, level, parentId
    final zones = MockData.zones;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Administrative Zones'),
        const SizedBox(height: 4),
        Text(
          'These drive the no-GPS location matching engine. '
          'Add sub-counties and parishes as provider coverage expands.',
          style: TextStyle(
              fontSize: 12.5,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 14),
        ...zones.map((z) {
          // Build a readable subtitle from the Zone's level and parentId
          final levelLabel = _levelLabel(z.level);
          final parentLabel =
              z.parentId != null ? ' › parent: ${z.parentId}' : '';
          return ListTile(
            dense: true,
            leading: Icon(_levelIcon(z.level),
                size: 18, color: AppColors.primaryGreen),
            title: Text(z.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5)),
            subtitle: Text('$levelLabel$parentLabel',
                style: const TextStyle(fontSize: 11.5)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () {},
            ),
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Zone'),
        ),
      ],
    );
  }

  String _levelLabel(ZoneLevel level) {
    switch (level) {
      case ZoneLevel.region:   return 'Region';
      case ZoneLevel.district: return 'District';
      case ZoneLevel.division: return 'Division / Sub-county';
      case ZoneLevel.parish:   return 'Parish / Village';
    }
  }

  IconData _levelIcon(ZoneLevel level) {
    switch (level) {
      case ZoneLevel.region:   return Icons.public_outlined;
      case ZoneLevel.district: return Icons.location_city_outlined;
      case ZoneLevel.division: return Icons.place_outlined;
      case ZoneLevel.parish:   return Icons.where_to_vote_outlined;
    }
  }
}

// ─── Categories ──────────────────────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Service Categories'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Categories are defined in service_category.dart.\n'
            'To add a category: add a new ServiceCategory entry to '
            'DefaultCategories.all with a unique id, label, and icon.\n\n'
            'To promote an "Others" listing to its own category, identify '
            'providers who registered under "others" and update their categoryId.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatPill(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primaryGreenDark)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.primaryGreenDark)),
        ]),
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  const _AdminTab(this.label, this.icon, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primaryGreen : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? AppColors.primaryGreen
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.primaryGreen
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 15));
  }
}
