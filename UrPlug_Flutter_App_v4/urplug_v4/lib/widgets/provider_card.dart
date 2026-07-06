import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../models/service_category.dart';
import '../theme/app_colors.dart';
import 'tier_badge.dart';
import 'star_rating.dart';

class ProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = DefaultCategories.all.firstWhere(
      (c) => c.id == provider.categoryId,
      orElse: () => DefaultCategories.all.last,
    );

    // ── FIX: InkWell MUST be INSIDE Card (which provides Material).
    // On Flutter Web, InkWell outside Material silently swallows taps.
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // ensures InkWell ripple clips to card shape
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + open-dot
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 76,
                      height: 76,
                      color: AppColors.primaryGreenLight,
                      child: Icon(category.icon,
                          color: AppColors.primaryGreen, size: 30),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: provider.isOpenForWork
                            ? AppColors.openDot
                            : AppColors.closedDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      TierBadge(tier: provider.tier, compact: true),
                    ]),
                    const SizedBox(height: 3),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 5),
                    StarRating(
                        rating: provider.ratingAverage,
                        reviewCount: provider.ratingCount,
                        size: 13),
                    const SizedBox(height: 5),
                    Row(children: [
                      Icon(Icons.place_outlined,
                          size: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          provider.zone.landmark ?? 'Nearby',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
