import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../theme/app_colors.dart';

class CategorySidebar extends StatelessWidget {
  final List<ServiceCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat.id == selectedId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(selected ? null : cat.id),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryGreen : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primaryGreen : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Icon(
                      cat.icon,
                      color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.primaryGreen
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
