import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../data/event.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final timezoneInfo =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.identifier),
    );

    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: settings);

    _initialized = true;
  }

  int notificationId(String eventId) {
    // Generate the same notification ID for the same event.
    int hash = 0x811c9dc5;

    for (final code in eventId.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }

  Future<void> scheduleEvent(Event event) async {
    await initialize();

    if (!event.time.isAfter(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id: notificationId(event.id),
      title: 'FurMate Reminder 🐾',
      body: 'Time for ${event.petName}: ${event.type}',
      scheduledDate: tz.TZDateTime.from(
        event.time,
        tz.local,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'furmate_events',
          'Pet Care Reminders',
          channelDescription: 'Reminders for pet care events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelEvent(String eventId) async {
    await initialize();

    await _plugin.cancel(
      id: notificationId(eventId),
    );
  }

  Future<void> cancelAllEvents() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<bool> requestPermission() async {
    await initialize();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final granted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }
  // Notification methods go here.
  Future<void> updateNotificationPreference(bool isEnabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'notificationsEnabled': isEnabled,
        }, SetOptions(merge: true));
        debugPrint('Notification preference updated: $isEnabled');
    } catch (e, stackTrace) {
      debugPrint('Notification preference error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  Future<void> syncEventNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final preference = await userRef.get();
    final enabled =
        preference.data()?['notificationsEnabled'] == true;

    await cancelAllEvents();

    if (!enabled) return;

    final eventSnapshot = await userRef
        .collection('events')
        .get();

    for (final doc in eventSnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      final event = Event.fromMap(data);

      if (event.time.isAfter(DateTime.now())) {
        await scheduleEvent(event);
      }
    }
  }
}