import 'zone.dart';

class JobPost {
  final String id;
  final String consumerId;
  final String categoryId;
  final String description;
  final String? voiceNoteUrl;
  final ZoneAddress zone;
  final DateTime createdAt;
  final bool isOpen;

  const JobPost({
    required this.id,
    required this.consumerId,
    required this.categoryId,
    required this.description,
    required this.zone,
    required this.createdAt,
    this.voiceNoteUrl,
    this.isOpen = true,
  });
}

enum MessageType { text, voiceNote, workAgreement }

class ChatMessage {
  final String id;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? voiceNoteUrl;
  final Duration? voiceNoteDuration;
  final WorkAgreement? agreement;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.sentAt,
    this.text,
    this.voiceNoteUrl,
    this.voiceNoteDuration,
    this.agreement,
  });
}

/// The in-chat work agreement checklist. Deliberately excludes any payment
/// processing — it just records agreed terms so both sides have a shared
/// reference point.
class WorkAgreement {
  final String jobScope;
  final String laborFeeRange;
  final String materialsResponsibility;
  final DateTime completionDate;
  final bool confirmedByConsumer;
  final bool confirmedByProvider;

  const WorkAgreement({
    required this.jobScope,
    required this.laborFeeRange,
    required this.materialsResponsibility,
    required this.completionDate,
    this.confirmedByConsumer = false,
    this.confirmedByProvider = false,
  });

  WorkAgreement copyWith({bool? confirmedByConsumer, bool? confirmedByProvider}) {
    return WorkAgreement(
      jobScope: jobScope,
      laborFeeRange: laborFeeRange,
      materialsResponsibility: materialsResponsibility,
      completionDate: completionDate,
      confirmedByConsumer: confirmedByConsumer ?? this.confirmedByConsumer,
      confirmedByProvider: confirmedByProvider ?? this.confirmedByProvider,
    );
  }
}

enum AppMode { consumer, provider }

class UserProfile {
  final String id;
  final String displayName;
  final String phoneNumber; // shown partially masked in UI
  final String? avatarUrl;
  final bool isRegisteredProvider;
  final String? providerId; // set once registered as a provider
  final ZoneAddress? homeZone;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    this.avatarUrl,
    this.isRegisteredProvider = false,
    this.providerId,
    this.homeZone,
  });

  String get maskedPhone {
    if (phoneNumber.length < 6) return phoneNumber;
    final visibleStart = phoneNumber.substring(0, 5);
    final visibleEnd = phoneNumber.substring(phoneNumber.length - 2);
    return '$visibleStart••••$visibleEnd';
  }
}
