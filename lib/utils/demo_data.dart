import '../models/user.dart';
import '../models/heart_rate_reading.dart';
import '../services/auth_service.dart';
import '../services/heart_rate_service.dart';
import 'dart:math';

/// Utility to create demo data for testing the app
class DemoData {
  static Future<void> createDemoUsers() async {
    final authService = AuthService();
    final heartRateService = HeartRateService();
    final random = Random();

    // Create emergency contact first
    final emergencyContact = User(
      id: 'emergency_001',
      name: 'Dr. Smith',
      phoneNumber: '+1234567890',
      userType: UserType.emergencyContact,
      emergencyContactIds: [],
    );
    await authService.createUser(emergencyContact, pin: '1234');

    // Create old person with emergency contact
    final oldPerson = User(
      id: 'old_001',
      name: 'John Doe',
      phoneNumber: '+0987654321',
      userType: UserType.oldPerson,
      emergencyContactIds: [emergencyContact.id],
    );
    await authService.createUser(oldPerson, pin: '5678');

    // Create some sample heart rate readings
    final now = DateTime.now();
    for (int i = 0; i < 20; i++) {
      final timestamp = now.subtract(Duration(hours: i * 2));
      final bpm = 65 + random.nextInt(60); // Random between 65-125
      final isAlert = bpm >= 120;
      
      final reading = HeartRateReading(
        bpm: bpm,
        timestamp: timestamp,
        userId: oldPerson.id,
        isAlert: isAlert,
      );
      await heartRateService.saveReading(reading);
    }

    print('Demo data created successfully!');
    print('Emergency Contact: Dr. Smith (PIN: 1234)');
    print('Old Person: John Doe (PIN: 5678)');
  }
}
