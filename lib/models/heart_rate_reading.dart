import 'dart:convert';

class HeartRateReading {
  final int bpm;
  final DateTime timestamp;
  final String userId;
  final bool isAlert;

  HeartRateReading({
    required this.bpm,
    required this.timestamp,
    required this.userId,
    required this.isAlert,
  });

  Map<String, dynamic> toJson() => {
        'bpm': bpm,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'isAlert': isAlert,
      };

  factory HeartRateReading.fromJson(Map<String, dynamic> json) {
    return HeartRateReading(
      bpm: json['bpm'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      isAlert: json['isAlert'] as bool? ?? false,
    );
  }

  static String encodeList(List<HeartRateReading> readings) =>
      jsonEncode(readings.map((r) => r.toJson()).toList());

  static List<HeartRateReading> decodeList(String source) {
    final List<dynamic> data = jsonDecode(source) as List<dynamic>;
    return data
        .map((e) => HeartRateReading.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}