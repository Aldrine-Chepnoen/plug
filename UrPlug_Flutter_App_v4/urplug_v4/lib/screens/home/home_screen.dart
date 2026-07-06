import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import '../../data/mock_data.dart';
import '../../data/zone_matching_engine.dart';
import '../../models/service_category.dart';
import '../../models/zone.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_sidebar.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/provider_card.dart';
import '../emergency/emergency_plug_screen.dart';
import '../jobs/job_board_screen.dart';
import '../profile/profile_screen.dart';
import '../provider/public_provider_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // Discover tab local state — kept here so it survives navigation back
  String? _selectedCategory;
  String _query = '';

  // ── Tab bodies ───────────────────────────────────────────────────────────
  // IMPORTANT: We deliberately do NOT use IndexedStack here.
  //
  // IndexedStack keeps all children alive in the widget tree, including the
  // hidden ones. On Flutter Web (HTML renderer), hidden Scaffold children
  // from tabs like JobBoardScreen / EmergencyPlugScreen still participate in
  // hit testing, silently consuming taps on the visible tab.
  //
  // Simple array indexing re-builds inactive tabs on switch but guarantees
  // that only ONE Scaffold is in the tree at any time — fixing all button
  // and navigation issues on Flutter Web.
  Widget get _body {
    switch (_navIndex) {
      case 0:
        return _DiscoverTab(
          selectedCategory: _selectedCategory,
          query: _query,
          onCategorySelected: (c) => setState(() => _selectedCategory = c),
          onQueryChanged: (q) => setState(() => _query = q),
        );
      case 1:
        return const JobBoardScreen();
      case 2:
        return const EmergencyPlugScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const _DiscoverTab(
          selectedCategory: null,
          query: '',
          onCategorySelected: null,
          onQueryChanged: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each tab's own Scaffold provides its AppBar, so the outer Scaffold
      // has no AppBar of its own.
      body: _body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add_outlined),
            activeIcon: Icon(Icons.post_add),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Discover Tab ─────────────────────────────────────────────────────────────
class _DiscoverTab extends StatelessWidget {
  final String? selectedCategory;
  final String query;
  final ValueChanged<String?>? onCategorySelected;
  final ValueChanged<String>? onQueryChanged;

  const _DiscoverTab({
    required this.selectedCategory,
    required this.query,
    required this.onCategorySelected,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final app = pv.Provider.of<AppState>(context);
    final consumerZone = app.currentUser.homeZone ?? MockData.consumerHomeZone;

    final ranked = ZoneMatchingEngine.match(
      consumerZone: consumerZone,
      providers: MockData.providers,
      categoryId: selectedCategory,
      searchQuery: query,
    );

    final featured = MockData.providers.where((p) => p.isFeatured).toList();
    final exact =
        ranked.where((r) => r.matchTier == MatchTier.exactParish).toList();
    final sameDistrict =
        ranked.where((r) => r.matchTier == MatchTier.sameDistrict).toList();
    final other =
        ranked.where((r) => r.matchTier == MatchTier.otherRegion).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _TopBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Find a plumber, electrician...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategorySidebar(
                  categories: DefaultCategories.all,
                  selectedId: selectedCategory,
                  onSelect: onCategorySelected ?? (_) {},
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 24),
                    children: [
                      if (selectedCategory == null &&
                          (query.isEmpty)) ...[
                        const _SectionLabel('Featured providers'),
                        const SizedBox(height: 8),
                        FeaturedCarousel(
                          providers: featured,
                          onTap: (p) => _openProfile(context, p.id),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _ResultsSection(
                        title: 'Near you',
                        subtitle: 'In your parish / village',
                        items: exact,
                      ),
                      _ResultsSection(
                        title: 'Also in your district',
                        subtitle: 'Nearby parishes & sub-counties',
                        items: sameDistrict,
                      ),
                      _ResultsSection(
                        title: 'More options',
                        subtitle: 'Other areas',
                        items: other,
                      ),
                      if (ranked.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No providers match yet — try another category.',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _openProfile(BuildContext context, String providerId) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
          builder: (_) => PublicProviderProfileScreen(providerId: providerId)),
    );
  }
}

// ─── Results section ──────────────────────────────────────────────────────────
class _ResultsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<RankedProvider> items;

  const _ResultsSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(title, subtitle: subtitle),
          const SizedBox(height: 8),
          ...items.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProviderCard(
                  provider: r.provider,
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => PublicProviderProfileScreen(
                          providerId: r.provider.id),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionLabel(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
        if (subtitle != null)
          Text(subtitle!,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55))),
      ],
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = pv.Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.primaryGreenLight,
          child: Text(
            app.currentUser.displayName.isNotEmpty
                ? app.currentUser.displayName[0]
                : '?',
            style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
        const Text('Ur Plug',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const Spacer(),
        // Emergency shortcut
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                  builder: (_) => const EmergencyPlugScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.bolt_rounded, color: AppColors.danger),
            ),
          ),
        ),
      ]),
    );
  }
}
