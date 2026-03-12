import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _service;

  AppSettings _settings =
      AppSettings(language: 'en', isDarkMode: true, fontSize: 16.0);
  bool _loading = true;

  SettingsProvider(this._service);

  AppSettings get settings => _settings;
  bool get isLoading => _loading;

  /// Simple key-based localization for EN / MR / HI.
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'login_title': 'Heart Rate Monitor',
      'login_subtitle': 'Select user to continue',
      'login_button': 'Login',
      'register': 'Register',
      'user_type_old': 'Old Person',
      'user_type_emergency': 'Emergency Contact',
      'name': 'Name',
      'phone': 'Phone Number',
      'pin': '4-digit PIN (optional)',
      'home_title': 'Home',
      'activity_title': 'Activity',
      'history_title': 'History',
      'settings_title': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark mode',
      'light_mode': 'Light mode',
      'font_size': 'Font size',
      'logout': 'Logout',
      'sos': 'SOS',
      'place_finger': 'Place finger on camera',
      'min': 'MIN',
      'max': 'MAX',
      'start_measurement': 'Start Measurement',
      'emergency_dashboard_title': 'Emergency Dashboard',
      'monitoring': 'Monitoring',
      'last_reading': 'Last',
      'today_stats': 'Today',
      'alerts_7d': 'Alerts (7d)',
      'call': 'Call',
      'history': 'History',
      'no_data': 'No data',
      'measuring': 'Measuring...',
    },
    'mr': {
      'login_title': 'हार्ट रेट मॉनिटर',
      'login_subtitle': 'पुढे जाण्यासाठी वापरकर्ता निवडा',
      'login_button': 'लॉगिन',
      'register': 'नोंदणी',
      'user_type_old': 'ज्येष्ठ नागरिक',
      'user_type_emergency': 'आपत्कालीन संपर्क',
      'name': 'नाव',
      'phone': 'मोबाइल क्रमांक',
      'pin': '४ अंकी पिन (पर्यायी)',
      'home_title': 'मुख्य',
      'activity_title': 'क्रियाकलाप',
      'history_title': 'इतिहास',
      'settings_title': 'सेटिंग्ज',
      'language': 'भाषा',
      'theme': 'थीम',
      'dark_mode': 'डार्क मोड',
      'light_mode': 'लाईट मोड',
      'font_size': 'फाँट साईज',
      'logout': 'लॉगआउट',
      'sos': 'एसओएस',
      'place_finger': 'कॅमेऱ्यावर बोट ठेवा',
      'min': 'किमान',
      'max': 'कमाल',
      'start_measurement': 'मोजमाप सुरू करा',
      'emergency_dashboard_title': 'आपत्कालीन डॅशबोर्ड',
      'monitoring': 'मॉनिटरिंग',
      'last_reading': 'शेवटचे',
      'today_stats': 'आज',
      'alerts_7d': 'अलर्ट (७ दिवस)',
      'call': 'कॉल',
      'history': 'इतिहास',
      'no_data': 'माहिती उपलब्ध नाही',
      'measuring': 'मोजमाप सुरू आहे...',
    },
    'hi': {
      'login_title': 'हार्ट रेट मॉनिटर',
      'login_subtitle': 'आगे बढ़ने के लिए उपयोगकर्ता चुनें',
      'login_button': 'लॉगिन',
      'register': 'रजिस्ट्रेशन',
      'user_type_old': 'वरिष्ठ नागरिक',
      'user_type_emergency': 'आपातकालीन संपर्क',
      'name': 'नाम',
      'phone': 'मोबाइल नंबर',
      'pin': '4 अंकों का पिन (वैकल्पिक)',
      'home_title': 'होम',
      'activity_title': 'गतिविधि',
      'history_title': 'इतिहास',
      'settings_title': 'सेटिंग्स',
      'language': 'भाषा',
      'theme': 'थीम',
      'dark_mode': 'डार्क मोड',
      'light_mode': 'लाइट मोड',
      'font_size': 'फॉन्ट साइज',
      'logout': 'लॉगआउट',
      'sos': 'एसओएस',
      'place_finger': 'कैमरे पर उंगली रखें',
      'min': 'न्यूनतम',
      'max': 'अधिकतम',
      'start_measurement': 'माप शुरू करें',
      'emergency_dashboard_title': 'आपातकालीन डैशबोर्ड',
      'monitoring': 'निगरानी',
      'last_reading': 'अंतिम',
      'today_stats': 'आज',
      'alerts_7d': 'अलर्ट (7 दिन)',
      'call': 'कॉल',
      'history': 'इतिहास',
      'no_data': 'कोई डेटा नहीं',
      'measuring': 'माप जारी है...',
    },
  };

  String t(String key) {
    final lang = _settings.language;
    return _localizedStrings[lang]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _settings = await _service.loadSettings();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _service.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await _service.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setFontSize(double fontSize) async {
    _settings = _settings.copyWith(fontSize: fontSize);
    await _service.saveSettings(_settings);
    notifyListeners();
  }
}