class GratitudeEntry {
  final String id;
  final String text;
  final DateTime date; // The date the entry is for (normalized to midnight)
  final DateTime timestamp; // Actual creation time

  GratitudeEntry({
    required this.id,
    required this.text,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'date': date.toIso8601String(),
    'timestamp': timestamp.toIso8601String(),
  };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
