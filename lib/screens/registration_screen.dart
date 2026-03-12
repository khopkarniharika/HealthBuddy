import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  UserType _selectedType = UserType.oldPerson;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final Set<String> _selectedEmergencyContactIds = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final emergencyContacts = auth.users
        .where((u) => u.userType == UserType.emergencyContact)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        title: Text(settings.t('register')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _UserTypeCard(
                      label: settings.t('user_type_old'),
                      icon: Icons.elderly,
                      selected: _selectedType == UserType.oldPerson,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.oldPerson;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UserTypeCard(
                      label: settings.t('user_type_emergency'),
                      icon: Icons.shield_moon,
                      selected: _selectedType == UserType.emergencyContact,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.emergencyContact;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: settings.t('name'),
                controller: _nameController,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: settings.t('phone'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: settings.t('pin'),
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
              ),
              const SizedBox(height: 16),
              if (_selectedType == UserType.oldPerson)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.t('user_type_emergency'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.cyan),
                    ),
                    const SizedBox(height: 8),
                    if (emergencyContacts.isEmpty)
                      const Text(
                        'No emergency contacts yet. Register them first.',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: emergencyContacts
                            .map(
                              (contact) => FilterChip(
                                label: Text(contact.name),
                                selected: _selectedEmergencyContactIds
                                    .contains(contact.id),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedEmergencyContactIds
                                          .add(contact.id);
                                    } else {
                                      _selectedEmergencyContactIds
                                          .remove(contact.id);
                                    }
                                  });
                                },
                                backgroundColor:
                                    const Color(0xFF2C3E50).withValues(
                                  alpha: 0.9,
                                ),
                                selectedColor: Colors.cyan,
                                labelStyle: TextStyle(
                                  color: _selectedEmergencyContactIds
                                          .contains(contact.id)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              if (auth.error != null)
                Text(
                  auth.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
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
                  onPressed: auth.isLoading ? null : _onRegisterPressed,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                      : Text(
                          settings.t('register'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        counterText: maxLength != null ? '' : null,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2C3E50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required')),
      );
      return;
    }
    if (pin.isNotEmpty && pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 4 digits')),
      );
      return;
    }
    if (_selectedType == UserType.oldPerson &&
        _selectedEmergencyContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one emergency contact'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phoneNumber: phone,
      userType: _selectedType,
      emergencyContactIds: _selectedType == UserType.oldPerson
          ? _selectedEmergencyContactIds.toList()
          : <String>[],
    );

    await auth.registerUser(newUser, pin: pin.isEmpty ? null : pin);
    if (auth.error == null && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _UserTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? Colors.cyan
              : const Color(0xFF2C3E50).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.cyan : Colors.white24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.black : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

