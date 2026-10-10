# DATSURŌ — Modular Flutter starter

## Structure

```text
lib/
├── main.dart
├── app/
│   └── datsuro_shell.dart
├── core/
│   ├── notifications/datsuro_notifications.dart
│   ├── storage/datsuro_store.dart
│   └── theme/app_colors.dart
├── models/
│   └── local_state.dart
├── features/
│   ├── home/home_screen.dart
│   ├── grassdex/grassdex_screen.dart
│   ├── diary/daily_memory_screen.dart
│   ├── diary/diary_screen.dart
│   └── settings/settings_screen.dart
└── widgets/
    ├── glass_card.dart
    └── glass_navigation.dart
```

Each feature screen is in its own file. Shared state, theme constants, notification scheduling, reusable UI and navigation are separated from screen code.

## Run

```bash
flutter doctor
flutter pub get
flutter run
```

## Important limitations

This is a modular starter, not a production-ready release:
- Background geofencing is not implemented. The home map is a local illustration.
- The current home location action saves current coordinates but does not monitor 50 m boundary crossings.
- Home-day status is conservative; manual confirmation is only a prototype.
- The storage layer currently uses SharedPreferences JSON. Migrate structured records to Drift/SQLite before long-term production use.
- ZIP import currently replaces the local profile and requires more robust transactional validation before use with irreplaceable data.
- Notification scheduling uses the timezone package; configure the device-local timezone explicitly and test scheduling on both platforms.
- App lock, true native Liquid Glass materials, quiet-hours enforcement and a legally reviewed privacy policy are not implemented.
- Add platform permissions for camera, photo picker, location and notifications as required by the target OS. Do not request background location until the native feature is implemented.

The project intentionally has no app-owned backend. Exported backups can contain private photos, diary notes and home coordinates, so users must protect them.
