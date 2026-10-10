import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/local_state.dart';
import '../stamps/stamp_catalog.dart';
import '../i18n/app_strings.dart';
import '../notifications/datsuro_notifications.dart';
import '../theme/app_colors.dart';

class DatsuroStore extends ChangeNotifier {
  DatsuroStore._();
  static final instance = DatsuroStore._();
  static const legalVersion = 2;
  LocalState state = LocalState();
  bool loaded = false;

  bool get hasAcceptedCurrentLegal =>
      state.privacyAcceptedVersion == legalVersion &&
      state.termsAcceptedVersion == legalVersion;

  Future<void> acceptCurrentLegal() async {
    final oldPrivacyVersion = state.privacyAcceptedVersion;
    final oldTermsVersion = state.termsAcceptedVersion;
    state.privacyAcceptedVersion = legalVersion;
    state.termsAcceptedVersion = legalVersion;
    try {
      await save();
    } catch (_) {
      state.privacyAcceptedVersion = oldPrivacyVersion;
      state.termsAcceptedVersion = oldTermsVersion;
      rethrow;
    }
  }

  Future<void> saveUsername(String value) async {
    final username = value.trim();
    if (username.isEmpty || username.runes.length > 32) {
      throw const FormatException(
          'Choose a username between 1 and 32 characters.');
    }
    final oldUsername = state.username;
    final oldUsernameSet = state.usernameSet;
    state.username = username;
    state.usernameSet = true;
    try {
      await save();
    } catch (_) {
      state.username = oldUsername;
      state.usernameSet = oldUsernameSet;
      rethrow;
    }
  }

  Future<void> setLanguageCode(String value) async {
    if (!const {'en', 'ja', 'ko', 'zh'}.contains(value)) return;
    final previous = state.languageCode;
    final previousStringsLanguage = AppStrings.languageCode;
    state.languageCode = value;
    AppStrings.languageCode = value;
    try {
      await save();
    } catch (_) {
      state.languageCode = previous;
      AppStrings.languageCode = previousStringsLanguage;
      rethrow;
    }
  }

  Future<void> setPermissionOnboardingDone() async {
    state.permissionOnboardingDone = true;
    await save();
  }

  Future<void> setTrackingEnabled(bool enabled) async {
    final previous = state.trackingEnabled;
    final previousStamps = List<Map<String, dynamic>>.from(state.stamps);
    state.trackingEnabled = enabled;
    try {
      if (enabled) {
        await _awardEarnedStamps(
            'tracking-${DateTime.now().millisecondsSinceEpoch}');
      }
      await save();
    } catch (_) {
      state.trackingEnabled = previous;
      state.stamps = previousStamps;
      rethrow;
    }
  }

  void updateTrackingStatus(bool? insideRadius) {
    if (state.trackingInsideRadius == insideRadius) return;
    state.trackingInsideRadius = insideRadius;
    notifyListeners();
  }

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    var storedLanguage = false;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        storedLanguage =
            const {'en', 'ja', 'ko', 'zh'}.contains(decoded['languageCode']);
        state = LocalState.fromJson(decoded);
      } catch (_) {
        // Keep a safe default if a local state file is malformed.
      }
    }
    if (!storedLanguage) {
      state.languageCode =
          switch (PlatformDispatcher.instance.locale.languageCode) {
        'ja' => 'ja',
        'ko' => 'ko',
        'zh' => 'zh',
        _ => 'en',
      };
    }
    loaded = true;
    notifyListeners();
    unawaited(_rescheduleNotifications());
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(prefsKey, jsonEncode(state.toJson()))) {
      throw StateError('Could not save local profile data.');
    }
    await _rescheduleNotifications();
    notifyListeners();
  }

  String todayKey([DateTime? date]) =>
      DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  Map<String, dynamic>? entryFor(DateTime date) {
    final key = todayKey(date);
    for (final e in state.entries) {
      if (e['date'] == key) return e;
    }
    return null;
  }

  DateTime? get lastEscape {
    DateTime? latest;
    for (final e in state.escapes) {
      final dt = DateTime.tryParse('${e['timestamp'] ?? ''}');
      if (dt != null && (latest == null || dt.isAfter(latest))) latest = dt;
    }
    return latest;
  }

  int get currentIndoorDays {
    final homeDays = _confirmedHomeDays;
    final today = DateTime.now();
    var day = DateTime(today.year, today.month, today.day);
    if (state.escapes.any((event) {
      final timestamp = DateTime.tryParse('${event['timestamp'] ?? ''}');
      return timestamp != null && todayKey(timestamp) == todayKey(day);
    })) {
      return 0;
    }
    if (!homeDays.contains(todayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (homeDays.contains(todayKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestIndoorStreak {
    // Only recorded home days count. Unknown days are never inferred as home days.
    final days = _confirmedHomeDays;
    var best = 0;
    var run = 0;
    DateTime? prev;
    final sorted = days.map(DateTime.tryParse).whereType<DateTime>().toList()
      ..sort();
    for (final d in sorted) {
      if (prev != null && d.difference(prev).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  Set<String> get _confirmedHomeDays {
    final escapeDays = state.escapes
        .map((e) {
          final date = DateTime.tryParse('${e['timestamp'] ?? ''}');
          return date == null ? null : todayKey(date);
        })
        .whereType<String>()
        .toSet();
    return state.manualHomeDays
        .where((e) => e['confirmed'] == true && e['date'] is String)
        .map((e) => e['date'] as String)
        .where((date) =>
            DateTime.tryParse(date) != null && !escapeDays.contains(date))
        .toSet();
  }

  int get totalEscapeDays {
    return state.escapes
        .map((e) {
          final dt = DateTime.tryParse('${e['timestamp'] ?? ''}');
          return dt == null ? null : todayKey(dt);
        })
        .whereType<String>()
        .toSet()
        .length;
  }

  Future<void> saveDiary(
      {required String photoPath, required String note}) async {
    final key = todayKey();
    if (entryFor(DateTime.now()) != null) {
      throw StateError("Today's memory has already been saved.");
    }
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/datsuro_photos');
    await photoDir.create(recursive: true);
    final source = File(photoPath);
    if (!await source.exists()) {
      throw FileSystemException('Selected photo is unavailable.', photoPath);
    }
    final filename = source.uri.pathSegments.last;
    final dot = filename.lastIndexOf('.');
    final candidate = dot < 0 ? '' : filename.substring(dot + 1).toLowerCase();
    final ext = const {'jpg', 'jpeg', 'png', 'heic', 'webp'}.contains(candidate)
        ? candidate
        : 'jpg';
    final dest = File('${photoDir.path}/$key.$ext');
    await source.copy(dest.path);
    final previousStamps = List<Map<String, dynamic>>.from(state.stamps);
    final entry = {
      'id': 'diary-$key',
      'date': key,
      'photo': dest.path,
      'note': note.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    state.entries.add(entry);
    try {
      await _awardEarnedStamps('diary-$key');
      await save();
    } catch (_) {
      state.entries.remove(entry);
      state.stamps = previousStamps;
      if (await dest.exists()) await dest.delete();
      rethrow;
    }
  }

  Future<void> recordEscape({
    required String method,
    String? countryCode,
  }) async {
    final now = DateTime.now();
    final previousEscapes = List<Map<String, dynamic>>.from(state.escapes);
    final previousStamps = List<Map<String, dynamic>>.from(state.stamps);
    final previousCountries = List<String>.from(state.visitedCountryCodes);
    final previousHomeDays =
        List<Map<String, dynamic>>.from(state.manualHomeDays);
    final id = 'escape-${now.millisecondsSinceEpoch}';
    state.escapes.add({
      'id': id,
      'timestamp': now.toIso8601String(),
      'method': method,
    });
    if (countryCode != null && RegExp(r'^[A-Z]{2}$').hasMatch(countryCode)) {
      if (!state.visitedCountryCodes.contains(countryCode)) {
        state.visitedCountryCodes.add(countryCode);
      }
      await _awardStamp('country_$countryCode', 'Explore $countryCode', id);
    }
    final key = todayKey(now);
    state.manualHomeDays.removeWhere((day) => day['date'] == key);
    try {
      await _awardEarnedStamps(id);
      await save();
    } catch (_) {
      state.escapes = previousEscapes;
      state.stamps = previousStamps;
      state.visitedCountryCodes = previousCountries;
      state.manualHomeDays = previousHomeDays;
      rethrow;
    }
  }

  Future<void> recordCountryVisit(String countryCode) async {
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(countryCode) ||
        state.visitedCountryCodes.contains(countryCode)) {
      return;
    }
    final previousStamps = List<Map<String, dynamic>>.from(state.stamps);
    state.visitedCountryCodes.add(countryCode);
    final eventId = 'country-${DateTime.now().millisecondsSinceEpoch}';
    try {
      await _awardStamp('country_$countryCode', 'Visit $countryCode', eventId);
      await _awardEarnedStamps(eventId);
      await save();
    } catch (_) {
      state.visitedCountryCodes.remove(countryCode);
      state.stamps = previousStamps;
      rethrow;
    }
  }

  Future<void> _awardEarnedStamps(String eventId) async {
    for (final stampId in StampCatalog.earnedIds(state)) {
      if (state.stamps.any((stamp) => stamp['id'] == stampId)) continue;
      final definition =
          StampCatalog.core.firstWhere((stamp) => stamp.id == stampId);
      await _awardStamp(stampId, definition.name, eventId);
    }
  }

  Future<void> _awardStamp(String id, String name, String eventId) async {
    if (state.stamps.any((s) => s['id'] == id)) return;
    state.stamps.add({
      'id': id,
      'name': name,
      'earnedAt': DateTime.now().toIso8601String(),
      'eventId': eventId,
    });
  }

  Future<void> confirmHomeDay() async {
    final key = todayKey();
    if (state.escapes.any((event) {
      final timestamp = DateTime.tryParse('${event['timestamp'] ?? ''}');
      return timestamp != null && todayKey(timestamp) == key;
    })) {
      throw StateError(
          'An escape was recorded today, so this cannot be marked as a home day.');
    }
    if (!state.manualHomeDays.any((e) => e['date'] == key)) {
      state.manualHomeDays.add({
        'date': key,
        'confirmed': true,
        'method': 'manual',
        'recordedAt': DateTime.now().toIso8601String(),
      });
    }
    await save();
  }

  Future<void> setHomeFromCurrentLocation() async {
    final previousLatitude = state.homeLat;
    final previousLongitude = state.homeLon;
    final previousStamps = List<Map<String, dynamic>>.from(state.stamps);
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw StateError('Location services are disabled.');
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission was not granted.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    state.homeLat = pos.latitude;
    state.homeLon = pos.longitude;
    try {
      await _awardEarnedStamps('home-${DateTime.now().millisecondsSinceEpoch}');
      await save();
    } catch (_) {
      state.homeLat = previousLatitude;
      state.homeLon = previousLongitude;
      state.stamps = previousStamps;
      rethrow;
    }
  }

  Future<void> _rescheduleNotifications() async {
    if (!loaded) return;
    try {
      await DatsuroNotifications.instance.scheduleDailyReminder(
        enabled: state.diaryReminderEnabled,
        hour: state.reminderHour,
        minute: state.reminderMinute,
        skipToday: entryFor(DateTime.now()) != null,
      );
      await DatsuroNotifications.instance.scheduleIntervention(
        enabled: state.interventionEnabled,
        days: state.interventionDays,
        lastEscape: lastEscape,
      );
    } catch (error) {
      debugPrint('Could not update local notifications: $error');
    }
  }

  Future<File> exportBackup() async {
    final archive = Archive();
    final data = utf8.encode(jsonEncode(state.toJson()));
    archive.addFile(ArchiveFile('profile.json', data.length, data));
    final photoPaths =
        state.entries.map((e) => e['photo']).whereType<String>().toSet();
    for (final path in photoPaths) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(
            'photos/${file.uri.pathSegments.last}', bytes.length, bytes));
      }
    }
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) throw StateError('Could not create backup archive.');
    final temp = await getTemporaryDirectory();
    final file = File(
        '${temp.path}/datsuro-backup-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.zip');
    await file.writeAsBytes(zipBytes, flush: true);
    return file;
  }

  Future<void> importBackup(String path) async {
    final bytes = await File(path).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final profile = archive.findFile('profile.json');
    if (profile == null) {
      throw const FormatException('This is not a DATSURŌ backup.');
    }
    final raw = utf8.decode(profile.content as List<int>);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
      throw const FormatException(
          'This backup uses an unsupported profile format.');
    }
    final imported = LocalState.fromJson(decoded);
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/datsuro_photos');
    await photoDir.create(recursive: true);

    // Copy photos from the archive before committing the imported profile.
    final copied = <String, String>{};
    final copiedFiles = <File>[];
    for (final file in archive.files) {
      if (!file.isFile || !file.name.startsWith('photos/')) continue;
      final name = file.name.replaceAll('\\', '/').split('/').last;
      if (name.isEmpty || name == '.' || name == '..') {
        throw const FormatException(
            'Backup contains an invalid photo filename.');
      }
      final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      if (copied.containsKey(name)) {
        throw FormatException('Backup contains duplicate photo: $name');
      }
      final dest = File('${photoDir.path}/imported_$safeName');
      await dest.writeAsBytes(file.content as List<int>, flush: true);
      copiedFiles.add(dest);
      copied[name] = dest.path;
    }
    for (final entry in imported.entries) {
      final old = entry['photo'] as String?;
      if (old == null) continue;
      final name = old.replaceAll('\\', '/').split('/').last;
      if (copied.containsKey(name)) entry['photo'] = copied[name];
      // Missing images remain referenced but are displayed as unavailable.
    }
    final previous = state;
    state = imported;
    try {
      await save();
    } catch (_) {
      state = previous;
      for (final file in copiedFiles) {
        if (await file.exists()) await file.delete();
      }
      rethrow;
    }
  }

  Future<void> deleteAllData() async {
    state = LocalState();
    await save();
    final dir = await getApplicationDocumentsDirectory();
    final photos = Directory('${dir.path}/datsuro_photos');
    if (await photos.exists()) await photos.delete(recursive: true);
  }
}
