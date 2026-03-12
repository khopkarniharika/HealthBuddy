import 'dart:convert';

enum UserType { oldPerson, emergencyContact }

UserType userTypeFromString(String value) {
  switch (value) {
    case 'oldPerson':
      return UserType.oldPerson;
    case 'emergencyContact':
      return UserType.emergencyContact;
    default:
      return UserType.oldPerson;
  }
}

String userTypeToString(UserType type) {
  switch (type) {
    case UserType.oldPerson:
      return 'oldPerson';
    case UserType.emergencyContact:
      return 'emergencyContact';
  }
}

class User {
  final String id;
  final String name;
  final String phoneNumber;
  final UserType userType;
  final List<String> emergencyContactIds; // IMPORTANT: plural list
  final String? pin; // optional 4-digit PIN (only used in-memory, not persisted here)

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    required this.emergencyContactIds,
    this.pin,
  });

  User copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    UserType? userType,
    List<String>? emergencyContactIds,
    String? pin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      emergencyContactIds: emergencyContactIds ?? this.emergencyContactIds,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'userType': userTypeToString(userType),
        'emergencyContactIds': emergencyContactIds,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userType: userTypeFromString(json['userType'] as String),
      emergencyContactIds: (json['emergencyContactIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
    );
  }

  static String encodeList(List<User> users) =>
      jsonEncode(users.map((u) => u.toJson()).toList());

  static List<User> decodeList(String source) {
    final List<dynamic> data = jsonDecode(source) as List<dynamic>;
    return data
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}