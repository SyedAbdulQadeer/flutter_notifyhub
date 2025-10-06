import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notifyhub/flutter_notifyhub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase first
  await Firebase.initializeApp();

  // Initialize the notification service
  await AlwariDevNotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Notification Handler Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  State<NotificationDemo> createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  late AlwariDevNotificationService _notificationService;
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _status = 'Ready to send notifications';
  bool _isLoading = false;
  bool _serviceHealthy = false;

  // Replace this with your actual Firebase service account JSON
  final Map<String, dynamic> _serviceAccount = {
    "type": "service_account",
    "project_id": "my-awesome-project",
    "private_key_id": "1a2b3c4d5e6f7g8h9i0j123456789abcd",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhki...fakekeycontent...IDAQAB\n-----END PRIVATE KEY-----\n",
    "client_email":
        "my-service-account@my-awesome-project.iam.gserviceaccount.com",
    "client_id": "123456789012345678901",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/my-service-account%40my-awesome-project.iam.gserviceaccount.com",
  };

  @override
  void initState() {
    super.initState();
    _initializeService();
    _setDefaultValues();
  }

  void _initializeService() {
    _notificationService = AlwariDevNotificationService();
    _checkServiceHealth();
  }

  void _setDefaultValues() async {
    // Get the device token using the new API
    final token = await _notificationService.getDeviceToken();
    _tokenController.text = token ?? "";
    _titleController.text = 'Hello from AlwariDev!';
    _bodyController.text =
        'This is a test notification from the Flutter package.';
  }

  Future<void> _checkServiceHealth() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking service health...';
    });

    try {
      final health = await _notificationService.checkServiceHealth();
      setState(() {
        _serviceHealthy = health.success;
        _status = health.success
            ? 'Service is healthy ✅'
            : 'Service unavailable ❌';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _serviceHealthy = false;
        _status = 'Health check failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty ||
        _bodyController.text.isEmpty ||
        _tokenController.text.isEmpty) {
      setState(() {
        _status = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Sending notification...';
    });

    try {
      final result = await _notificationService.sendNotification(
        serviceAccount: _serviceAccount,
        fcmToken: _tokenController.text,
        title: _titleController.text,
        body: _bodyController.text,
      );

      setState(() {
        if (result.success) {
          _status =
              'Notification sent successfully! ✅\nMessage ID: ${result.messageId}';
        } else {
          _status = 'Failed to send notification ❌\nError: ${result.error}';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Notification Handler Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _serviceHealthy ? Icons.check_circle : Icons.error,
                          color: _serviceHealthy ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Backend Service Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _checkServiceHealth,
                          child: const Text('Check'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Replace the serviceAccount JSON with your Firebase service account\n'
                      '2. The FCM token is automatically loaded from your device\n'
                      '3. Backend URL and secret are pre-configured - no setup needed!\n'
                      '4. Just customize the title and body, then send!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Notification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'FCM Token (Auto-loaded)',
                        border: OutlineInputBorder(),
                        helperText: 'Device token automatically retrieved',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendNotification,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Notification'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Card
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
