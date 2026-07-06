import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../models/service_category.dart';
import '../theme/app_colors.dart';
import 'tier_badge.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<ProviderProfile> providers;
  final ValueChanged<ProviderProfile> onTap;

  const FeaturedCarousel(
      {super.key, required this.providers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: providers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final p = providers[index];
          final category = DefaultCategories.all.firstWhere(
            (c) => c.id == p.categoryId,
            orElse: () => DefaultCategories.all.last,
          );

          // ── FIX: GestureDetector works on Flutter Web without needing
          // a Material ancestor. InkWell wrapping a plain Container (no
          // Material above it) silently drops taps on Flutter Web.
          return GestureDetector(
            onTap: () => onTap(p),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreenDark,
                      AppColors.primaryGreen
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(category.icon, color: Colors.white70, size: 18),
                    ]),
                    const Spacer(),
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.label,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TierBadge(tier: p.tier, compact: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
