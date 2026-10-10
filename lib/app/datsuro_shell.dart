import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../core/storage/datsuro_store.dart';
import '../features/home/home_screen.dart';
import '../features/grassdex/grassdex_screen.dart';
import '../features/diary/daily_memory_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/glass_navigation.dart';
import '../core/i18n/app_strings.dart';
import '../core/location/datsuro_location_tracker.dart';

class DatsuroShell extends StatefulWidget {
  const DatsuroShell({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;
  @override
  State<DatsuroShell> createState() => _DatsuroShellState();
}

class _DatsuroShellState extends State<DatsuroShell>
    with WidgetsBindingObserver {
  final store = DatsuroStore.instance;
  int tab = 0;
  bool busy = true;
  bool openingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.addListener(_refresh);
    store.load().then((_) {
      if (mounted) setState(() => busy = false);
      _syncTracking();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    _syncTracking();
    if (mounted) setState(() {});
  }

  void _syncTracking() {
    if (store.state.trackingEnabled) {
      unawaited(DatsuroLocationTracker.instance.start());
    } else {
      unawaited(DatsuroLocationTracker.instance.stop());
    }
  }

  Future<void> _openCamera() async {
    if (openingCamera) return;
    openingCamera = true;
    if (store.entryFor(DateTime.now()) != null) {
      _message("Today's memory is already sealed. See you tomorrow!");
      setState(() => tab = 3);
      openingCamera = false;
      return;
    }
    try {
      final result = await Navigator.of(context).push<Map<String, String>>(
        MaterialPageRoute(builder: (_) => const DailyMemoryScreen()),
      );
      if (result != null && mounted && result['photo'] != null) {
        await store.saveDiary(
            photoPath: result['photo']!, note: result['note'] ?? '');
        setState(() => tab = 3);
        _message('Memory saved. Future-you says thanks.');
      }
    } catch (e) {
      _message('Could not save memory: $e');
    } finally {
      openingCamera = false;
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final pages = [
      HomeScreen(
        onOpenDiary: () => setState(() => tab = 3),
        onOpenGrassdex: () => setState(() => tab = 1),
      ),
      const GrassdexScreen(),
      const SizedBox.shrink(),
      const DiaryScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('脱籠',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25)),
          Text(
            '${store.state.username} · ${[
              'YOUR ESCAPE QUEST',
              'YOUR COLLECTION',
              'DAILY MEMORY',
              'YOUR TIMELINE',
              'YOUR SETTINGS'
            ].map(AppStrings.tr).toList()[tab]}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(letterSpacing: 1.2),
          ),
        ]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => setState(() => tab = 4),
            icon: const Icon(CupertinoIcons.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: tab == 2 ? 0 : tab, children: pages),
      bottomNavigationBar: GlassNavigation(
        selected: tab,
        onSelect: (i) {
          if (i == 2) {
            _openCamera();
          } else {
            setState(() => tab = i);
          }
        },
      ),
    );
  }
}
