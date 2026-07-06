import 'zone.dart';

enum ProviderTier { gold, standard }

class PortfolioItem {
  final String id;
  final String imageUrl;
  final String? caption;

  const PortfolioItem({required this.id, required this.imageUrl, this.caption});
}

class AvailabilitySlot {
  final DateTime date;
  final bool isAvailable;

  const AvailabilitySlot({required this.date, required this.isAvailable});
}

class ProviderProfile {
  final String id;
  final String name;
  final String categoryId;
  final ProviderTier tier;
  final String? coverImageUrl;
  final String? avatarUrl;
  final String businessDescription;
  final ZoneAddress zone;
  final double ratingAverage;
  final int ratingCount;
  final int completedJobs;
  final double responsivenessScore; // 0-1, derived from reply time/rate
  final bool isOpenForWork;
  final bool isFeatured;
  final List<PortfolioItem> portfolio;
  final List<AvailabilitySlot> availability;
  final String nationalIdOnFile; // stored securely server-side in production
  final bool identityVerified;

  const ProviderProfile({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.tier,
    required this.businessDescription,
    required this.zone,
    this.coverImageUrl,
    this.avatarUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.completedJobs = 0,
    this.responsivenessScore = 0.5,
    this.isOpenForWork = true,
    this.isFeatured = false,
    this.portfolio = const [],
    this.availability = const [],
    this.nationalIdOnFile = '',
    this.identityVerified = false,
  });

  /// Composite ranking score used by the recommendation engine.
  /// Proximity is handled separately (bucket ordering); within a bucket,
  /// providers are ranked by this score. Gold tier gets a fixed boost.
  double rankingScore() {
    final tierBoost = tier == ProviderTier.gold ? 0.15 : 0.0;
    final ratingComponent = (ratingAverage / 5) * 0.45;
    final jobsComponent = (completedJobs.clamp(0, 200) / 200) * 0.2;
    final responsivenessComponent = responsivenessScore * 0.2;
    return tierBoost + ratingComponent + jobsComponent + responsivenessComponent;
  }

  ProviderProfile copyWith({bool? isOpenForWork, String? businessDescription}) {
    return ProviderProfile(
      id: id,
      name: name,
      categoryId: categoryId,
      tier: tier,
      coverImageUrl: coverImageUrl,
      avatarUrl: avatarUrl,
      businessDescription: businessDescription ?? this.businessDescription,
      zone: zone,
      ratingAverage: ratingAverage,
      ratingCount: ratingCount,
      completedJobs: completedJobs,
      responsivenessScore: responsivenessScore,
      isOpenForWork: isOpenForWork ?? this.isOpenForWork,
      isFeatured: isFeatured,
      portfolio: portfolio,
      availability: availability,
      nationalIdOnFile: nationalIdOnFile,
      identityVerified: identityVerified,
    );
  }
}
