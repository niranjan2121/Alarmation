class ManifestationTemplate {
  final String id;
  final String text;
  final String category; // e.g., 'Fitness', 'Wealth', 'Focus'
  final bool isPremium; // Locks behind the Pro paywall
  final int wordCount;

  ManifestationTemplate({
    required this.id,
    required this.text,
    required this.category,
    required this.isPremium,
    required this.wordCount,
  });

  // Converts cloud database JSON into our Flutter Object
  factory ManifestationTemplate.fromJson(
      Map<String, dynamic> json, String documentId) {
    return ManifestationTemplate(
      id: documentId,
      text: json['text'] ?? '',
      category: json['category'] ?? 'General',
      isPremium: json['isPremium'] ?? false,
      wordCount: json['wordCount'] ?? 0,
    );
  }

  // Converts our Flutter Object back into JSON for the Admin Panel to upload
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'category': category,
      'isPremium': isPremium,
      'wordCount': wordCount,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
