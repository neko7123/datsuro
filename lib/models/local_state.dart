class LocalState {
  String username = 'Indoor Creature';
  bool usernameSet = false;
  int? privacyAcceptedVersion;
  int? termsAcceptedVersion;
  String? photoPath;
  double? homeLat;
  double? homeLon;
  int radius = 50;
  bool trackingEnabled = false;
  bool? trackingInsideRadius;
  bool diaryReminderEnabled = true;
  bool interventionEnabled = true;
  bool quietHoursEnabled = true;
  int reminderHour = 21;
  int reminderMinute = 0;
  int interventionDays = 3;
  bool appLockEnabled = false;
  bool darkMode = false;
  String languageCode = 'en';
  bool permissionOnboardingDone = false;
  List<String> visitedCountryCodes = [];
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> escapes = [];
  List<Map<String, dynamic>> stamps = [];
  List<Map<String, dynamic>> manualHomeDays = [];

  Map<String, dynamic> toJson() => {
        'version': 1,
        'username': username,
        'usernameSet': usernameSet,
        'privacyAcceptedVersion': privacyAcceptedVersion,
        'termsAcceptedVersion': termsAcceptedVersion,
        'photoPath': photoPath,
        'homeLat': homeLat,
        'homeLon': homeLon,
        'radius': radius,
        'trackingEnabled': trackingEnabled,
        'diaryReminderEnabled': diaryReminderEnabled,
        'interventionEnabled': interventionEnabled,
        'quietHoursEnabled': quietHoursEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'interventionDays': interventionDays,
        'appLockEnabled': appLockEnabled,
        'darkMode': darkMode,
        'languageCode': languageCode,
        'permissionOnboardingDone': permissionOnboardingDone,
        'visitedCountryCodes': visitedCountryCodes,
        'entries': entries,
        'escapes': escapes,
        'stamps': stamps,
        'manualHomeDays': manualHomeDays,
      };

  static LocalState fromJson(Map<String, dynamic> j) {
    if (j['version'] is num && (j['version'] as num).toInt() != 1) {
      throw FormatException(
          'Unsupported DATSURŌ profile version: ${j['version']}');
    }
    final s = LocalState();
    s.username =
        j['username'] is String ? j['username'] as String : 'Indoor Creature';
    s.usernameSet = j['usernameSet'] == true ||
        (j['usernameSet'] == null &&
            s.username.trim().isNotEmpty &&
            s.username != 'Indoor Creature');
    s.privacyAcceptedVersion = j['privacyAcceptedVersion'] is num
        ? (j['privacyAcceptedVersion'] as num).toInt()
        : null;
    s.termsAcceptedVersion = j['termsAcceptedVersion'] is num
        ? (j['termsAcceptedVersion'] as num).toInt()
        : null;
    s.photoPath = j['photoPath'] is String ? j['photoPath'] as String : null;
    final latitude =
        j['homeLat'] is num ? (j['homeLat'] as num).toDouble() : null;
    final longitude =
        j['homeLon'] is num ? (j['homeLon'] as num).toDouble() : null;
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      s.homeLat = latitude;
      s.homeLon = longitude;
    }
    s.radius = (j['radius'] is num ? (j['radius'] as num).toInt() : 50)
        .clamp(30, 150)
        .toInt();
    s.trackingEnabled = j['trackingEnabled'] == true;
    s.diaryReminderEnabled = j['diaryReminderEnabled'] != false;
    s.interventionEnabled = j['interventionEnabled'] != false;
    s.quietHoursEnabled = j['quietHoursEnabled'] != false;
    s.reminderHour =
        (j['reminderHour'] is num ? (j['reminderHour'] as num).toInt() : 21)
            .clamp(0, 23)
            .toInt();
    s.reminderMinute =
        (j['reminderMinute'] is num ? (j['reminderMinute'] as num).toInt() : 0)
            .clamp(0, 59)
            .toInt();
    final days = j['interventionDays'] is num
        ? (j['interventionDays'] as num).toInt()
        : 3;
    s.interventionDays = [2, 3, 4, 5, 7].contains(days) ? days : 3;
    s.appLockEnabled = j['appLockEnabled'] == true;
    s.darkMode = j['darkMode'] == true;
    s.languageCode = const {'en', 'ja', 'ko', 'zh'}.contains(j['languageCode'])
        ? j['languageCode'] as String
        : 'en';
    s.permissionOnboardingDone = j['permissionOnboardingDone'] == true;
    s.visitedCountryCodes = (j['visitedCountryCodes'] is List
            ? (j['visitedCountryCodes'] as List).whereType<String>()
            : const <String>[])
        .where((code) => RegExp(r'^[A-Z]{2}$').hasMatch(code))
        .toSet()
        .toList();
    s.entries = _mapList(j['entries']);
    s.escapes = _mapList(j['escapes']);
    s.stamps = _mapList(j['stamps']);
    s.manualHomeDays = _mapList(j['manualHomeDays']);
    return s;
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.fromEntries(
              e.entries
                  .where((entry) => entry.key is String)
                  .map((entry) => MapEntry(entry.key as String, entry.value)),
            ))
        .toList();
  }
}
