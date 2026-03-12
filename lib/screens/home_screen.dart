import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/heart_rate_reading.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../services/heart_rate_service.dart';
import '../services/sms_service.dart';
import 'activity_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  static const routeName = '/home';

  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  int _currentBpm = 0;
  int _minBpm = 65;
  int _maxBpm = 130;
  bool _isMeasuring = false;
  Timer? _measurementTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _loadInitialStats();
  }

  Future<void> _loadInitialStats() async {
    final heartService = context.read<HeartRateService>();
    final stats = await heartService.getStatsForUserToday(widget.user.id);
    if (stats != null && mounted) {
      setState(() {
        _minBpm = stats.min;
        _maxBpm = stats.max;
        _currentBpm = stats.avg.round();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _measurementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settings.t('home_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: settings.t('logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  onPressed: _sendSos,
                  child: Text(
                    settings.t('sos'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor:
                          Colors.cyan.withValues(alpha: 0.15),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.8),
                              Colors.cyan.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentBpm > 0 ? '$_currentBpm' : '--',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'BPM',
                                style: TextStyle(
                                  color: Colors.white70,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    settings.t('place_finger'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatCard(
                          label: settings.t('min'),
                          value: _minBpm.toString(),
                        ),
                        _StatCard(
                          label: settings.t('max'),
                          value: _maxBpm.toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _isMeasuring ? null : _startMeasurement,
                      child: Text(
                        _isMeasuring
                            ? context
                                .read<SettingsProvider>()
                                .t('measuring')
                            : settings.t('start_measurement'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2C3E50),
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivityScreen(user: widget.user),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoryScreen(user: widget.user),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }

  Future<void> _startMeasurement() async {
    setState(() {
      _isMeasuring = true;
    });

    _measurementTimer?.cancel();
    _measurementTimer = Timer(const Duration(seconds: 3), () async {
      final random = Random();
      final bpm = 65 + random.nextInt(61); // 65-125
      final heartService = context.read<HeartRateService>();
      final isDangerous = heartService.isDangerous(bpm);
      final reading = HeartRateReading(
        bpm: bpm,
        timestamp: DateTime.now(),
        userId: widget.user.id,
        isAlert: isDangerous,
      );
      await heartService.saveReading(reading);

      if (!mounted) return;

      setState(() {
        _currentBpm = bpm;
        _minBpm = min(_minBpm, bpm);
        _maxBpm = max(_maxBpm, bpm);
        _isMeasuring = false;
      });

      if (isDangerous && widget.user.userType == UserType.oldPerson) {
        final authService = context.read<AuthService>();
        final smsService = context.read<SmsService>();
        final contacts =
            await authService.getEmergencyContactsForUser(widget.user);
        if (contacts.isNotEmpty) {
          await smsService.sendDangerAlert(
            oldPerson: widget.user,
            emergencyContacts: contacts,
            bpm: bpm,
          );
        }
      }
    });
  }

  Future<void> _sendSos() async {
    final authService = context.read<AuthService>();
    final smsService = context.read<SmsService>();
    final contacts =
        await authService.getEmergencyContactsForUser(widget.user);
    if (contacts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contacts configured')),
      );
      return;
    }
    await smsService.sendSosAlert(
      oldPerson: widget.user,
      emergencyContacts: contacts,
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
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
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

