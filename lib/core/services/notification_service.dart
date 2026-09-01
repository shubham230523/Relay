import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    // Basic platform support check for flutter_local_notifications
    final bool isSupported = kIsWeb || 
        Platform.isAndroid || 
        Platform.isIOS || 
        Platform.isMacOS || 
        Platform.isLinux;

    if (!isSupported) {
      debugPrint('Notification Service: Current platform is not supported by the plugin.');
      _isInitialized = false;
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    try {
      final bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );
      _isInitialized = initialized ?? false;
    } catch (e) {
      debugPrint('Notification Service failed to initialize: $e');
      _isInitialized = false;
    }

    if (_isInitialized && !kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      debugPrint('Notification Service not initialized. Skipping notification: $title');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'relay_channel_id',
      'Relay Automations',
      channelDescription: 'Notifications for Relay automation steps',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
      linux: LinuxNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(id, title, body, platformDetails);
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }
}
