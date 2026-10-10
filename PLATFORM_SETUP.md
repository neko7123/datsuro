# Platform setup checklist

## iOS
- Camera and photo library usage descriptions in Info.plist.
- Location usage description for current-location home setup.
- Notification permission flow.
- Background location capability only after native geofencing has been implemented and tested.
- Test on a physical device; simulator results are not sufficient for location validation.

## Android
- Camera/photo picker behavior and location permissions.
- Notification runtime permission on supported Android versions.
- Add background geofencing permissions only with the actual implementation.
- Test battery optimization, app force-stop, permission revocation and reboot behavior.

## Release requirements
- Replace the privacy summary with a legally reviewed policy.
- Verify app icon and mascot rights.
- Pin package versions and run `flutter analyze` and tests.
- Test export/import and document backup contents.
