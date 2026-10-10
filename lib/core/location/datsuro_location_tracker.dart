import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../i18n/app_strings.dart';
import '../storage/datsuro_store.dart';

/// Monitors transitions across the configured home radius while the Android
/// foreground service notification is visible.
class DatsuroLocationTracker {
  DatsuroLocationTracker._();
  static final instance = DatsuroLocationTracker._();
  final geocoding = Geocoding();

  StreamSubscription<Position>? _subscription;
  bool? _inside;
  bool _recordingTransition = false;
  DateTime? _lastCountryCheck;

  Future<bool> requestBackgroundPermission() async {
    var foreground = await Permission.locationWhenInUse.status;
    if (!foreground.isGranted) {
      foreground = await Permission.locationWhenInUse.request();
    }
    if (!foreground.isGranted) return false;
    var background = await Permission.locationAlways.status;
    if (!background.isGranted) {
      background = await Permission.locationAlways.request();
    }
    return background.isGranted;
  }

  Future<void> start() async {
    final store = DatsuroStore.instance;
    if (_subscription != null ||
        !store.state.trackingEnabled ||
        store.state.homeLat == null ||
        store.state.homeLon == null) {
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) return;
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return;
    }
    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 30,
            intervalDuration: const Duration(minutes: 2),
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: AppStrings.tr('DATSURŌ location tracking'),
              notificationText: AppStrings.tr(
                  'Monitoring your home radius. Only escape events are saved.'),
              enableWakeLock: false,
              setOngoing: true,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.medium, distanceFilter: 30);
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: (_) => stop());
  }

  Future<void> _onPosition(Position position) async {
    final store = DatsuroStore.instance;
    final lat = store.state.homeLat;
    final lon = store.state.homeLon;
    if (lat == null ||
        lon == null ||
        position.accuracy > 100 ||
        _recordingTransition) {
      return;
    }
    final distance = Geolocator.distanceBetween(
        lat, lon, position.latitude, position.longitude);
    final wasInside = _inside;
    final inside = wasInside == null
        ? distance <= store.state.radius
        : wasInside
            ? distance <= store.state.radius + 20
            : distance < store.state.radius - 20;
    _inside = inside;
    store.updateTrackingStatus(inside);
    final exited = wasInside == true && !inside;
    final dueCountryCheck = _lastCountryCheck == null ||
        DateTime.now().difference(_lastCountryCheck!) >=
            const Duration(minutes: 30);
    if (!inside && (exited || dueCountryCheck)) {
      _recordingTransition = true;
      try {
        _lastCountryCheck = DateTime.now();
        String? countryCode;
        try {
          final marks = await geocoding.placemarkFromCoordinates(
              position.latitude, position.longitude);
          if (marks.isNotEmpty) {
            countryCode = marks.first.isoCountryCode?.toUpperCase();
          }
        } catch (_) {
          // Country awards are optional; escape detection must work without geocoding.
        }
        if (exited) {
          await store.recordEscape(
              method: 'background_location', countryCode: countryCode);
        } else if (countryCode != null) {
          await store.recordCountryVisit(countryCode);
        }
      } finally {
        _recordingTransition = false;
      }
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _inside = null;
    _lastCountryCheck = null;
    DatsuroStore.instance.updateTrackingStatus(null);
  }
}
