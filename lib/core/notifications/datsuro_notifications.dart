import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../i18n/app_strings.dart';

class DatsuroNotifications {
  DatsuroNotifications._();
  static final instance = DatsuroNotifications._();
  final plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  Future<void> initialize() =>
      _initialization ??= _initialize().catchError((Object error) {
        _initialization = null;
        throw error;
      });

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local));
    } catch (_) {
      // Fall back to timezone package default if device timezone lookup fails.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await plugin
        .initialize(const InitializationSettings(android: android, iOS: ios));
  }

  Future<void> requestPermission() async {
    await initialize();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDailyReminder({
    required bool enabled,
    required int hour,
    required int minute,
    required bool skipToday,
  }) async {
    await initialize();
    const id = 1001;
    await plugin.cancel(id);
    if (!enabled) return;
    // Daily time-based scheduling is used; exact-time delivery remains OS-dependent.
    final now = DateTime.now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (skipToday || !first.isAfter(now)) {
      first = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    await plugin.zonedSchedule(
      id,
      AppStrings.tr('A little memory for future-you'),
      AppStrings.tr(
          "Psst. Today's memory is waiting. Give future-you one photo to remember."),
      _nextInstance(first),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'datsuro_diary',
          AppStrings.tr('Daily diary reminder'),
          channelDescription:
              AppStrings.tr('A reminder to save today’s photo diary entry.'),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleIntervention({
    required bool enabled,
    required int days,
    required DateTime? lastEscape,
  }) async {
    await initialize();
    const id = 1002;
    await plugin.cancel(id);
    if (!enabled || lastEscape == null) return;
    final at = lastEscape.add(Duration(days: days));
    if (!at.isAfter(DateTime.now())) return;
    await plugin.zonedSchedule(
      id,
      AppStrings.tr('Your grass misses you'),
      AppStrings.tr(
          'The outside world has submitted a formal request for your presence.'),
      _nextInstance(at),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'datsuro_intervention',
          AppStrings.tr('Touch grass intervention'),
          channelDescription:
              AppStrings.tr('Funny nudges after a long indoor streak.'),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstance(DateTime date) =>
      tz.TZDateTime.from(date, tz.local);
}
