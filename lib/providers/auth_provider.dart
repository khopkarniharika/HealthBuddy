import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/sms_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final SmsService _smsService;

  AuthProvider(this._authService, this._smsService);

  List<User> _users = <User>[];
  User? _currentUser;
  bool _loading = false;
  String? _error;

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await _authService.getAllUsers();
      _error = null;
    } catch (e) {
      _error = 'Failed to load users: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> registerUser(User user, {String? pin}) async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.createUser(user, pin: pin);
      await loadUsers();
      _error = null;
    } catch (e) {
      _error = 'Failed to register: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(User user, {String? pin}) async {
    _loading = true;
    notifyListeners();
    try {
      if (pin != null && pin.isNotEmpty) {
        final ok = await _authService.verifyPin(user.id, pin);
        if (!ok) {
          _error = 'Invalid PIN';
          _loading = false;
          notifyListeners();
          return false;
        }
      }

      _currentUser = user;
      await _authService.setLastLoggedUserId(user.id);

      if (user.userType == UserType.oldPerson) {
        final contacts = await _authService.getEmergencyContactsForUser(user);
        if (contacts.isNotEmpty) {
          await _smsService.sendLoginNotification(
            user: user,
            emergencyContacts: contacts,
          );
        }
      }

      _error = null;
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _authService.clearLastLoggedUserId();
    notifyListeners();
  }
}