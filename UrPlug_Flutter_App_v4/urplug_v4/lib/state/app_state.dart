import 'package:flutter/material.dart';
import '../models/chat_and_jobs.dart';
import '../models/zone.dart';
import '../models/provider_profile.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  AppMode mode = AppMode.consumer;

  // Demo signed-in user. In production this comes from Firebase Auth
  // (phone + OTP) after PhoneLoginScreen / OtpVerificationScreen succeed.
  UserProfile currentUser = const UserProfile(
    id: 'u_demo',
    displayName: 'Demo User',
    phoneNumber: '+256772123456',
    isRegisteredProvider: false,
    homeZone: MockData.consumerHomeZone,
  );

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  void toggleMode() {
    if (!currentUser.isRegisteredProvider) return;
    mode = mode == AppMode.consumer ? AppMode.provider : AppMode.consumer;
    notifyListeners();
  }

  /// Called from ConsumerSetupScreen after the consumer fills in name + zone.
  /// Quick shortcut used by LocationSetupScreen.
  void setConsumerZone(ZoneAddress zone) {
    updateConsumer(displayName: currentUser.displayName, zone: zone);
  }

  void updateConsumer({required String displayName, ZoneAddress? zone}) {
    currentUser = UserProfile(
      id: currentUser.id,
      displayName: displayName,
      phoneNumber: currentUser.phoneNumber,
      avatarUrl: currentUser.avatarUrl,
      isRegisteredProvider: currentUser.isRegisteredProvider,
      providerId: currentUser.providerId,
      homeZone: zone ?? currentUser.homeZone,
    );
    notifyListeners();
  }

  /// Called once provider registration (category, description, National ID,
  /// operating zones, landmark, contact) completes successfully server-side.
  void completeProviderRegistration(String providerId) {
    currentUser = UserProfile(
      id: currentUser.id,
      displayName: currentUser.displayName,
      phoneNumber: currentUser.phoneNumber,
      avatarUrl: currentUser.avatarUrl,
      isRegisteredProvider: true,
      providerId: providerId,
      homeZone: currentUser.homeZone,
    );
    mode = AppMode.provider;
    notifyListeners();
  }

  ProviderProfile? get myProviderProfile {
    if (currentUser.providerId == null) return null;
    try {
      return MockData.providers.firstWhere((p) => p.id == currentUser.providerId);
    } catch (_) {
      return null;
    }
  }
}
