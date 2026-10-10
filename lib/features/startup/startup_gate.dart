import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/legal/app_legal.dart';
import '../../core/storage/datsuro_store.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../app/datsuro_shell.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/notifications/datsuro_notifications.dart';
import '../../core/location/datsuro_location_tracker.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key, required this.onThemeChanged});

  final ValueChanged<bool> onThemeChanged;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  final store = DatsuroStore.instance;
  bool usernamePromptScheduled = false;
  bool permissionPromptScheduled = false;
  Object? loadError;

  @override
  void initState() {
    super.initState();
    if (!store.loaded) _load();
  }

  Future<void> _load() async {
    try {
      await store.load();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => loadError = error);
    }
  }

  void _scheduleUsernamePrompt() {
    if (usernamePromptScheduled) return;
    usernamePromptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _UsernamePrompt(store: store),
      );
      if (mounted) {
        setState(() => usernamePromptScheduled = false);
      }
    });
  }

  void _schedulePermissionPrompt() {
    if (permissionPromptScheduled) return;
    permissionPromptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final allow = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.tr('Before you begin')),
          content: Text(AppStrings.tr('permission_rationale')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.tr('Not now'))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppStrings.tr('Allow permissions'))),
          ],
        ),
      );
      if (allow == true) {
        try {
          await Permission.locationWhenInUse.request();
          await DatsuroLocationTracker.instance.requestBackgroundPermission();
          await DatsuroNotifications.instance.requestPermission();
        } catch (_) {
          // The app remains usable when optional system permissions are denied.
        }
      }
      await store.setPermissionOnboardingDone();
      if (mounted) setState(() => permissionPromptScheduled = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DATSURŌ could not load its local profile.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() => loadError = null);
                    _load();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (!store.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!store.hasAcceptedCurrentLegal) {
      return StartupConsentScreen(
        onAccept: () async {
          await store.acceptCurrentLegal();
          if (mounted) setState(() {});
        },
      );
    }
    if (!store.state.usernameSet) {
      _scheduleUsernamePrompt();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!store.state.permissionOnboardingDone) {
      _schedulePermissionPrompt();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DatsuroShell(onThemeChanged: widget.onThemeChanged);
  }
}

class StartupConsentScreen extends StatefulWidget {
  const StartupConsentScreen({super.key, required this.onAccept});

  final Future<void> Function() onAccept;

  @override
  State<StartupConsentScreen> createState() => _StartupConsentScreenState();
}

class _StartupConsentScreenState extends State<StartupConsentScreen> {
  bool agreed = false;
  bool saving = false;
  String? error;

  Future<void> _accept() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.onAccept();
    } catch (e) {
      if (mounted) setState(() => error = 'Could not save your agreement: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppStrings.tr('Before you begin'))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              AppStrings.tr('Your data stays in your hands.'),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
                'Please review the ${AppStrings.tr('Privacy Policy')} and ${AppStrings.tr('Terms of Use')} before using 脱籠.'),
            const SizedBox(height: 16),
            _LegalSection(
                title: '${AppStrings.tr('Privacy Policy')} · Version 2',
                body: AppLegal.privacyPolicy(
                    DatsuroStore.instance.state.languageCode)),
            const SizedBox(height: 12),
            _LegalSection(
                title: '${AppStrings.tr('Terms of Use')} · Version 2',
                body: AppLegal.termsOfUse(
                    DatsuroStore.instance.state.languageCode)),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: agreed,
              onChanged: saving
                  ? null
                  : (value) => setState(() => agreed = value ?? false),
              title: Text(
                  'I have read the ${AppStrings.tr('Privacy Policy')} and ${AppStrings.tr('Terms of Use')}, and I agree to the ${AppStrings.tr('Terms of Use')}.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: agreed && !saving ? _accept : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                    saving ? 'Saving…' : AppStrings.tr('Agree and continue')),
              ),
            ),
          ],
        ),
      );
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body.trim()),
          ],
        ),
      );
}

class _UsernamePrompt extends StatefulWidget {
  const _UsernamePrompt({required this.store});

  final DatsuroStore store;

  @override
  State<_UsernamePrompt> createState() => _UsernamePromptState();
}

class _UsernamePromptState extends State<_UsernamePrompt> {
  final controller = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.store.saveUsername(controller.text);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(CupertinoIcons.person_crop_circle, color: sprout),
          title: Text(AppStrings.tr('Choose your username')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'This name appears across DATSURŌ. You can change it later in Settings.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 32,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Your username'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) async {
                  if (!saving) await _save();
                },
              ),
              if (error != null)
                Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed:
                  saving || controller.text.trim().isEmpty ? null : _save,
              child: Text(saving ? 'Saving…' : AppStrings.tr('Save username')),
            ),
          ],
        ),
      );
}
