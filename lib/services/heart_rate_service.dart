import 'package:shared_preferences/shared_preferences.dart';
import '../models/heart_rate_reading.dart';

class HeartRateStats {
  final double avg;
  final int min;
  final int max;

  HeartRateStats({required this.avg, required this.min, required this.max});
}

class HeartRateService {
  static const _readingsKey = 'heart_rate_readings';

  Future<List<HeartRateReading>> _loadReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_readingsKey);
    if (data == null) return <HeartRateReading>[];
    try {
      return HeartRateReading.decodeList(data);
    } catch (_) {
      return <HeartRateReading>[];
    }
  }

  Future<void> _saveReadings(List<HeartRateReading> readings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _readingsKey, HeartRateReading.encodeList(readings));
  }

  Future<HeartRateReading> saveReading(HeartRateReading reading) async {
    final readings = await _loadReadings();
    readings.add(reading);
    await _saveReadings(readings);
    return reading;
  }

  Future<List<HeartRateReading>> getReadingsForUser(String userId) async {
    final readings = await _loadReadings();
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings.where((r) => r.userId == userId).toList();
  }

  bool isDangerous(int bpm) => bpm >= 120;

  Future<HeartRateStats?> getStatsForUserToday(String userId) async {
    final all = await getReadingsForUser(userId);
    final now = DateTime.now();
    final today = all.where((r) =>
        r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day);
    final list = today.toList();
    if (list.isEmpty) return null;
    int min = list.first.bpm;
    int max = list.first.bpm;
    int sum = 0;
    for (final r in list) {
      sum += r.bpm;
      if (r.bpm < min) min = r.bpm;
      if (r.bpm > max) max = r.bpm;
    }
    return HeartRateStats(
      avg: sum / list.length,
      min: min,
      max: max,
    );
  }

  Future<int> getAlertsCountLast7Days(String userId) async {
    final readings = await getReadingsForUser(userId);
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return readings
        .where((r) => r.isAlert && r.timestamp.isAfter(sevenDaysAgo))
        .length;
  }

  Future<List<HeartRateReading>> getAlertsLast7Days(String userId) async {
    final readings = await getReadingsForUser(userId);
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return readings
        .where((r) => r.isAlert && r.timestamp.isAfter(sevenDaysAgo))
        .toList();
  }
}