# Ur Plug — Flutter App Skeleton

A zone-based (no-GPS) service provider discovery and matching platform for
Uganda, built from the "Ur Plug" abstract + build spec. This package is a
complete, navigable Flutter app skeleton with real UI, real state
management, and a real matching algorithm — running on mock data so you can
see and demo the whole flow immediately, with clearly marked seams for
plugging in Supabase, Firebase Cloud Messaging, and an SMS gateway.

## Run it

```bash
flutter pub get
flutter run
```

No backend keys are required to explore the app — everything currently
reads from `lib/data/mock_data.dart`.

## What's implemented

- **Zone matching engine** (`lib/data/zone_matching_engine.dart`) — the
  actual no-GPS ranking logic: exact parish → same district → other
  region, then sorted within each bucket by a blended score of tier,
  rating, completed jobs, and responsiveness. This is the real algorithm,
  not a mock — swap the data source, not the logic.
- **Home / Discover screen** — profile header, Emergency Plug shortcut,
  search bar, scrollable category sidebar, featured/advertised carousel,
  and the three priority-ranked result sections.
- **Dual-role system** — every user starts as a consumer; "Register as a
  Service Provider" unlocks a Consumer/Provider mode switch in Profile.
- **Provider registration** — category multi-select (incl. "Others"),
  business description, National ID field, landmark, contact, optional
  Gold Tier application.
- **Provider dashboard** — open/closed toggle, portfolio & availability
  entry points, editable business description, chat inbox entry point,
  analytics cards, and reviews (viewable but not editable by the provider,
  matching the "admins only" rule).
- **Public provider profile** — cover, tier badge, rating, landmark,
  description, portfolio, reviews with provider responses, Contact button.
- **Chat screen** — text bubbles, a mic button for voice notes (UI is
  wired, recording itself is stubbed — see below), and a Work Agreement
  checklist bottom sheet (job scope / fee range / materials / completion
  date, deliberately with **no payment fields**).
- **Emergency Plug** — SOS button → category confirm sheet → responding
  providers list, consumer keeps full choice.
- **Job Request Board** — post a job (with voice-note attach point), list
  of active posts, respond entry point.
- **Admin console** — placeholder grid for the 8 admin functions in the
  spec (verification queue, user management, zone config, category
  management, moderation, review oversight, logo management, analytics).
  Recommend building this as a separate web dashboard rather than
  shipping admin tooling inside the consumer app.
- **Theming** — full light/dark mode, deep-green/gold trust palette,
  Material 3.
- **App icon** — `assets/icon/app_icon.svg`, a plug-in-a-location-pin
  mark (see below to turn it into launcher icons).

## What's intentionally stubbed (marked with `// TODO` in code)

These need real credentials/infra that only you can provide, so they're
left as clearly marked integration points rather than faked:

| Feature | File | What to do |
|---|---|---|
| Phone OTP auth | `screens/auth/*` | Wire to Supabase phone auth + SMS gateway fallback |
| Provider/review/zone data | `data/mock_data.dart` | Replace with Supabase queries; keep the same shapes so screens don't need rewrites |
| Push notifications | main.dart, emergency screen | Firebase Cloud Messaging init + handlers |
| Voice notes | `screens/chat/chat_screen.dart`, `screens/jobs/job_board_screen.dart` | `record` package to capture, upload to storage, attach URL |
| E2E encryption | chat layer | Add an encryption library (e.g. libsodium bindings) before messages leave the device |
| Offline caching | zones/categories | Hive/shared_preferences are already dependencies; add a cache-then-network pattern |

## A few additions beyond the original prompt

- **Recommendation score is a real formula**, not just distance — mixes
  tier, star rating, completed jobs, and responsiveness so a highly-rated
  Standard provider can still outrank a middling Gold one *within* the same
  proximity bucket, per your "not distance alone" requirement.
- **"Others" category has a defined admin workflow**: the admin console
  includes a Category Management tile specifically for promoting recurring
  "Others" submissions into first-class categories.
- **Masked phone number display** on the profile screen for privacy, since
  the spec mentions "partially hidden."
- **Provider identity verification flag** kept separate from tier, since a
  Gold applicant's documents may take time to review — the data model
  supports "Standard tier, verification pending" cleanly.

## Android platform folder

The `android/` directory (Gradle files, manifest, `MainActivity.kt`,
launcher icons) is now included — this is the native scaffolding
`flutter create` normally generates, and tools like FlutLab require it to
recognize the project. It targets:
- `applicationId` / package: `com.urplug.app`
- `minSdk` 21, `compileSdk`/`targetSdk` 34
- AGP 8.1.0, Kotlin 1.9.10, Gradle 8.3

If your build tool (FlutLab, Android Studio, CI) uses a different
Gradle/AGP/Kotlin version, it may auto-adjust these files on first sync —
that's normal. If you ever want the canonical, freshly-generated platform
folders instead (e.g. to also add `ios/`, `web/`, `windows/`, `linux/`,
`macos/`), run `flutter create .` inside the unzipped project on a machine
with the Flutter SDK installed; it will fill in anything missing without
touching your `lib/` code.

## App icon

`assets/icon/app_icon.png` (1024×1024) and `app_icon_foreground.png` are
already generated, along with the launcher PNGs under
`android/app/src/main/res/mipmap-*/ic_launcher.png` — a plug-in-a-rounded-
square mark in the brand green/gold. To regenerate a nicer/refined version
later and push it through all platforms and densities automatically:

```bash
flutter pub run flutter_launcher_icons
```

(`pubspec.yaml` is already configured for this — just replace
`assets/icon/app_icon.png` with a refined version first if you want.)

## Project structure

```
android/                 native platform scaffolding (Gradle, manifest, MainActivity, launcher icons)
lib/
  main.dart              entry point
  app.dart                MaterialApp + theme + state wiring
  theme/                   colors + light/dark ThemeData
  models/                  Zone, ProviderProfile, Review, ChatMessage, ...
  data/                    mock_data.dart (swap for Supabase), zone_matching_engine.dart
  state/                   app_state.dart (mode switching, current user, theme)
  widgets/                 reusable cards, badges, sidebar, carousel
  screens/
    auth/                  phone login, OTP
    home/                  Discover tab + bottom nav shell
    provider/               public profile, dashboard
    profile/                consumer profile, provider registration
    chat/                    chat screen, work agreement sheet
    emergency/               Emergency Plug
    jobs/                    Job Request Board
    admin/                   admin console placeholder
```
