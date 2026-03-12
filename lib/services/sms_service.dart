import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';

/// Simplified SMS service that opens SMS app with Marathi messages
class SmsService {
  Future<void> _openSmsApp(String phone, String body) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': body},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendLoginNotification({
    required User user,
    required List<User> emergencyContacts,
  }) async {
    final message =
        'सूचना: ${user.name} (${userTypeToString(user.userType)}) अॅपमध्ये लॉग इन झाले आहे.';

    for (final contact in emergencyContacts) {
      await _openSmsApp(contact.phoneNumber, message);
    }
  }

  Future<void> sendDangerAlert({
    required User oldPerson,
    required List<User> emergencyContacts,
    required int bpm,
  }) async {
    final message =
        'आपत्कालीन सूचना: ${oldPerson.name} यांचा हृदय गती $bpm BPM आहे. कृपया त्वरित संपर्क साधा.';

    for (final contact in emergencyContacts) {
      await _openSmsApp(contact.phoneNumber, message);
    }
  }

  Future<void> sendSosAlert({
    required User oldPerson,
    required List<User> emergencyContacts,
  }) async {
    final message =
        'एसओएस: ${oldPerson.name} यांनी मदतीसाठी SOS पाठवले आहे. कृपया त्वरित संपर्क साधा.';

    for (final contact in emergencyContacts) {
      await _openSmsApp(contact.phoneNumber, message);
    }
  }
}