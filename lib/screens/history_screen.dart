import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/heart_rate_reading.dart';
import '../models/user.dart';
import '../providers/settings_provider.dart';
import '../services/heart_rate_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.user});

  final User user;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settings.t('history_title')),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : _readings.isEmpty
              ? Center(
                  child: Text(
                    settings.t('no_data'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _readings.length,
                  itemBuilder: (context, index) {
                    final r = _readings[index];
                    final isAlert = r.isAlert;
                    return ListTile(
                      tileColor: const Color(0xFF2C3E50),
                      leading: CircleAvatar(
                        backgroundColor: isAlert
                            ? Colors.redAccent
                            : Colors.cyan.withValues(alpha: 0.6),
                        child: Text(
                          r.bpm.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${r.bpm} BPM',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        DateFormat('MMM d, yyyy – hh:mm a').format(r.timestamp),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: isAlert
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ALERT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
    );
  }
}

