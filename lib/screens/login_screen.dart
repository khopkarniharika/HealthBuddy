import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/demo_data.dart';
import 'emergency_dashboard_screen.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserType _selectedType = UserType.oldPerson;
  User? _selectedUser;
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final users = auth.users
        .where((u) => u.userType == _selectedType)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                settings.t('login_title'),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.cyan, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                settings.t('login_subtitle'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _UserTypeChip(
                      label: settings.t('user_type_old'),
                      selected: _selectedType == UserType.oldPerson,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.oldPerson;
                          _selectedUser = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UserTypeChip(
                      label: settings.t('user_type_emergency'),
                      selected: _selectedType == UserType.emergencyContact,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.emergencyContact;
                          _selectedUser = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<User>(
                value: _selectedUser,
                dropdownColor: const Color(0xFF2C3E50),
                decoration: InputDecoration(
                  labelText: settings.t('name'),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C3E50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                iconEnabledColor: Colors.cyan,
                items: users
                    .map(
                      (u) => DropdownMenuItem<User>(
                        value: u,
                        child: Text(
                          '${u.name} (${u.phoneNumber})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUser = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                maxLength: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: settings.t('pin'),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C3E50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (auth.error != null)
                Text(
                  auth.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: auth.isLoading ? null : _onLoginPressed,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                      : Text(
                          settings.t('login_button'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegistrationScreen(),
                    ),
                  );
                },
                child: Text(
                  settings.t('register'),
                  style: const TextStyle(color: Colors.pinkAccent),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _createDemoData,
                child: Text(
                  'Create Demo Data',
                  style: const TextStyle(color: Colors.cyan),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final auth = context.read<AuthProvider>();
    final user = _selectedUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    final pin = _pinController.text.trim();
    if (pin.isNotEmpty && pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 4 digits')),
      );
      return;
    }

    final success = await auth.login(user, pin: pin.isEmpty ? null : pin);
    if (!success) return;

    if (user.userType == UserType.oldPerson) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EmergencyDashboardScreen(user: user)),
      );
    }
  }

  Future<void> _createDemoData() async {
    try {
      await DemoData.createDemoUsers();
      await context.read<AuthProvider>().loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo data created! You can now login with:\n\n'
                'Old Person: John Doe (PIN: 5678)\n'
                'Emergency: Dr. Smith (PIN: 1234)'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _UserTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UserTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.cyan
              : const Color(0xFF2C3E50).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.cyan : Colors.white24,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

