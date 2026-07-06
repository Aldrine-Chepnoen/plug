import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating; // 0-5
  final int? reviewCount;
  final double size;

  const StarRating({super.key, required this.rating, this.reviewCount, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: AppColors.gold),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: size * 0.9),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.8,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
