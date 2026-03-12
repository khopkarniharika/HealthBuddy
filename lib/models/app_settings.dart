import 'dart:convert';

class AppSettings {
  final String language; // 'en' | 'mr' | 'hi'
  final bool isDarkMode;
  final double fontSize;

  AppSettings({
    required this.language,
    required this.isDarkMode,
    required this.fontSize,
  });

  AppSettings copyWith({
    String? language,
    bool? isDarkMode,
    double? fontSize,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'isDarkMode': isDarkMode,
        'fontSize': fontSize,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] as String? ?? 'en',
      isDarkMode: json['isDarkMode'] as bool? ?? true,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    );
  }

  static String encode(AppSettings settings) =>
      jsonEncode(settings.toJson());

  static AppSettings decode(String source) =>
      AppSettings.fromJson(jsonDecode(source) as Map<String, dynamic>);
}