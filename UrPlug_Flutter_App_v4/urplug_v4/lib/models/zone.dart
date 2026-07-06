/// Uganda's administrative hierarchy, used instead of GPS for all
/// location-based matching. Region -> District -> Division/Sub-county ->
/// Parish/Village.
class Zone {
  final String id;
  final String name;
  final ZoneLevel level;
  final String? parentId;

  const Zone({
    required this.id,
    required this.name,
    required this.level,
    this.parentId,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'] as String,
        name: json['name'] as String,
        level: ZoneLevel.values.byName(json['level'] as String),
        parentId: json['parent_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level.name,
        'parent_id': parentId,
      };
}

enum ZoneLevel { region, district, division, parish }

/// A consumer's or provider's selected operating location: a Parish/Village
/// plus an optional human landmark anchor (e.g. "Opposite Shell Ntinda").
/// This is what stands in for GPS everywhere in the app.
class ZoneAddress {
  final String regionId;
  final String districtId;
  final String divisionId;
  final String parishId;
  final String? landmark;

  const ZoneAddress({
    required this.regionId,
    required this.districtId,
    required this.divisionId,
    required this.parishId,
    this.landmark,
  });

  ZoneAddress copyWith({
    String? regionId,
    String? districtId,
    String? divisionId,
    String? parishId,
    String? landmark,
  }) {
    return ZoneAddress(
      regionId: regionId ?? this.regionId,
      districtId: districtId ?? this.districtId,
      divisionId: divisionId ?? this.divisionId,
      parishId: parishId ?? this.parishId,
      landmark: landmark ?? this.landmark,
    );
  }
}

/// Result of the zone matching engine: how close a provider's zone is to
/// the consumer's, driving both sort order and the UI section it appears in.
enum MatchTier { exactParish, sameDistrict, otherRegion }
