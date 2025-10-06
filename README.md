# Flutter NotifyHub 🔔

[![pub package](https://img.shields.io/pub/v/flutter_notifyhub.svg)](https://pub.dev/packages/flutter_notifyhub)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/SyedAbdulQadeer/flutter_notifyhub)](https://github.com/SyedAbdulQadeer/flutter_notifyhub/issues)

<div align="center">
  <img src="https://i.ibb.co/GQTdgdMG/alwari-logo-dark.png" alt="AlwariDev Logo" width="200"/>
</div>

A powerful and secure Flutter package for handling Firebase Cloud Messaging (FCM) notifications with advanced features like encryption, batch sending, and seamless integration.

**Developed by:** Syed Abdul Qadeer  
**Company:** [AlwariDev](https://alwaridev.tech)  
**Website:** [https://alwaridev.tech](https://alwaridev.tech)

## ✨ Features

- � **Easy Integration** - Simple setup with minimal configuration
- 🔐 **Secure Transmission** - AES-256-CBC encryption for service accounts
- 📱 **Cross-Platform** - Works on both Android and iOS
- 📦 **Batch Notifications** - Send to multiple devices efficiently
- 🎯 **Topic Management** - Subscribe/unsubscribe from notification topics
- � **Robust Validation** - Built-in FCM token and content validation
- 📊 **Health Monitoring** - Service health checks and diagnostics
- � **Token Management** - Automatic token refresh handling
- 📝 **Comprehensive Logging** - Detailed success and error reporting

## 🚀 Quick Start

### 1. Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_notifyhub: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 2. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the project
3. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place the files in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 3. Generate Service Account

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file securely - you'll need its contents

### 4. Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notifyhub/flutter_notifyhub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize AlwariDev Notification Service
  await AlwariDevNotificationService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Demo',
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = AlwariDevNotificationService();
  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    _getDeviceToken();
    _setupTokenRefreshListener();
  }

  Future<void> _getDeviceToken() async {
    final token = await _notificationService.getDeviceToken();
    setState(() {
      _deviceToken = token;
    });
    print('Device FCM Token: $token');
  }

  void _setupTokenRefreshListener() {
    _notificationService.onTokenRefresh((newToken) {
      setState(() {
        _deviceToken = newToken;
      });
      print('Token refreshed: $newToken');
      // Update your server with the new token
    });
  }

  Future<void> _sendNotification() async {
    if (_deviceToken == null) return;

    // Your Firebase service account JSON
    final serviceAccount = {
      "type": "service_account",
      "project_id": "your-project-id",
      "private_key_id": "your-private-key-id",
      "private_key": "-----BEGIN PRIVATE KEY-----\\nYOUR_PRIVATE_KEY\\n-----END PRIVATE KEY-----\\n",
      "client_email": "firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com",
      "client_id": "your-client-id",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project-id.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    final response = await _notificationService.sendNotification(
      serviceAccount: serviceAccount,
      fcmToken: _deviceToken!,
      title: 'Hello from AlwariDev! 👋',
      body: 'This is a test notification from Firebase Notification Handler',
      data: {
        'action': 'open_screen',
        'screen': 'home',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    if (response.success) {
      print('✅ Notification sent successfully!');
      print('Message ID: ${response.messageId}');
    } else {
      print('❌ Failed to send notification: ${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _deviceToken ?? 'Loading...',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📋 Advanced Usage

### Batch Notifications

Send notifications to multiple devices efficiently:

```dart
final responses = await _notificationService.sendBatchNotifications(
  serviceAccount: serviceAccountJson,
  notifications: [
    {
      'token': 'device_token_1',
      'title': 'Welcome!',
      'body': 'Thanks for joining our app!'
    },
    {
      'token': 'device_token_2',
      'title': 'Special Offer',
      'body': 'Get 50% off your next purchase!'
    },
  ],
  commonData: {
    'campaign': 'welcome_series',
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
  },
);

// Process results
for (int i = 0; i < responses.length; i++) {
  if (responses[i].success) {
    print('Notification $i sent successfully');
  } else {
    print('Notification $i failed: ${responses[i].error}');
  }
}
```

### Topic Management

Manage notification topics for targeted messaging:

```dart
// Subscribe to topics
await _notificationService.subscribeToTopic('breaking_news');
await _notificationService.subscribeToTopic('sports_updates');

// Unsubscribe from topics
await _notificationService.unsubscribeFromTopic('sports_updates');
```

### Service Health Monitoring

Check if the notification service is operational:

```dart
final health = await _notificationService.checkServiceHealth();
if (health.success) {
  print('✅ Service is healthy!');
  print('Response time: ${health.data?['responseTime']}ms');
} else {
  print('❌ Service is down: ${health.message}');
}
```

### Input Validation

Validate tokens and content before sending:

```dart
// Validate FCM token
if (_notificationService.validateFCMToken(token)) {
  print('✅ Token format is valid');
} else {
  print('❌ Invalid token format');
}

// Validate notification content
if (_notificationService.validateNotification(title, body)) {
  print('✅ Content is valid');
} else {
  print('❌ Invalid content');
}
```

## 🔧 Configuration

### Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Firebase Messaging permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <!-- Notification permission for Android 13+ -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your activities here -->
        
    </application>
</manifest>
```

Update `android/app/build.gradle`:

```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 23
        targetSdk 34
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Your existing configuration -->
    
    <!-- Firebase messaging background modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
</dict>
```

## 🔒 Security Features

- **AES-256-CBC Encryption**: Service account credentials are encrypted before transmission
- **Secure Token Validation**: FCM tokens are validated for format and structure
- **Content Sanitization**: Notification content is validated and sanitized
- **HTTPS Communication**: All API calls use secure HTTPS connections

## 🧪 Testing

Run the example app to test functionality:

```bash
cd example
flutter run
```

The example includes:
- Device token display
- Test notification sending
- Service health checking
- Token refresh monitoring

## 📝 API Reference

### AlwariDevNotificationService

#### Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `initialize()` | Initialize the service | None | `Future<void>` |
| `getDeviceToken()` | Get FCM token | None | `Future<String?>` |
| `sendNotification()` | Send single notification | `serviceAccount`, `fcmToken`, `title`, `body`, `data?` | `Future<NotificationResponse>` |
| `sendBatchNotifications()` | Send multiple notifications | `serviceAccount`, `notifications`, `commonData?` | `Future<List<NotificationResponse>>` |
| `checkServiceHealth()` | Check service status | None | `Future<HealthResponse>` |
| `subscribeToTopic()` | Subscribe to topic | `topic` | `Future<void>` |
| `unsubscribeFromTopic()` | Unsubscribe from topic | `topic` | `Future<void>` |
| `onTokenRefresh()` | Listen for token changes | `callback` | `void` |
| `validateFCMToken()` | Validate token format | `token` | `bool` |
| `validateNotification()` | Validate content | `title`, `body` | `bool` |

## 🐛 Troubleshooting

### Common Issues

1. **"Service account not found"**
   - Ensure your service account JSON is complete and valid
   - Check that the project ID matches your Firebase project

2. **"Invalid FCM token"**
   - Make sure Firebase is properly initialized
   - Verify the device has Google Play Services (Android)
   - Check internet connectivity

3. **"Permission denied"**
   - Ensure notification permissions are granted
   - Check Firebase project permissions

4. **"Service unavailable"**
   - Check your internet connection
   - Verify service health with `checkServiceHealth()`

### Debug Mode

Enable debug logging to see detailed information:

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug information will be shown in console');
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Syed Abdul Qadeer - AlwariDev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🔗 Links

- **GitHub Repository**: [https://github.com/SyedAbdulQadeer/flutter_notifyhub](https://github.com/SyedAbdulQadeer/flutter_notifyhub)
- **Issue Tracker**: [https://github.com/SyedAbdulQadeer/flutter_notifyhub/issues](https://github.com/SyedAbdulQadeer/flutter_notifyhub/issues)
- **Company Website**: [https://alwaridev.tech](https://alwaridev.tech)
- **Pub.dev Package**: [flutter_notifyhub](https://pub.dev/packages/flutter_notifyhub)

## 💡 Support

- 📧 **Email**: support@alwaridev.tech
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/SyedAbdulQadeer/flutter_notifyhub/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/SyedAbdulQadeer/flutter_notifyhub/discussions)

---

<div align="center">
  <p>Made with ❤️ by <a href="https://alwaridev.tech">AlwariDev</a></p>
  <p>Developed by Syed Abdul Qadeer</p>
</div>
