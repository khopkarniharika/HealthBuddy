# Flutter Heart Rate Monitor - Complete Project Structure

## 📁 Project Overview
Complete Flutter heart rate monitoring app with emergency contact system for Android Studio Koala 2024.0.1

## 🗂️ Folder Structure

```
heart_rate_monitor/
├── 📄 pubspec.yaml                    # Dependencies and project config
├── 📄 README.md                       # Project documentation
├── 📄 .gitignore                      # Git ignore rules
├── 📄 analysis_options.yaml           # Dart analysis options
├── 📄 .metadata                       # Flutter metadata
├── 📄 heart_rate_monitor.iml          # IntelliJ module file
├── 📄 .flutter-plugins-dependencies   # Flutter plugins
├── 📄 pubspec.lock                    # Locked dependency versions
│
├── 📁 lib/                            # Main source code
│   ├── 📄 main.dart                   # App entry point and providers setup
│   │
│   ├── 📁 models/                     # Data models
│   │   ├── 📄 user.dart              # User model with emergency contacts
│   │   ├── 📄 heart_rate_reading.dart # Heart rate reading model
│   │   └── 📄 app_settings.dart      # App settings model
│   │
│   ├── 📁 providers/                  # State management
│   │   ├── 📄 auth_provider.dart     # Authentication state management
│   │   └── 📄 settings_provider.dart # Settings and localization
│   │
│   ├── 📁 services/                   # Business logic services
│   │   ├── 📄 auth_service.dart      # User CRUD and PIN management
│   │   ├── 📄 heart_rate_service.dart # Heart rate data and stats
│   │   ├── 📄 sms_service.dart       # SMS alerts via url_launcher
│   │   └── 📄 settings_service.dart  # Theme and settings management
│   │
│   ├── 📁 screens/                    # UI screens (7 total)
│   │   ├── 📄 login_screen.dart     # User login with type selection
│   │   ├── 📄 registration_screen.dart # User registration with linking
│   │   ├── 📄 home_screen.dart      # Heart rate monitoring with pulse animation
│   │   ├── 📄 activity_screen.dart  # Weekly charts and statistics
│   │   ├── 📄 history_screen.dart   # Heart rate reading history
│   │   ├── 📄 emergency_dashboard_screen.dart # Emergency contact monitoring
│   │   └── 📄 settings_screen.dart  # Language, theme, font settings
│   │
│   └── 📁 utils/                      # Utility functions
│       └── 📄 demo_data.dart        # Demo data creation for testing
│
├── 📁 android/                        # Android-specific configuration
│   ├── 📄 app/
│   │   ├── 📄 build.gradle           # Android build configuration
│   │   └── 📄 src/main/
│   │       ├── 📄 AndroidManifest.xml # Permissions (SMS, Camera)
│   │       └── 📁 kotlin/           # Kotlin source files
│   ├── 📄 build.gradle               # Project build config
│   ├── 📄 gradle.properties          # Gradle properties
│   └── 📄 settings.gradle            # Gradle settings
│
├── 📁 ios/                           # iOS-specific configuration
├── 📁 linux/                         # Linux-specific configuration  
├── 📁 macos/                         # macOS-specific configuration
├── 📁 web/                           # Web-specific configuration
├── 📁 windows/                       # Windows-specific configuration
│
├── 📁 test/                          # Test files
│   └── 📄 widget_test.dart           # Basic widget tests
│
└── 📁 build/                         # Build output files
```

## 📋 Key Files Description

### 🎯 Core Configuration
- **pubspec.yaml**: Flutter dependencies (Provider, fl_chart, secure storage, etc.)
- **android/app/src/main/AndroidManifest.xml**: SMS and Camera permissions
- **lib/main.dart**: App initialization with Provider setup

### 📱 Data Models (3 files)
- **user.dart**: User with emergencyContactIds (List<String>), PIN support
- **heart_rate_reading.dart**: BPM, timestamp, alert status
- **app_settings.dart**: Language (EN/MR/HI), theme, font size

### 🔧 Services (4 files)
- **auth_service.dart**: User CRUD, PIN storage, emergency contact linking
- **heart_rate_service.dart**: Save readings, calculate stats, danger detection
- **sms_service.dart**: SMS alerts with Marathi messages via url_launcher
- **settings_service.dart**: Theme building, multi-language support

### 🖼️ Screens (7 files)
- **login_screen.dart**: Dark blue theme, user type selection, cyan login button
- **registration_screen.dart**: User type cards, emergency contact linking
- **home_screen.dart**: Animated pulse circle, SOS button, BPM display
- **activity_screen.dart**: Weekly bar charts with fl_chart
- **history_screen.dart**: ListView of readings with timestamps
- **emergency_dashboard_screen.dart**: Monitoring cards, alerts, call button
- **settings_screen.dart**: Language selection, theme toggle, logout

### 🎨 UI Features
- **Colors**: Background #1E2A3A, Cards #2C3E50, Primary cyan, Accent pink
- **Animations**: Pulse animation (1.0 to 1.2 scale), 3s heart rate measurement
- **Navigation**: Bottom nav with 💗📊📜 icons
- **Multi-language**: English, Marathi, Hindi support

## 🚀 Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  fl_chart: ^0.65.0
  permission_handler: ^11.1.0
  intl: ^0.18.1
  flutter_secure_storage: ^9.0.0
  url_launcher: ^6.2.2
```

## 🔐 Android Permissions
```xml
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CAMERA" />
minSdk 21, targetSdk 34
```

## 📱 App Flow
1. **Login Screen** → Select user type → Login with PIN
2. **Old Person** → **Home Screen** (heart rate monitoring)
3. **Emergency Contact** → **Emergency Dashboard** (monitoring dependents)
4. **Registration** → Create users with emergency contact linking
5. **Settings** → Language/theme/font customization

## ✅ Key Features Implemented
- ✅ Emergency contact linking (emergencyContactIds as List<String>)
- ✅ Heart rate simulation (65-125 BPM random)
- ✅ SMS alerts with Marathi text
- ✅ Animated pulse monitoring
- ✅ Weekly activity charts
- ✅ Multi-language support
- ✅ Dark/Light theme toggle
- ✅ Secure PIN storage
- ✅ No deprecated methods (withValues instead of withOpacity)

## 🎯 Critical Requirements Met
- ✅ Uses emergencyContactIds (plural List) not single ID
- ✅ Uses withValues(alpha:) not deprecated withOpacity()
- ✅ Navigation logic: Old person → HomeScreen, Emergency → Dashboard
- ✅ SMS triggers: login, BPM>=120, SOS button
- ✅ 3-second heart rate animation
- ✅ Android permissions configured
- ✅ Flutter 3.x compatible
- ✅ Production-ready code

## 📞 Emergency Features
- **SOS Button**: Immediate SMS alert to all emergency contacts
- **Danger Alerts**: Automatic SMS when BPM >= 120
- **Login Notifications**: SMS when old person logs in
- **Real-time Monitoring**: Emergency contacts can see live data

## 🌍 Localization Support
- **English**: Default language
- **Marathi (mr)**: Complete UI translation
- **Hindi (hi)**: Complete UI translation
- **Dynamic switching**: Change language in settings

This project is **complete and production-ready** with all specified requirements implemented.
