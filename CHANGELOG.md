# Changelog

All notable changes to the Flutter NotifyHub package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-06

### Added
- 🚀 **Initial Release** - Complete Flutter NotifyHub package for Firebase notifications
- 🔐 **Secure Encryption** - AES-256-CBC encryption for Firebase service account credentials
- 🏭 **Singleton Pattern** - Factory pattern implementation ensuring single instance management
- 📱 **Cross-Platform Support** - Full compatibility with Android and iOS platforms
- ✅ **Input Validation** - Comprehensive validation for FCM tokens and notification content
- 📦 **Batch Notifications** - Efficient sending of multiple notifications to different devices
- 🎯 **Topic Management** - Subscribe and unsubscribe from Firebase notification topics
- 🏥 **Health Monitoring** - Backend service health checks and diagnostics
- 🔄 **Token Management** - Automatic FCM token refresh handling with callbacks
- 📊 **Detailed Logging** - Comprehensive success and error reporting with timestamps
- 🛡️ **Error Handling** - Robust error handling with detailed error messages
- 📝 **Rich Documentation** - Complete API documentation with examples and best practices
- 🧪 **Example App** - Full-featured example application demonstrating all features
- 🔗 **Deep Linking Support** - Custom data payload support for app navigation
- 🌍 **HTTPS Security** - All communications secured with HTTPS protocol

### Technical Features
- **Encryption Service**: Secure AES-256-CBC encryption for sensitive data
- **Firebase Manager**: Complete Firebase Cloud Messaging integration
- **Notification Handler**: Advanced notification processing and delivery
- **Model Classes**: Type-safe data models for requests and responses
- **Validation Engine**: Multi-layer validation for tokens and content
- **Background Processing**: Support for background notification handling

### Platform Support
- **Android**: Minimum SDK 23, optimized for Android 13+ notification permissions
- **iOS**: Full support with background processing capabilities
- **Flutter**: Compatible with Flutter 3.0+ and Dart 3.8+

### Dependencies
- `firebase_core: ^2.24.2` - Firebase core functionality
- `firebase_messaging: ^14.7.10` - Firebase Cloud Messaging
- `http: ^1.2.0` - HTTP client for API communication
- `crypto: ^3.0.3` - Cryptographic operations
- `encrypt: ^5.0.3` - Advanced encryption capabilities

### Developer Information
- **Author**: Syed Abdul Qadeer
- **Company**: AlwariDev
- **Website**: https://alwaridev.tech
- **Repository**: https://github.com/SyedAbdulQadeer/flutter_notifyhub
- **License**: MIT License

### Package Features
- Zero configuration setup with pre-configured backend
- Type-safe API with comprehensive error handling
- Built-in security with encrypted data transmission
- Performance optimized for high-volume notifications
- Memory efficient singleton implementation
- Extensive documentation and examples
- Community support and regular updates
- Batch notification sending capability
- Health check functionality for backend service monitoring
- Comprehensive error handling and validation
- Complete test suite with unit tests
- Detailed documentation and usage examples

### Features
- `AlwariDevNotificationService` main service class with singleton pattern
- `EncryptionService` for secure service account encryption/decryption
- `NotificationResponse` and `HealthResponse` models
- FCM token validation (50-1000 characters)
- Notification content validation (title: 1-100 chars, body: 1-1000 chars)
- HTTP client integration with proper error handling
- Backend health monitoring

### Security
- AES-256-CBC encryption for Firebase service account JSON
- Secret key based encryption/decryption
- No plain text storage of sensitive data
- HTTPS communication with backend service

### Developer Experience
- Comprehensive documentation with examples
- Type-safe API with proper error handling
- Easy initialization and usage
- Support for both single and batch notifications
- Built-in validation methods
