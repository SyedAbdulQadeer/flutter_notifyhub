/// Flutter NotifyHub Package
///
/// A comprehensive Flutter package for handling Firebase Cloud Messaging (FCM)
/// notifications with advanced features like encryption, batch sending, and
/// seamless integration.
///
/// Developed by: Syed Abdul Qadeer
/// Company: AlwariDev
/// Website: https://alwaridev.tech
///
/// Features:
/// - Easy Firebase notification integration
/// - Secure message transmission with AES-256-CBC encryption
/// - Batch notification sending capabilities
/// - Automatic token management and refresh handling
/// - Topic subscription management
/// - Service health monitoring
/// - Cross-platform support (Android & iOS)
///
/// This package provides a simplified interface for sending Firebase notifications
/// without exposing complex backend configurations to the end user.
library;

import 'src/notification_handler.dart';
import 'src/models.dart';
import 'src/firebase_notification_manager.dart';

// Export models and services for external use
export 'src/models.dart';
export 'src/encryption_service.dart';

// The AlwariDevNotificationService class is defined in this file and automatically exported

/// Main service class for AlwariDev Firebase Notification Handler
///
/// This class implements the Singleton pattern to ensure only one instance
/// of the notification service exists throughout the application lifecycle.
/// It provides a simplified API for sending Firebase notifications with
/// built-in security and validation.
///
/// Example usage:
/// ```dart
/// // Initialize the service (call once in main())
/// await AlwariDevNotificationService().initialize();
///
/// // Send a notification
/// final result = await AlwariDevNotificationService().sendNotification(
///   serviceAccount: yourServiceAccountJson,
///   fcmToken: 'device_fcm_token',
///   title: 'Hello World',
///   body: 'This is a test notification',
/// );
/// ```
class AlwariDevNotificationService {
  // Singleton instance holder
  static AlwariDevNotificationService? _instance;

  // Pre-configured backend settings for AlwariDev notification service
  // These are fixed to ensure consistent behavior across all implementations
  static const String _baseUrl = 'https://notifyhub-eight.vercel.app';
  static const String _secretKey =
      'Bqa6qQyQ6c7kK6l+IHIwQ+gm1dOf/QG/VdDvpYdLTt4';

  // Core service components
  final FirebaseNotificationHandler _handler;
  final FirebaseNotificationManager _firebaseManager;

  /// Private constructor for singleton implementation
  /// Initializes the core notification handler and Firebase manager
  AlwariDevNotificationService._internal()
    : _handler = FirebaseNotificationHandler(),
      _firebaseManager = FirebaseNotificationManager();

  /// Factory constructor that implements the Singleton pattern
  /// Returns the same instance every time it's called
  ///
  /// This ensures that:
  /// - Only one notification service instance exists
  /// - Configuration is consistent across the app
  /// - Memory usage is optimized
  factory AlwariDevNotificationService() {
    _instance ??= AlwariDevNotificationService._internal();
    return _instance!;
  }

  /// Reset the singleton instance (mainly for testing purposes)
  /// Use with caution in production code
  static void resetInstance() {
    _instance = null;
  }

  /// Initialize the Firebase notification service
  ///
  /// This method MUST be called once in your app's main() function
  /// before using any notification features. It sets up:
  /// - Firebase Cloud Messaging integration
  /// - Token generation and management
  /// - Background message handling
  /// - Notification permission requests
  ///
  /// Example:
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await Firebase.initializeApp();
  ///   await AlwariDevNotificationService().initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize() async {
    await _firebaseManager.initialize();
  }

  /// Retrieve the current device's Firebase Cloud Messaging token
  ///
  /// This token uniquely identifies the device/app installation and is
  /// required for sending targeted notifications. The token can change
  /// when the app is updated, restored on a new device, or when app
  /// data is cleared.
  ///
  /// Returns:
  /// - String: The FCM token if successfully retrieved
  /// - null: If token generation fails or Firebase is not initialized
  ///
  /// Example:
  /// ```dart
  /// final token = await AlwariDevNotificationService().getDeviceToken();
  /// if (token != null) {
  ///   print('Device FCM Token: $token');
  ///   // Send token to your server for future notifications
  /// }
  /// ```
  Future<String?> getDeviceToken() async {
    return await _firebaseManager.getToken();
  }

  /// Send a Firebase notification to a specific device
  ///
  /// This is the primary method for sending notifications. It handles:
  /// - Input validation for FCM tokens and notification content
  /// - Secure transmission using AES-256-CBC encryption
  /// - Automatic retry logic for failed requests
  /// - Detailed response reporting
  ///
  /// Parameters:
  /// - [serviceAccount]: Firebase service account JSON (required)
  ///   Download from Firebase Console > Project Settings > Service Accounts
  /// - [fcmToken]: Target device's FCM token (required)
  /// - [title]: Notification title (required, max 200 characters)
  /// - [body]: Notification body text (required, max 1000 characters)
  /// - [data]: Optional custom data payload (Map&lt;String, dynamic&gt;)
  ///   Useful for deep linking, custom actions, or app state updates
  ///
  /// Returns:
  /// - [NotificationResponse]: Contains success status, message ID, or error details
  ///
  /// Example:
  /// ```dart
  /// final response = await AlwariDevNotificationService().sendNotification(
  ///   serviceAccount: {
  ///     "type": "service_account",
  ///     "project_id": "your-project-id",
  ///     // ... other service account fields
  ///   },
  ///   fcmToken: 'eXaMpLe_tOkEn_HeRe...',
  ///   title: 'Order Update',
  ///   body: 'Your order #12345 has been shipped!',
  ///   data: {
  ///     'orderId': '12345',
  ///     'action': 'view_order',
  ///     'url': 'myapp://orders/12345'
  ///   },
  /// );
  ///
  /// if (response.success) {
  ///   print('Notification sent! Message ID: ${response.messageId}');
  /// } else {
  ///   print('Failed to send: ${response.error}');
  /// }
  /// ```
  Future<NotificationResponse> sendNotification({
    required Map<String, dynamic> serviceAccount,
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Validate FCM token format before processing
    if (!validateFCMToken(fcmToken)) {
      return NotificationResponse(success: false, error: 'Invalid FCM token');
    }

    // Validate notification content before sending
    if (!validateNotification(title, body)) {
      return NotificationResponse(
        success: false,
        error: 'Invalid notification content',
      );
    }

    // Delegate to the handler with pre-configured settings
    return _handler.sendNotification(
      baseUrl: _baseUrl,
      serviceAccount: serviceAccount,
      secretKey: _secretKey,
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send notifications to multiple devices in batch
  ///
  /// This method is optimized for sending the same or different notifications
  /// to multiple devices efficiently. It validates all inputs before processing
  /// and provides detailed responses for each notification attempt.
  ///
  /// Features:
  /// - Input validation for all notifications before sending
  /// - Sequential processing to avoid rate limiting
  /// - Individual response tracking for each notification
  /// - Common data payload support for all notifications
  ///
  /// Parameters:
  /// - [serviceAccount]: Firebase service account JSON (required)
  /// - [notifications]: List of notification objects, each containing:
  ///   - 'token': FCM token of the target device
  ///   - 'title': Notification title
  ///   - 'body': Notification body text
  /// - [commonData]: Optional data payload applied to all notifications
  ///
  /// Returns:
  /// - List&lt;NotificationResponse&gt;: Response for each notification in order
  ///
  /// Example:
  /// ```dart
  /// final responses = await AlwariDevNotificationService().sendBatchNotifications(
  ///   serviceAccount: serviceAccountJson,
  ///   notifications: [
  ///     {
  ///       'token': 'token1...',
  ///       'title': 'Welcome!',
  ///       'body': 'Thanks for joining our app!'
  ///     },
  ///     {
  ///       'token': 'token2...',
  ///       'title': 'Special Offer',
  ///       'body': 'Get 50% off your next purchase!'
  ///     },
  ///   ],
  ///   commonData: {
  ///     'campaign': 'welcome_series',
  ///     'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
  ///   },
  /// );
  ///
  /// // Process results
  /// for (int i = 0; i < responses.length; i++) {
  ///   if (responses[i].success) {
  ///     print('Notification $i sent successfully');
  ///   } else {
  ///     print('Notification $i failed: ${responses[i].error}');
  ///   }
  /// }
  /// ```
  Future<List<NotificationResponse>> sendBatchNotifications({
    required Map<String, dynamic> serviceAccount,
    required List<Map<String, String>> notifications,
    Map<String, dynamic>? commonData,
  }) async {
    // Pre-validate all notifications to fail fast if any are invalid
    for (final notification in notifications) {
      if (!validateFCMToken(notification['token']!)) {
        throw Exception(
          'Invalid FCM token for notification: ${notification['title']}',
        );
      }
      if (!validateNotification(
        notification['title']!,
        notification['body']!,
      )) {
        throw Exception(
          'Invalid content for notification: ${notification['title']}',
        );
      }
    }

    // Process notifications sequentially
    final responses = <NotificationResponse>[];

    for (final notification in notifications) {
      final response = await sendNotification(
        serviceAccount: serviceAccount,
        fcmToken: notification['token']!,
        title: notification['title']!,
        body: notification['body']!,
        data: commonData,
      );
      responses.add(response);
    }

    return responses;
  }

  /// Check the health status of the AlwariDev notification service
  ///
  /// This method verifies that the backend notification service is
  /// operational and can handle requests. It's useful for:
  /// - Service monitoring and diagnostics
  /// - Pre-flight checks before sending important notifications
  /// - Troubleshooting connectivity issues
  ///
  /// Returns:
  /// - [HealthResponse]: Contains service status and response time
  ///
  /// Example:
  /// ```dart
  /// final health = await AlwariDevNotificationService().checkServiceHealth();
  /// if (health.success) {
  ///   print('Service is healthy! Response time: ${health.responseTime}ms');
  /// } else {
  ///   print('Service is down: ${health.error}');
  /// }
  /// ```
  Future<HealthResponse> checkServiceHealth() async {
    return _handler.checkHealth(_baseUrl);
  }

  /// Validate the format of an FCM token
  ///
  /// FCM tokens have specific format requirements. This method checks:
  /// - Token length (typically 140+ characters)
  /// - Character set (alphanumeric plus specific symbols)
  /// - Overall structure validity
  ///
  /// Parameters:
  /// - [token]: The FCM token string to validate
  ///
  /// Returns:
  /// - bool: true if token format is valid, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final token = await getDeviceToken();
  /// if (AlwariDevNotificationService().validateFCMToken(token)) {
  ///   print('Token format is valid');
  /// } else {
  ///   print('Invalid token format');
  /// }
  /// ```
  bool validateFCMToken(String token) {
    return _handler.validateFCMToken(token);
  }

  /// Validate notification title and body content
  ///
  /// Ensures notification content meets Firebase requirements:
  /// - Title: Non-empty, reasonable length
  /// - Body: Non-empty, within size limits
  /// - Character encoding compatibility
  ///
  /// Parameters:
  /// - [title]: Notification title to validate
  /// - [body]: Notification body to validate
  ///
  /// Returns:
  /// - bool: true if content is valid, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final isValid = AlwariDevNotificationService().validateNotification(
  ///   'My Title',
  ///   'My notification body text'
  /// );
  /// if (!isValid) {
  ///   print('Notification content is invalid');
  /// }
  /// ```
  bool validateNotification(String title, String body) {
    return _handler.validateNotification(title, body);
  }

  /// Subscribe the current device to a Firebase topic
  ///
  /// Topics allow you to send notifications to multiple devices that have
  /// subscribed to the same topic. This is useful for:
  /// - News categories (sports, technology, etc.)
  /// - User segments (premium users, beta testers)
  /// - Geographic regions (city-specific updates)
  ///
  /// Parameters:
  /// - [topic]: Topic name to subscribe to (alphanumeric and underscores only)
  ///
  /// Example:
  /// ```dart
  /// await AlwariDevNotificationService().subscribeToTopic('breaking_news');
  /// await AlwariDevNotificationService().subscribeToTopic('sports_updates');
  /// ```
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseManager.subscribeToTopic(topic);
  }

  /// Unsubscribe the current device from a Firebase topic
  ///
  /// Removes the device from the specified topic, stopping future
  /// topic-based notifications from being delivered to this device.
  ///
  /// Parameters:
  /// - [topic]: Topic name to unsubscribe from
  ///
  /// Example:
  /// ```dart
  /// await AlwariDevNotificationService().unsubscribeFromTopic('sports_updates');
  /// ```
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseManager.unsubscribeFromTopic(topic);
  }

  /// Set up a callback for FCM token refresh events
  ///
  /// FCM tokens can change due to app updates, device restoration,
  /// or other system events. This callback allows you to capture
  /// the new token and update your server records.
  ///
  /// Parameters:
  /// - [callback]: Function to call when token refreshes
  ///   Receives the new token as a String parameter
  ///
  /// Example:
  /// ```dart
  /// AlwariDevNotificationService().onTokenRefresh((newToken) {
  ///   print('Token refreshed: $newToken');
  ///   // Send new token to your server
  ///   updateTokenOnServer(newToken);
  /// });
  /// ```
  void onTokenRefresh(Function(String) callback) {
    _firebaseManager.onTokenRefresh(callback);
  }
}
