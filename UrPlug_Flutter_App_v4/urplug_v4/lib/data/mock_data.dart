import '../models/zone.dart';
import '../models/provider_profile.dart';
import '../models/review.dart';
import '../models/chat_and_jobs.dart';

/// TEMPORARY in-memory data source.
///
/// Replace with real calls once wired up:
///   - Firebase (Firestore) for providers, reviews, zones, job posts, chat
///   - Firebase Cloud Messaging for push notifications
///   - SMS gateway fallback for OTP / low-connectivity notification delivery
///
/// Keep the method signatures in ZoneMatchingEngine and this class stable —
/// screens are written against them, not against Firebase directly, so
/// swapping the implementation later shouldn't require touching UI code.
class MockData {
  MockData._();

  // --- Zones -----------------------------------------------------------
  static final List<Zone> zones = [
    // ── Regions ───────────────────────────────────────────────────────────
    const Zone(id: 'r_central',  name: 'Central Region',  level: ZoneLevel.region),
    const Zone(id: 'r_eastern',  name: 'Eastern Region',  level: ZoneLevel.region),
    const Zone(id: 'r_northern', name: 'Northern Region', level: ZoneLevel.region),
    const Zone(id: 'r_western',  name: 'Western Region',  level: ZoneLevel.region),

    // ── Districts — Central ───────────────────────────────────────────────
    const Zone(id: 'd_kampala',  name: 'Kampala',         level: ZoneLevel.district, parentId: 'r_central'),
    const Zone(id: 'd_wakiso',   name: 'Wakiso',          level: ZoneLevel.district, parentId: 'r_central'),
    const Zone(id: 'd_mukono',   name: 'Mukono',          level: ZoneLevel.district, parentId: 'r_central'),
    const Zone(id: 'd_masaka',   name: 'Masaka',          level: ZoneLevel.district, parentId: 'r_central'),
    const Zone(id: 'd_kalangala',name: 'Kalangala',       level: ZoneLevel.district, parentId: 'r_central'),

    // ── Districts — Eastern ───────────────────────────────────────────────
    const Zone(id: 'd_jinja',    name: 'Jinja',           level: ZoneLevel.district, parentId: 'r_eastern'),
    const Zone(id: 'd_mbale',    name: 'Mbale',           level: ZoneLevel.district, parentId: 'r_eastern'),
    const Zone(id: 'd_tororo',   name: 'Tororo',          level: ZoneLevel.district, parentId: 'r_eastern'),
    const Zone(id: 'd_soroti',   name: 'Soroti',          level: ZoneLevel.district, parentId: 'r_eastern'),
    const Zone(id: 'd_iganga',   name: 'Iganga',          level: ZoneLevel.district, parentId: 'r_eastern'),

    // ── Districts — Northern ──────────────────────────────────────────────
    const Zone(id: 'd_gulu',     name: 'Gulu',            level: ZoneLevel.district, parentId: 'r_northern'),
    const Zone(id: 'd_lira',     name: 'Lira',            level: ZoneLevel.district, parentId: 'r_northern'),
    const Zone(id: 'd_arua',     name: 'Arua',            level: ZoneLevel.district, parentId: 'r_northern'),
    const Zone(id: 'd_kitgum',   name: 'Kitgum',          level: ZoneLevel.district, parentId: 'r_northern'),

    // ── Districts — Western ───────────────────────────────────────────────
    const Zone(id: 'd_mbarara',  name: 'Mbarara',         level: ZoneLevel.district, parentId: 'r_western'),
    const Zone(id: 'd_fort_p',   name: 'Fort Portal',     level: ZoneLevel.district, parentId: 'r_western'),
    const Zone(id: 'd_kabale',   name: 'Kabale',          level: ZoneLevel.district, parentId: 'r_western'),
    const Zone(id: 'd_kasese',   name: 'Kasese',          level: ZoneLevel.district, parentId: 'r_western'),
    const Zone(id: 'd_hoima',    name: 'Hoima',           level: ZoneLevel.district, parentId: 'r_western'),

    // ── Divisions / Sub-counties — Kampala ────────────────────────────────
    const Zone(id: 'div_kampala_c', name: 'Kampala Central', level: ZoneLevel.division, parentId: 'd_kampala'),
    const Zone(id: 'div_kawempe',   name: 'Kawempe Division', level: ZoneLevel.division, parentId: 'd_kampala'),
    const Zone(id: 'div_makindye',  name: 'Makindye Division', level: ZoneLevel.division, parentId: 'd_kampala'),
    const Zone(id: 'div_nakawa',    name: 'Nakawa Division',  level: ZoneLevel.division, parentId: 'd_kampala'),
    const Zone(id: 'div_rubaga',    name: 'Rubaga Division',  level: ZoneLevel.division, parentId: 'd_kampala'),

    // ── Divisions / Sub-counties — Wakiso ─────────────────────────────────
    const Zone(id: 'div_nansana',   name: 'Nansana Town',    level: ZoneLevel.division, parentId: 'd_wakiso'),
    const Zone(id: 'div_entebbe',   name: 'Entebbe Municipality', level: ZoneLevel.division, parentId: 'd_wakiso'),
    const Zone(id: 'div_kira',      name: 'Kira Town',        level: ZoneLevel.division, parentId: 'd_wakiso'),
    const Zone(id: 'div_makindye_s','Makindye-Ssabagabo', level: ZoneLevel.division, parentId: 'd_wakiso'),

    // ── Divisions — Other major towns ─────────────────────────────────────
    const Zone(id: 'div_jinja_c',   name: 'Jinja Central',   level: ZoneLevel.division, parentId: 'd_jinja'),
    const Zone(id: 'div_mbarara_c', name: 'Mbarara Central', level: ZoneLevel.division, parentId: 'd_mbarara'),
    const Zone(id: 'div_gulu_c',    name: 'Gulu Central',    level: ZoneLevel.division, parentId: 'd_gulu'),
    const Zone(id: 'div_mbale_c',   name: 'Mbale Central',   level: ZoneLevel.division, parentId: 'd_mbale'),
    const Zone(id: 'div_fort_p_c',  name: 'Fort Portal Central', level: ZoneLevel.division, parentId: 'd_fort_p'),
    const Zone(id: 'div_lira_c',    name: 'Lira Central',    level: ZoneLevel.division, parentId: 'd_lira'),
    const Zone(id: 'div_arua_c',    name: 'Arua Central',    level: ZoneLevel.division, parentId: 'd_arua'),

    // ── Parishes — Kampala Central ────────────────────────────────────────
    const Zone(id: 'p_kololo',      name: 'Kololo',          level: ZoneLevel.parish, parentId: 'div_kampala_c'),
    const Zone(id: 'p_nakasero',    name: 'Nakasero',        level: ZoneLevel.parish, parentId: 'div_kampala_c'),
    const Zone(id: 'p_kibuli',      name: 'Kibuli',          level: ZoneLevel.parish, parentId: 'div_kampala_c'),
    const Zone(id: 'p_old_kampala', name: 'Old Kampala',     level: ZoneLevel.parish, parentId: 'div_kampala_c'),

    // ── Parishes — Nakawa ─────────────────────────────────────────────────
    const Zone(id: 'p_ntinda',      name: 'Ntinda',          level: ZoneLevel.parish, parentId: 'div_nakawa'),
    const Zone(id: 'p_naguru',      name: 'Naguru',          level: ZoneLevel.parish, parentId: 'div_nakawa'),
    const Zone(id: 'p_kyambogo',    name: 'Kyambogo',        level: ZoneLevel.parish, parentId: 'div_nakawa'),
    const Zone(id: 'p_butabika',    name: 'Butabika',        level: ZoneLevel.parish, parentId: 'div_nakawa'),

    // ── Parishes — Kawempe ────────────────────────────────────────────────
    const Zone(id: 'p_bwaise',      name: 'Bwaise',          level: ZoneLevel.parish, parentId: 'div_kawempe'),
    const Zone(id: 'p_wandegeya',   name: 'Wandegeya',       level: ZoneLevel.parish, parentId: 'div_kawempe'),
    const Zone(id: 'p_makerere',    name: 'Makerere',        level: ZoneLevel.parish, parentId: 'div_kawempe'),
    const Zone(id: 'p_mulago',      name: 'Mulago',          level: ZoneLevel.parish, parentId: 'div_kawempe'),

    // ── Parishes — Makindye ───────────────────────────────────────────────
    const Zone(id: 'p_kabalagala',  name: 'Kabalagala',      level: ZoneLevel.parish, parentId: 'div_makindye'),
    const Zone(id: 'p_ggaba',       name: 'Ggaba',           level: ZoneLevel.parish, parentId: 'div_makindye'),
    const Zone(id: 'p_nsambya',     name: 'Nsambya',         level: ZoneLevel.parish, parentId: 'div_makindye'),

    // ── Parishes — Rubaga ─────────────────────────────────────────────────
    const Zone(id: 'p_namirembe',   name: 'Namirembe',       level: ZoneLevel.parish, parentId: 'div_rubaga'),
    const Zone(id: 'p_lungujja',    name: 'Lungujja',        level: ZoneLevel.parish, parentId: 'div_rubaga'),
    const Zone(id: 'p_mutundwe',    name: 'Mutundwe',        level: ZoneLevel.parish, parentId: 'div_rubaga'),

    // ── Parishes — Wakiso ─────────────────────────────────────────────────
    const Zone(id: 'p_nansana_c',   name: 'Nansana Central', level: ZoneLevel.parish, parentId: 'div_nansana'),
    const Zone(id: 'p_kira_c',      name: 'Kira Central',    level: ZoneLevel.parish, parentId: 'div_kira'),
    const Zone(id: 'p_entebbe_c',   name: 'Entebbe Central', level: ZoneLevel.parish, parentId: 'div_entebbe'),

    // ── Parishes — Other regions (representative) ─────────────────────────
    const Zone(id: 'p_jinja_c',     name: 'Jinja Central Parish',  level: ZoneLevel.parish, parentId: 'div_jinja_c'),
    const Zone(id: 'p_mbarara_c',   name: 'Mbarara Central Parish',level: ZoneLevel.parish, parentId: 'div_mbarara_c'),
    const Zone(id: 'p_gulu_c',      name: 'Gulu Central Parish',   level: ZoneLevel.parish, parentId: 'div_gulu_c'),
    const Zone(id: 'p_mbale_c',     name: 'Mbale Central Parish',  level: ZoneLevel.parish, parentId: 'div_mbale_c'),
    const Zone(id: 'p_fort_p_c',    name: 'Fort Portal Central Parish', level: ZoneLevel.parish, parentId: 'div_fort_p_c'),
    const Zone(id: 'p_lira_c',      name: 'Lira Central Parish',   level: ZoneLevel.parish, parentId: 'div_lira_c'),
    const Zone(id: 'p_arua_c',      name: 'Arua Central Parish',   level: ZoneLevel.parish, parentId: 'div_arua_c'),
  ];

  static const consumerHomeZone = const ZoneAddress(
    regionId: 'r_central',
    districtId: 'd_wakiso',
    divisionId: 'div_nansana',
    parishId: 'p_nansana_c',
    landmark: 'Near Nansana Taxi Park',
  );

  // --- Providers ---------------------------------------------------------
  static final List<ProviderProfile> providers = [
    ProviderProfile(
      id: 'p1',
      name: 'Moses Kato Electricals',
      categoryId: 'electrical',
      tier: ProviderTier.gold,
      businessDescription:
          'Licensed electrician with 8 years experience: wiring, rewiring, '
          'fault diagnosis, and solar backup installation for homes and shops.',
      zone: const ZoneAddress(
        regionId: 'r_central',
        districtId: 'd_wakiso',
        divisionId: 'div_nansana',
        parishId: 'p_nansana_c',
        landmark: 'Opposite Nansana Market',
      ),
      ratingAverage: 4.8,
      ratingCount: 63,
      completedJobs: 140,
      responsivenessScore: 0.9,
      isFeatured: true,
      identityVerified: true,
    ),
    ProviderProfile(
      id: 'p2',
      name: "Sarah's Bridal & Salon",
      categoryId: 'bridal_salon',
      tier: ProviderTier.standard,
      businessDescription:
          'Full bridal makeup, hair styling, and gele tying. Home visits '
          'available across Wakiso.',
      zone: const ZoneAddress(
        regionId: 'r_central',
        districtId: 'd_wakiso',
        divisionId: 'div_nansana',
        parishId: 'p_nansana_c',
        landmark: 'Near Nansana Taxi Park',
      ),
      ratingAverage: 4.5,
      ratingCount: 21,
      completedJobs: 34,
      responsivenessScore: 0.7,
      isFeatured: true,
    ),
    ProviderProfile(
      id: 'p3',
      name: 'Kawempe Plumbing Experts',
      categoryId: 'plumbing',
      tier: ProviderTier.gold,
      businessDescription:
          'Pipe installation, leak repair, and water tank setup. '
          'Fast response for emergencies.',
      zone: const ZoneAddress(
        regionId: 'r_central',
        districtId: 'd_kampala',
        divisionId: 'div_kawempe',
        parishId: 'p_bwaise',
        landmark: 'Bwaise Stage',
      ),
      ratingAverage: 4.6,
      ratingCount: 48,
      completedJobs: 97,
      responsivenessScore: 0.85,
      identityVerified: true,
    ),
    ProviderProfile(
      id: 'p4',
      name: 'Ntinda Mechanical Works',
      categoryId: 'mechanical',
      tier: ProviderTier.standard,
      businessDescription:
          'General car servicing, engine diagnostics, and mobile roadside '
          'assistance around Nakawa.',
      zone: const ZoneAddress(
        regionId: 'r_central',
        districtId: 'd_kampala',
        divisionId: 'div_nakawa',
        parishId: 'p_ntinda',
        landmark: 'Near Ntinda Shell',
      ),
      ratingAverage: 4.1,
      ratingCount: 15,
      completedJobs: 22,
      responsivenessScore: 0.55,
    ),
    ProviderProfile(
      id: 'p5',
      name: 'Nansana Events & Decor',
      categoryId: 'events',
      tier: ProviderTier.gold,
      businessDescription:
          'Tent, chair, and decor hire for weddings, introductions, and '
          'corporate functions.',
      zone: const ZoneAddress(
        regionId: 'r_central',
        districtId: 'd_wakiso',
        divisionId: 'div_nansana',
        parishId: 'p_nansana_c',
        landmark: 'Nansana Central, next to the clinic',
      ),
      ratingAverage: 4.9,
      ratingCount: 89,
      completedJobs: 210,
      responsivenessScore: 0.95,
      isFeatured: true,
      identityVerified: true,
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'rv1',
      providerId: 'p1',
      consumerDisplayName: 'Grace N.',
      stars: 5,
      comment: 'Fixed our wiring fault same day. Very professional.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      providerResponse: 'Thank you Grace, glad we could help!',
    ),
    Review(
      id: 'rv2',
      providerId: 'p1',
      consumerDisplayName: 'Daniel K.',
      stars: 4,
      comment: 'Good work, arrived a bit late but explained why.',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  static final List<JobPost> jobPosts = [
    JobPost(
      id: 'j1',
      consumerId: 'u_demo',
      categoryId: 'plumbing',
      description: 'Kitchen sink pipe burst, need urgent repair today.',
      zone: consumerHomeZone,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
}
