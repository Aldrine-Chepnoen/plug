import '../models/zone.dart';
import '../models/provider_profile.dart';

class RankedProvider {
  final ProviderProfile provider;
  final MatchTier matchTier;
  final double score;

  const RankedProvider({
    required this.provider,
    required this.matchTier,
    required this.score,
  });
}

/// The heart of Ur Plug: turns a consumer's manually-selected zone into a
/// ranked, bucketed list of providers, without ever touching device GPS.
///
/// Bucket priority (highest first):
///   1. exactParish   — provider's parish matches the consumer's exactly
///   2. sameDistrict   — same district, different parish/division
///   3. otherRegion    — everything else (kept for variety/choice)
///
/// Within a bucket, providers are sorted by [ProviderProfile.rankingScore],
/// which blends tier, rating, completed jobs, and responsiveness.
class ZoneMatchingEngine {
  ZoneMatchingEngine._();

  static MatchTier _tierFor(ZoneAddress consumer, ZoneAddress provider) {
    if (provider.parishId == consumer.parishId) return MatchTier.exactParish;
    if (provider.districtId == consumer.districtId) return MatchTier.sameDistrict;
    return MatchTier.otherRegion;
  }

  static List<RankedProvider> match({
    required ZoneAddress consumerZone,
    required List<ProviderProfile> providers,
    String? categoryId,
    String? searchQuery,
  }) {
    Iterable<ProviderProfile> pool = providers;

    if (categoryId != null && categoryId.isNotEmpty) {
      pool = pool.where((p) => p.categoryId == categoryId);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      pool = pool.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.businessDescription.toLowerCase().contains(q));
    }

    final ranked = pool.map((p) {
      final tier = _tierFor(consumerZone, p.zone);
      return RankedProvider(provider: p, matchTier: tier, score: p.rankingScore());
    }).toList();

    ranked.sort((a, b) {
      final tierCompare = a.matchTier.index.compareTo(b.matchTier.index);
      if (tierCompare != 0) return tierCompare;
      return b.score.compareTo(a.score); // higher score first
    });

    return ranked;
  }
}
