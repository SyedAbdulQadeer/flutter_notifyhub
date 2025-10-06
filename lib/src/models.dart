/// Model classes for Firebase Notification Handler Android Package
///
/// This file contains all the data models used throughout the notification
/// handling system. These models provide type safety and structure for
/// API requests and responses.
///
/// Developed by: Syed Abdul Qadeer
/// Company: AlwariDev
/// Website: https://alwaridev.tech

import 'dart:convert';

/// Request model for sending Firebase notifications
///
/// This class encapsulates all the data required to send a notification
/// through the Firebase Cloud Messaging service. It provides serialization
/// methods for API communication.
///
/// Used internally by the notification handler to structure requests
/// to the AlwariDev notification service.
class NotificationRequest {
  /// Encrypted Firebase service account configuration
  /// This contains the encrypted JSON credentials needed for Firebase API access
  final String firebaseConfig;

  /// Target device's FCM token
  /// Unique identifier for the device/app installation that will receive the notification
  final String token;

  /// Notification title
  /// The main heading text that appears in the notification
  final String title;

  /// Notification body
  /// The detailed message content that appears below the title
  final String body;

  /// Optional custom data payload
  /// Additional key-value pairs that can be used for deep linking,
  /// custom actions, or passing app-specific information
  final Map<String, dynamic>? data;

  /// Creates a new notification request
  ///
  /// All parameters except [data] are required for a valid notification.
  /// The [data] parameter is optional and can contain any JSON-serializable
  /// key-value pairs for custom functionality.
  NotificationRequest({
    required this.firebaseConfig,
    required this.token,
    required this.title,
    required this.body,
    this.data,
  });

  /// Converts the notification request to a JSON map
  ///
  /// This method serializes the request object for transmission to the
  /// notification service API. The data payload is JSON-encoded if present.
  ///
  /// Returns a Map<String, dynamic> suitable for HTTP request bodies.
  Map<String, dynamic> toJson() {
    final json = {
      'firebaseConfig': firebaseConfig,
      'token': token,
      'title': title,
      'body': body,
    };
    if (data != null && data!.isNotEmpty) {
      json['data'] = jsonEncode(data!);
    }
    return json;
  }
}

/// Response model for notification sending operations
///
/// This class represents the response received from the notification service
/// after attempting to send a notification. It contains success status,
/// delivery information, and error details when applicable.
///
/// Used to provide detailed feedback to the application about notification
/// delivery attempts and their outcomes.
class NotificationResponse {
  /// Indicates whether the notification was successfully sent
  /// true: Notification was accepted by Firebase and queued for delivery
  /// false: Notification failed due to validation, authentication, or service errors
  final bool success;

  /// Unique message identifier assigned by Firebase
  /// This ID can be used for tracking delivery status and analytics.
  /// Only available when success is true.
  final String? messageId;

  /// Total time taken to process the notification request
  /// Includes encryption, API communication, and Firebase processing time.
  /// Useful for performance monitoring and debugging.
  final String? duration;

  /// Error message when notification sending fails
  /// Contains detailed information about what went wrong, such as:
  /// - Invalid FCM token format
  /// - Authentication failures
  /// - Service unavailability
  /// - Validation errors
  final String? error;

  /// Timestamp when the response was generated
  /// ISO 8601 formatted timestamp indicating when the notification
  /// processing completed on the server side.
  final String? timestamp;

  /// Creates a new notification response
  ///
  /// The [success] parameter is required to indicate the operation outcome.
  /// Other parameters are optional and depend on the specific result.
  NotificationResponse({
    required this.success,
    this.messageId,
    this.duration,
    this.error,
    this.timestamp,
  });

  /// Creates a NotificationResponse from a JSON map
  ///
  /// This factory constructor parses the API response from the notification
  /// service and creates a structured response object. It handles missing
  /// fields gracefully with null defaults.
  ///
  /// Parameters:
  /// - [json]: The JSON response from the notification service API
  ///
  /// Returns a properly structured NotificationResponse object.
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      messageId: json['data']?['messageId'],
      duration: json['data']?['totalDuration'],
      error: json['error'],
      timestamp: json['timestamp'],
    );
  }
}

/// Response model for service health check operations
///
/// This class represents the response from the notification service health
/// endpoint. It provides information about service availability, performance,
/// and operational status.
///
/// Used for monitoring service uptime and diagnosing connectivity issues
/// before attempting to send critical notifications.
class HealthResponse {
  /// Indicates whether the notification service is operational
  /// true: Service is healthy and ready to process notifications
  /// false: Service is experiencing issues or is unavailable
  final bool success;

  /// Human-readable status message
  /// Provides additional context about the service state, such as:
  /// - "Service is healthy and operational"
  /// - "Service is experiencing high load"
  /// - "Service is temporarily unavailable"
  final String? message;

  /// Additional diagnostic data
  /// May contain service metrics, version information, or other
  /// operational details useful for debugging and monitoring.
  /// Structure varies based on service implementation.
  final Map<String, dynamic>? data;

  /// Timestamp when the health check was performed
  /// ISO 8601 formatted timestamp indicating when the service
  /// status was last verified.
  final String? timestamp;

  /// Creates a new health response
  ///
  /// The [success] parameter is required to indicate service status.
  /// Other parameters provide additional context and diagnostic information.
  HealthResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  /// Creates a HealthResponse from a JSON map
  ///
  /// This factory constructor parses the API response from the health
  /// check endpoint and creates a structured response object.
  ///
  /// Parameters:
  /// - [json]: The JSON response from the health check API
  ///
  /// Returns a properly structured HealthResponse object.
  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      timestamp: json['timestamp'],
    );
  }
}
