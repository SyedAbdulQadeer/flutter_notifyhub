import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static EncryptionService? _instance;

  EncryptionService._internal();

  factory EncryptionService() {
    _instance ??= EncryptionService._internal();
    return _instance!;
  }

  String encryptServiceAccount(
    Map<String, dynamic> serviceAccount,
    String secretKey,
  ) {
    // Create a 32-byte key for AES-256
    final keyString = secretKey.padRight(32, '0').substring(0, 32);
    final keyBytes = utf8.encode(keyString);
    final iv = Uint8List(16);
    final key = Key(Uint8List.fromList(keyBytes));
    final ivObj = IV(iv);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final jsonString = jsonEncode(serviceAccount);
    final encrypted = encrypter.encrypt(jsonString, iv: ivObj);
    return encrypted.base64;
  }

  Map<String, dynamic> decryptServiceAccount(
    String encryptedData,
    String secretKey,
  ) {
    // Create a 32-byte key for AES-256 (same as encrypt method)
    final keyString = secretKey.padRight(32, '0').substring(0, 32);
    final keyBytes = utf8.encode(keyString);
    final iv = Uint8List(16);
    final key = Key(Uint8List.fromList(keyBytes));
    final ivObj = IV(iv);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(encryptedData);
    final decrypted = encrypter.decrypt(encrypted, iv: ivObj);
    return jsonDecode(decrypted);
  }
}
