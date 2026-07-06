class Review {
  final String id;
  final String providerId;
  final String consumerDisplayName;
  final int stars; // 1-5
  final String comment;
  final DateTime createdAt;
  final String? providerResponse; // providers may post exactly one response

  const Review({
    required this.id,
    required this.providerId,
    required this.consumerDisplayName,
    required this.stars,
    required this.comment,
    required this.createdAt,
    this.providerResponse,
  });
}
