import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/heart_rate_reading.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../services/heart_rate_service.dart';
import 'history_screen.dart';

class EmergencyDashboardScreen extends StatefulWidget {
  const EmergencyDashboardScreen({super.key, required this.user});

  static const routeName = '/emergency-dashboard';

  final User user;

  @override
  State<EmergencyDashboardScreen> createState() =>
      _EmergencyDashboardScreenState();
}

class _EmergencyDashboardScreenState extends State<EmergencyDashboardScreen> {
  User? _monitored;
  HeartRateReading? _lastReading;
  HeartRateStats? _todayStats;
  int _alerts7d = 0;
  List<HeartRateReading> _alertsList = <HeartRateReading>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authService = context.read<AuthService>();
    final heartService = context.read<HeartRateService>();
    final dependents = await authService
        .getDependentsForEmergencyContact(widget.user.id);

    if (dependents.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      return;
    }

    final monitored = dependents.first;
    final readings = await heartService.getReadingsForUser(monitored.id);
    HeartRateReading? last;
    if (readings.isNotEmpty) {
      last = readings.first;
    }
    final todayStats = await heartService.getStatsForUserToday(monitored.id);
    final alertsCount = await heartService.getAlertsCountLast7Days(monitored.id);
    final alertsList = await heartService.getAlertsLast7Days(monitored.id);

    if (!mounted) return;
    setState(() {
      _monitored = monitored;
      _lastReading = last;
      _todayStats = todayStats;
      _alerts7d = alertsCount;
      _alertsList = alertsList;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settings.t('emergency_dashboard_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : _monitored == null
              ? Center(
                  child: Text(
                    'No dependents linked to this contact.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${settings.t('monitoring')}: ${_monitored!.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMonitoringCard(),
                      const SizedBox(height: 16),
                      _buildAlertsSection(),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: _callMonitored,
                              icon: const Icon(Icons.call),
                              label: Text(settings.t('call')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (_monitored == null) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HistoryScreen(user: _monitored!),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bar_chart),
                              label: Text(settings.t('history')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMonitoringCard() {
    final last = _lastReading;
    final stats = _todayStats;
    final settings = context.read<SettingsProvider>();

    String lastText;
    String timeText;
    if (last == null) {
      lastText = '-- BPM';
      timeText = settings.t('no_data');
    } else {
      lastText = '${last.bpm} BPM';
      final diff = DateTime.now().difference(last.timestamp);
      if (diff.inMinutes < 1) {
        timeText = 'Just now';
      } else {
        timeText = '${diff.inMinutes} mins ago';
      }
    }

    String todayText;
    if (stats == null) {
      todayText = 'Avg -- | Min --';
    } else {
      todayText =
          'Avg ${stats.avg.toStringAsFixed(0)} | Min ${stats.min.toString()}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💗 ${settings.t('last_reading')}: $lastText ✓ ($timeText)',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '📊 Today: $todayText',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '🔔 ${settings.t('alerts_7d')}: $_alerts7d',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    if (_alertsList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.builder(
          itemCount: _alertsList.length,
          itemBuilder: (context, index) {
            final alert = _alertsList[index];
            return ListTile(
              dense: true,
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow,
              ),
              title: Text(
                '⚠️ ${DateFormat('MMM d').format(alert.timestamp)} - ${alert.bpm} BPM',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _callMonitored() async {
    final monitored = _monitored;
    if (monitored == null) return;
    final uri = Uri(scheme: 'tel', path: monitored.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

