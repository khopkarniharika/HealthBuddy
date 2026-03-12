import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/heart_rate_reading.dart';
import '../models/user.dart';
import '../providers/settings_provider.dart';
import '../services/heart_rate_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.user});

  final User user;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _loading = true;
  List<HeartRateReading> _readings = <HeartRateReading>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<HeartRateService>();
    final readings = await service.getReadingsForUser(widget.user.id);
    if (!mounted) return;
    setState(() {
      _readings = readings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    final now = DateTime.now();
    final last7Days = List<DateTime>.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day - (6 - index)),
    );

    final Map<DateTime, List<int>> buckets = {};
    for (final day in last7Days) {
      buckets[DateTime(day.year, day.month, day.day)] = <int>[];
    }

    for (final r in _readings) {
      final key = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
      if (buckets.containsKey(key)) {
        buckets[key]!.add(r.bpm);
      }
    }

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final values = buckets[DateTime(day.year, day.month, day.day)]!;
      final double avg =
          values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(4),
              width: 14,
            ),
          ],
        ),
      );
    }

    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settings.t('activity_title')),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    height: 260,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= last7Days.length) {
                                  return const SizedBox.shrink();
                                }
                                final d = last7Days[index];
                                return Text(
                                  DateFormat.E().format(d),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Avg',
                          value: stats == null
                              ? '--'
                              : (stats['avg'] as num).toStringAsFixed(1),
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Min',
                          value: stats == null
                              ? '--'
                              : (stats['min'] as num).toString(),
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Max',
                          value: stats == null
                              ? '--'
                              : (stats['max'] as num).toString(),
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, num>? _calculateStats() {
    if (_readings.isEmpty) return null;
    int min = _readings.first.bpm;
    int max = _readings.first.bpm;
    int sum = 0;
    for (final r in _readings) {
      sum += r.bpm;
      if (r.bpm < min) min = r.bpm;
      if (r.bpm > max) max = r.bpm;
    }
    return {
      'avg': sum / _readings.length,
      'min': min,
      'max': max,
    };
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

