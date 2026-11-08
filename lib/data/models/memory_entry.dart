class MemoryEntry {
  const MemoryEntry({required this.id, required this.title, required this.occurredAt, this.description, this.photoPaths = const [], this.isFavorite = false});

  final String id;
  final String title;
  final String? description;
  final List<String> photoPaths;
  final DateTime occurredAt;
  final bool isFavorite;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'photoPaths': photoPaths, 'occurredAt': occurredAt.toIso8601String(), 'isFavorite': isFavorite};

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        photoPaths: (json['photoPaths'] as List<dynamic>? ?? const []).cast<String>(),
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
