import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../theme/app_colors.dart';

class TierBadge extends StatelessWidget {
  final ProviderTier tier;
  final bool compact;

  const TierBadge({super.key, required this.tier, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isGold = tier == ProviderTier.gold;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 9, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: isGold ? AppColors.goldLight : Colors.transparent,
        border: isGold ? null : Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGold ? Icons.verified : Icons.shield_outlined,
            size: compact ? 12 : 14,
            color: isGold ? AppColors.gold : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            isGold ? 'Gold Verified' : 'Standard',
            style: TextStyle(
              fontSize: compact ? 10 : 11.5,
              fontWeight: FontWeight.w700,
              color: isGold
                  ? const Color(0xFF8A6300)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
