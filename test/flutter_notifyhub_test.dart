import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_notifyhub/flutter_notifyhub.dart';

void main() {
  group('AlwariDevNotificationService Tests', () {
    late AlwariDevNotificationService service;

    setUp(() {
      AlwariDevNotificationService.resetInstance();
      service = AlwariDevNotificationService();
    });

    test('should create singleton instance', () {
      final service1 = AlwariDevNotificationService();
      final service2 = AlwariDevNotificationService();
      expect(identical(service1, service2), isTrue);
    });

    test('should validate FCM token correctly', () {
      final validToken = 'c' * 152; // Valid length token
      final invalidShortToken = 'short';
      final invalidLongToken = 'a' * 1001; // Too long

      expect(service.validateFCMToken(validToken), isTrue);
      expect(service.validateFCMToken(invalidShortToken), isFalse);
      expect(service.validateFCMToken(invalidLongToken), isFalse);
    });

    test('should validate notification content correctly', () {
      expect(service.validateNotification('Valid Title', 'Valid body'), isTrue);
      expect(service.validateNotification('', 'Valid body'), isFalse);
      expect(service.validateNotification('Valid Title', ''), isFalse);
      expect(service.validateNotification('a' * 101, 'Valid body'), isFalse);
      expect(service.validateNotification('Valid Title', 'a' * 1001), isFalse);
    });

    test('should return error for invalid FCM token', () async {
      final serviceAccount = {
        'type': 'service_account',
        'project_id': 'test-project',
        'private_key': 'test-key',
        'client_email': 'test@test.com',
      };

      final result = await service.sendNotification(
        serviceAccount: serviceAccount,
        fcmToken: 'invalid_token',
        title: 'Test Title',
        body: 'Test Body',
      );

      expect(result.success, isFalse);
      expect(result.error, 'Invalid FCM token');
    });

    test('should return error for invalid notification content', () async {
      final serviceAccount = {
        'type': 'service_account',
        'project_id': 'test-project',
        'private_key': 'test-key',
        'client_email': 'test@test.com',
      };

      final validToken = 'c' * 152;

      final result = await service.sendNotification(
        serviceAccount: serviceAccount,
        fcmToken: validToken,
        title: '',
        body: 'Test Body',
      );

      expect(result.success, isFalse);
      expect(result.error, 'Invalid notification content');
    });
  });

  group('EncryptionService Tests', () {
    test('should encrypt and decrypt service account correctly', () {
      final encryptionService = EncryptionService();
      final serviceAccount = {
        'type': 'service_account',
        'project_id': 'test-project',
        'private_key': 'test-key',
        'client_email': 'test@test.com',
      };
      final secretKey = 'test_secret_key_32_characters_long';

      final encrypted = encryptionService.encryptServiceAccount(
        serviceAccount,
        secretKey,
      );
      final decrypted = encryptionService.decryptServiceAccount(
        encrypted,
        secretKey,
      );

      expect(decrypted, equals(serviceAccount));
    });
  });
}
