import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/service_category.dart';
import '../../theme/app_colors.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/tier_badge.dart';
import '../chat/chat_screen.dart';

class PublicProviderProfileScreen extends StatelessWidget {
  final String providerId;
  const PublicProviderProfileScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final provider = MockData.providers.firstWhere((p) => p.id == providerId);
    final category = DefaultCategories.all.firstWhere(
      (c) => c.id == provider.categoryId,
      orElse: () => DefaultCategories.all.last,
    );
    final reviews = MockData.reviews.where((r) => r.providerId == providerId).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreenDark, AppColors.primaryGreen],
                  ),
                ),
                child: Center(
                  child: Icon(category.icon, color: Colors.white.withValues(alpha: 0.85), size: 56),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(provider.name,
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                      ),
                      TierBadge(tier: provider.tier),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(category.label,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StarRating(rating: provider.ratingAverage, reviewCount: provider.ratingCount),
                      const SizedBox(width: 14),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: provider.isOpenForWork ? AppColors.openDot : AppColors.closedDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(provider.isOpenForWork ? 'Open for work' : 'Not available',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider.zone.landmark ?? 'Zone on file',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(provider.businessDescription, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 20),
                  const Text('Portfolio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  provider.portfolio.isEmpty
                      ? _EmptyPortfolioPlaceholder(category: category)
                      : SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.portfolio.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(width: 90, color: AppColors.primaryGreenLight),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Reviews', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const Spacer(),
                      Text('${reviews.length} total',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    Text('No reviews yet.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)))
                  else
                    ...reviews.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(r.consumerDisplayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const Spacer(),
                                    StarRating(rating: r.stars.toDouble(), size: 13),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(r.comment),
                                if (r.providerResponse != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreenLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Provider response: ${r.providerResponse}',
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(providerId: provider.id, providerName: provider.name),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Provider'),
          ),
        ),
      ),
    );
  }
}

class _EmptyPortfolioPlaceholder extends StatelessWidget {
  final ServiceCategory category;
  const _EmptyPortfolioPlaceholder({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        'This provider hasn\'t uploaded portfolio photos yet.',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
      ),
    );
  }
}
