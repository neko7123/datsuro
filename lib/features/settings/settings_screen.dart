import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/legal/app_legal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/datsuro_store.dart';
import '../../core/notifications/datsuro_notifications.dart';
import '../../core/location/datsuro_location_tracker.dart';
import '../../core/i18n/app_strings.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final store = DatsuroStore.instance;
    final s = store.state;
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          Text(AppStrings.tr('Settings'),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          Text(AppStrings.tr('Make DATSURŌ yours.'),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _settingsGroup(context, 'PROFILE', [
            ListTile(
              leading: const Icon(CupertinoIcons.person_crop_circle),
              title: Text(AppStrings.tr('Username')),
              subtitle: Text(s.username),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () async {
                final value = await showDialog<String>(
                    context: context,
                    builder: (_) => _UsernameEditDialog(initial: s.username));
                if (value != null && value.isNotEmpty) {
                  try {
                    await store.saveUsername(value);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'HOME & TRACKING', [
            ListTile(
              leading: const Icon(CupertinoIcons.location),
              title: Text(AppStrings.tr('Home location')),
              subtitle: Text(AppStrings.tr(s.homeLat == null
                  ? 'Not configured'
                  : 'Saved on this device')),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () async {
                try {
                  await store.setHomeFromCurrentLocation();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppStrings.tr('Home location saved.'))));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.scope),
              title: Text(AppStrings.tr('Escape radius')),
              subtitle: Text('${s.radius} metres'),
              trailing: SizedBox(
                  width: 120,
                  child: Slider(
                      value: s.radius.toDouble(),
                      min: 30,
                      max: 150,
                      divisions: 12,
                      label: '${s.radius} m',
                      onChanged: (v) async {
                        s.radius = v.round();
                        await store.save();
                      })),
            ),
            SwitchListTile(
              secondary: const Icon(CupertinoIcons.location_circle),
              title: Text(AppStrings.tr('Background location tracking')),
              subtitle: Text(s.trackingEnabled
                  ? 'Active while the system location service is available.'
                  : 'Requires a saved home location and background location permission.'),
              value: s.trackingEnabled,
              onChanged: (enabled) async {
                try {
                  if (enabled) {
                    if (s.homeLat == null) {
                      await store.setHomeFromCurrentLocation();
                    }
                    if (!await DatsuroLocationTracker.instance
                        .requestBackgroundPermission()) {
                      throw StateError(
                          'Allow location access in system settings to enable background tracking.');
                    }
                  }
                  await store.setTrackingEnabled(enabled);
                  if (!enabled) await DatsuroLocationTracker.instance.stop();
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$error')));
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'NOTIFICATIONS', [
            SwitchListTile(
              secondary: const Icon(CupertinoIcons.book),
              title: Text(AppStrings.tr('Daily diary reminder')),
              subtitle: Text(AppStrings.tr('Reminder at your chosen time')),
              value: s.diaryReminderEnabled,
              onChanged: (v) async {
                s.diaryReminderEnabled = v;
                if (v) await DatsuroNotifications.instance.requestPermission();
                await store.save();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.clock),
              title: Text(AppStrings.tr('Reminder time')),
              subtitle: Text(
                  TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute)
                      .format(context)),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () async {
                final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: s.reminderHour, minute: s.reminderMinute));
                if (picked != null) {
                  s.reminderHour = picked.hour;
                  s.reminderMinute = picked.minute;
                  await store.save();
                }
              },
            ),
            SwitchListTile(
              secondary: const Icon(CupertinoIcons.leaf_arrow_circlepath),
              title: Text(AppStrings.tr('Touch-grass intervention')),
              subtitle: const Text(
                  'Funny reminder after the configured indoor streak'),
              value: s.interventionEnabled,
              onChanged: (v) async {
                s.interventionEnabled = v;
                await store.save();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.calendar),
              title: Text(AppStrings.tr('Intervention threshold')),
              subtitle: Text('${s.interventionDays} consecutive days'),
              trailing: DropdownButton<int>(
                value: s.interventionDays,
                items: [2, 3, 4, 5, 7]
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text('$d days')))
                    .toList(),
                onChanged: (v) async {
                  if (v != null) {
                    s.interventionDays = v;
                    await store.save();
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'APPEARANCE', [
            SwitchListTile(
              secondary: const Icon(CupertinoIcons.moon_stars),
              title: Text(AppStrings.tr('Dark mode')),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: onThemeChanged,
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'LANGUAGE', [
            ListTile(
              leading: const Icon(CupertinoIcons.globe),
              title: Text(AppStrings.tr('Language')),
              trailing: DropdownButton<String>(
                value: s.languageCode,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                  DropdownMenuItem(value: 'zh', child: Text('简体中文')),
                ],
                onChanged: (value) {
                  if (value != null) store.setLanguageCode(value);
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'BACKUP & RESTORE', [
            ListTile(
              leading: const Icon(CupertinoIcons.archivebox),
              title: Text(AppStrings.tr('Export profile')),
              subtitle: const Text(
                  'Create a ZIP containing local records and available diary photos'),
              onTap: () async {
                try {
                  final file = await store.exportBackup();
                  await Share.shareXFiles([XFile(file.path)],
                      text: 'DATSURŌ local profile backup');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')));
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.arrow_down_doc),
              title: Text(AppStrings.tr('Import profile')),
              subtitle:
                  Text(AppStrings.tr('Restore from a DATSURŌ ZIP backup')),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['zip'],
                    withData: false);
                final path = result?.files.single.path;
                if (path == null || !context.mounted) return;
                final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text(AppStrings.tr('Replace local profile?')),
                          content: Text(AppStrings.tr(
                              'This prototype replaces your current local profile with the imported backup. Export your current data first if you need it.')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(AppStrings.tr('Cancel'))),
                            FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(AppStrings.tr('Replace profile'))),
                          ],
                        ));
                if (!context.mounted) return;
                if (confirmed != true) return;
                try {
                  await store.importBackup(path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppStrings.tr('Profile restored.'))));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Import failed: $e')));
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'PRIVACY & SECURITY', [
            ListTile(
              leading: const Icon(CupertinoIcons.lock),
              title: Text(AppStrings.tr('Privacy Policy')),
              subtitle: Text(
                  AppStrings.tr('How this build stores and uses local data')),
              onTap: () => _showLegalDocument(context, 'Privacy Policy',
                  AppLegal.privacyPolicy(s.languageCode)),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.doc_text),
              title: Text(AppStrings.tr('Terms of Use')),
              subtitle: Text(AppStrings.tr('The terms accepted during setup')),
              onTap: () => _showLegalDocument(
                  context, 'Terms of Use', AppLegal.termsOfUse(s.languageCode)),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash, color: coral),
              title: Text(AppStrings.tr('Delete all local data'),
                  style: const TextStyle(color: coral)),
              subtitle: const Text(
                  'Permanently remove this profile and diary from this app'),
              onTap: () async {
                final yes = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text(AppStrings.tr('Delete all local data?')),
                          content: Text(AppStrings.tr(
                              'This removes your local profile, entries, stamps and tracking history. Export a backup first if you want to keep them.')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(AppStrings.tr('Cancel'))),
                            FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child:
                                    Text(AppStrings.tr('Delete everything'))),
                          ],
                        ));
                if (yes == true) {
                  await store.deleteAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppStrings.tr('Local data deleted.'))));
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 12),
          _settingsGroup(context, 'ABOUT', [
            const ListTile(
              leading: Icon(CupertinoIcons.info_circle),
              title: Text('DATSURŌ'),
              subtitle: Text('脱籠 · Version 1.0.0 · Local-first starter build'),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.link),
              title: const Text('Made by Neko'),
              subtitle: const Text('github.com/neko7123'),
              trailing: const Icon(CupertinoIcons.arrow_up_right),
              onTap: () async {
                final uri = Uri.parse('https://github.com/neko7123');
                final opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open GitHub.')),
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 24),
          Center(
              child: Text(
                  'No account. No app-owned server. Just you and the outside world.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall)),
        ]);
  }

  Widget _settingsGroup(
      BuildContext context, String label, List<Widget> children) {
    return GlassCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.tr(label),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.1, fontWeight: FontWeight.w800)))),
          ...children,
        ]));
  }

  void _showLegalDocument(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content.trim())),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.tr('Close')))
        ],
      ),
    );
  }
}

class _UsernameEditDialog extends StatefulWidget {
  const _UsernameEditDialog({required this.initial});
  final String initial;
  @override
  State<_UsernameEditDialog> createState() => _UsernameEditDialogState();
}

class _UsernameEditDialogState extends State<_UsernameEditDialog> {
  late final controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppStrings.tr('Choose a username')),
        content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 32,
            decoration: const InputDecoration(hintText: 'Your local nickname')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.tr('Cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(AppStrings.tr('Save'))),
        ],
      );
}
