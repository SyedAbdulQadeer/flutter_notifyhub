import 'dart:convert';
import 'package:http/http.dart' as http;
import 'encryption_service.dart';
import 'models.dart';

class FirebaseNotificationHandler {
  static FirebaseNotificationHandler? _instance;
  final EncryptionService _encryptionService;

  FirebaseNotificationHandler._internal()
    : _encryptionService = EncryptionService();

  factory FirebaseNotificationHandler() {
    _instance ??= FirebaseNotificationHandler._internal();
    return _instance!;
  }

  Future<NotificationResponse> sendNotification({
    required String baseUrl,
    required Map<String, dynamic> serviceAccount,
    required String secretKey,
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final encryptedConfig = _encryptionService.encryptServiceAccount(
        serviceAccount,
        secretKey,
      );

      final request = NotificationRequest(
        firebaseConfig: encryptedConfig,
        token: fcmToken,
        title: title,
        body: body,
        data: data,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(responseData);
      } else {
        return NotificationResponse(
          success: false,
          error: responseData['error'] ?? 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return NotificationResponse(success: false, error: e.toString());
    }
  }

  Future<HealthResponse> checkHealth(String baseUrl) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return HealthResponse.fromJson(responseData);
      } else {
        return HealthResponse(
          success: false,
          message: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return HealthResponse(success: false, message: e.toString());
    }
  }

  Future<List<NotificationResponse>> sendBatchNotifications({
    required String baseUrl,
    required Map<String, dynamic> serviceAccount,
    required String secretKey,
    required List<Map<String, String>> notifications,
  }) async {
    final responses = <NotificationResponse>[];

    for (final notification in notifications) {
      final response = await sendNotification(
        baseUrl: baseUrl,
        serviceAccount: serviceAccount,
        secretKey: secretKey,
        fcmToken: notification['token']!,
        title: notification['title']!,
        body: notification['body']!,
      );
      responses.add(response);
    }

    return responses;
  }

  bool validateFCMToken(String token) {
    return token.isNotEmpty && token.length > 50 && token.length < 1000;
  }

  bool validateNotification(String title, String body) {
    return title.isNotEmpty &&
        title.length <= 100 &&
        body.isNotEmpty &&
        body.length <= 1000;
  }
}
