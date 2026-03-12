import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settingsProvider.t('settings_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settingsProvider.t('language'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LanguageChip(
                  label: 'EN',
                  selected: settings.language == 'en',
                  onTap: () => settingsProvider.setLanguage('en'),
                ),
                const SizedBox(width: 8),
                _LanguageChip(
                  label: 'MR',
                  selected: settings.language == 'mr',
                  onTap: () => settingsProvider.setLanguage('mr'),
                ),
                const SizedBox(width: 8),
                _LanguageChip(
                  label: 'HI',
                  selected: settings.language == 'hi',
                  onTap: () => settingsProvider.setLanguage('hi'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  settingsProvider.t('theme'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: settings.isDarkMode,
                  activeColor: Colors.cyan,
                  onChanged: (_) => settingsProvider.toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              settingsProvider.t('font_size'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: settings.fontSize,
              min: 14,
              max: 22,
              activeColor: Colors.cyan,
              inactiveColor: Colors.white24,
              onChanged: (value) => settingsProvider.setFontSize(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.cyan : const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

