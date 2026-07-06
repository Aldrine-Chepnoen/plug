import 'package:flutter/material.dart';

/// Admin-managed service categories. "others" is a permanent fallback
/// bucket so providers are never blocked from registering; admins can
/// later promote a recurring pattern in "others" into its own category.
class ServiceCategory {
  final String id;
  final String label;
  final IconData icon;
  final bool isSystemDefault;

  const ServiceCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.isSystemDefault = false,
  });
}

class DefaultCategories {
  DefaultCategories._();

  static const List<ServiceCategory> all = [
    ServiceCategory(id: 'mechanical', label: 'Mechanical', icon: Icons.build_circle_outlined, isSystemDefault: true),
    ServiceCategory(id: 'plumbing', label: 'Plumbing', icon: Icons.plumbing_outlined, isSystemDefault: true),
    ServiceCategory(id: 'building', label: 'Building', icon: Icons.construction_outlined, isSystemDefault: true),
    ServiceCategory(id: 'bridal_salon', label: 'Bridal & Salon', icon: Icons.content_cut_outlined, isSystemDefault: true),
    ServiceCategory(id: 'events', label: 'Events', icon: Icons.celebration_outlined, isSystemDefault: true),
    ServiceCategory(id: 'electrical', label: 'Electrical', icon: Icons.electrical_services_outlined, isSystemDefault: true),
    ServiceCategory(id: 'others', label: 'Others', icon: Icons.more_horiz_outlined, isSystemDefault: true),
  ];
}
