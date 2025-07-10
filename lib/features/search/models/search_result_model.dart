class SearchResultModel {
  final String id;
  final String type; // 'profile', 'photo', 'video', 'text'
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  const SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.timestamp,
    this.additionalData,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'text',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'additional_data': additionalData,
    };
  }
}
