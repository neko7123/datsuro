import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/datsuro_store.dart';
import '../../widgets/glass_card.dart';
import '../../core/location/datsuro_location_tracker.dart';
import '../../core/i18n/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key, required this.onOpenDiary, required this.onOpenGrassdex});
  final VoidCallback onOpenDiary;
  final VoidCallback onOpenGrassdex;
  static const thoughts = [
    (
      'Small steps still move you forward.',
      'You do not need to conquer the world. Start with the front door.'
    ),
    ('The world is still rendering.', 'Go explore a little of it today.'),
    (
      'Your comfort zone has excellent Wi-Fi.',
      'Unfortunately, the scenery is terrible.'
    ),
    (
      'One small expedition is still an expedition.',
      'The mascot believes in you. Mostly.'
    ),
    ('今日こそ、外へ。', 'Today, finally, outside.'),
    ('The grass will be here when you are ready.', 'No speedrun required.'),
    (
      'Even a tiny adventure counts.',
      'Just make sure it actually happens outside.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final store = DatsuroStore.instance;
    final s = store.state;
    final today = DateTime.now();
    final thoughtIndex =
        int.parse(DateFormat('yyyyMMdd').format(today)) % thoughts.length;
    final thought = thoughts[thoughtIndex];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        GlassCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/mascot/datsuro_mascot.png',
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      CupertinoIcons.leaf_arrow_circlepath,
                      size: 64,
                      color: sprout)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      "TODAY'S THOUGHT · ${DateFormat('MMM d').format(today).toUpperCase()}",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.1,
                          color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(height: 7),
                  Text(thought.$1,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(thought.$2,
                      style: Theme.of(context).textTheme.bodySmall),
                ])),
          ]),
        ),
        const SizedBox(height: 14),
        _IndoorCalendarCard(store: store),
        const SizedBox(height: 14),
        _HomeBaseCard(store: store),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppStrings.tr('Latest achievements'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          TextButton(
              onPressed: onOpenGrassdex,
              child: Text(AppStrings.tr('Grassdex'))),
        ]),
        if (s.stamps.isEmpty)
          GlassCard(
              child: Row(children: [
            const Icon(CupertinoIcons.sparkles, color: gold, size: 32),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    'Your first stamp is waiting outside. Your diary does not count, sneaky human.',
                    style: Theme.of(context).textTheme.bodyMedium)),
          ]))
        else
          ...s.stamps.reversed.take(3).map((stamp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                    child: Row(children: [
                  const CircleAvatar(
                      backgroundColor: Color(0xFFE7ECDD),
                      child: Icon(CupertinoIcons.rosette, color: forest)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('${stamp['name']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                            DateFormat('MMM d, yyyy').format(
                                DateTime.tryParse('${stamp['earnedAt']}') ??
                                    today),
                            style: Theme.of(context).textTheme.bodySmall),
                      ])),
                ])),
              )),
        const SizedBox(height: 14),
        GlassCard(
            child: Row(children: [
          const Icon(CupertinoIcons.book, color: sprout, size: 30),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(AppStrings.tr('Today’s memory'),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                    store.entryFor(today) == null
                        ? 'One photo. One note. A future memory.'
                        : 'Today’s memory is sealed.',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
          TextButton(
              onPressed: onOpenDiary, child: Text(AppStrings.tr('View'))),
        ])),
      ],
    );
  }
}

class _IndoorCalendarCard extends StatefulWidget {
  const _IndoorCalendarCard({required this.store});
  final DatsuroStore store;

  @override
  State<_IndoorCalendarCard> createState() => _IndoorCalendarCardState();
}

class _IndoorCalendarCardState extends State<_IndoorCalendarCard> {
  late DateTime selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _chooseMonth() async {
    final now = DateTime.now();
    var year = selectedMonth.year;
    var month = selectedMonth.month;
    final years = List<int>.generate(now.year - 1999, (i) => now.year - i);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.tr('Choose month')),
          content: Row(children: [
            Expanded(
                child: DropdownButtonFormField<int>(
              initialValue: month,
              decoration: InputDecoration(labelText: AppStrings.tr('Month')),
              items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                            DateFormat('MMMM').format(DateTime(2000, i + 1))),
                      )),
              onChanged: (value) {
                if (value != null) setDialogState(() => month = value);
              },
            )),
            const SizedBox(width: 12),
            Expanded(
                child: DropdownButtonFormField<int>(
              initialValue: year,
              decoration: InputDecoration(labelText: AppStrings.tr('Year')),
              items: years
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text('$value')))
                  .toList(),
              onChanged: (value) {
                if (value != null) setDialogState(() => year = value);
              },
            )),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppStrings.tr('Cancel'))),
            FilledButton(
                onPressed: () {
                  setState(() => selectedMonth = DateTime(year, month));
                  Navigator.pop(dialogContext);
                },
                child: Text(AppStrings.tr('Show'))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = selectedMonth;
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = (first.weekday + 6) % 7;
    final store = widget.store;
    final state = store.state;
    final escapeDates = state.escapes.map((e) {
      final d = DateTime.tryParse('${e['timestamp'] ?? ''}');
      return d == null ? '' : store.todayKey(d);
    }).toSet();
    final homeDates = state.manualHomeDays
        .where((e) => e['confirmed'] == true)
        .map((e) => e['date'])
        .where((date) => !escapeDates.contains(date))
        .toSet();
    final todayKey = store.todayKey(now);
    final escapedToday = escapeDates.contains(todayKey);

    return GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.tr('Indoor Chronicle'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(DateFormat('MMMM yyyy').format(month),
              style: Theme.of(context).textTheme.bodySmall),
        ]),
        IconButton(
            tooltip: AppStrings.tr('Choose month'),
            onPressed: _chooseMonth,
            icon: const Icon(CupertinoIcons.calendar, color: sprout, size: 26)),
      ]),
      const SizedBox(height: 16),
      Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                  child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)))))
              .toList()),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: offset + days,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4),
        itemBuilder: (context, index) {
          if (index < offset) return const SizedBox.shrink();
          final day = index - offset + 1;
          final date = DateTime(month.year, month.month, day);
          final key = store.todayKey(date);
          final isToday = date.year == now.year &&
              date.month == now.month &&
              day == now.day;
          final isHome = homeDates.contains(key);
          final isEscape = escapeDates.contains(key);
          final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));
          return Container(
            decoration: BoxDecoration(
              color: isHome
                  ? const Color(0xFFDDE8D2)
                  : isEscape
                      ? const Color(0xFFF7E9B9)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isToday ? gold : Colors.transparent, width: 2),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                  isHome
                      ? CupertinoIcons.house_fill
                      : isEscape
                          ? CupertinoIcons.leaf_arrow_circlepath
                          : CupertinoIcons.house,
                  size: 15,
                  color: isHome
                      ? forest
                      : isEscape
                          ? const Color(0xFF9C772A)
                          : Theme.of(context)
                              .hintColor
                              .withValues(alpha: isFuture ? .22 : .55)),
              Text('$day',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500)),
            ]),
          );
        },
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 6, children: [
        _legend(context, forest, AppStrings.tr('Confirmed home day')),
        _legend(context, const Color(0xFF9C772A), AppStrings.tr('Escape day')),
        _legend(
            context, Theme.of(context).hintColor, AppStrings.tr('Unconfirmed')),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
            child: _metric(context, AppStrings.tr('CURRENT STREAK'),
                '${store.currentIndoorDays} days', coral)),
        const SizedBox(width: 10),
        Expanded(
            child: _metric(context, AppStrings.tr('LONGEST STREAK'),
                '${store.longestIndoorStreak} days', forest)),
      ]),
      const SizedBox(height: 8),
      Text('${AppStrings.tr('Total escape days:')} ${store.totalEscapeDays}',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 10),
      Row(children: [
        Icon(
            escapedToday
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.location_circle,
            color: escapedToday ? sprout : Theme.of(context).hintColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
                AppStrings.tr(escapedToday
                    ? 'Escape detected today'
                    : !store.state.trackingEnabled
                        ? 'Tracking is off. Escape status is unknown.'
                        : store.state.trackingInsideRadius == null
                            ? 'Waiting for location fix'
                            : store.state.trackingInsideRadius!
                                ? 'Inside home radius'
                                : 'Outside home radius'),
                style: Theme.of(context).textTheme.bodySmall)),
      ]),
      Text(
          'Only confirmed location exits count as escapes. Missing location readings are left unclassified.',
          style: Theme.of(context).textTheme.bodySmall),
    ]));
  }

  Widget _legend(BuildContext context, Color color, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(CupertinoIcons.circle_fill, size: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ]);

  Widget _metric(
          BuildContext context, String label, String value, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: color)),
        ]),
      );
}

class _HomeBaseCard extends StatelessWidget {
  const _HomeBaseCard({required this.store});
  final DatsuroStore store;

  @override
  Widget build(BuildContext context) {
    final s = store.state;
    return GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.tr('Home Base'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(
              s.homeLat == null
                  ? AppStrings.tr('Set your home location to begin tracking.')
                  : '${s.radius} m radius · ${AppStrings.tr(s.trackingEnabled ? 'Tracking active' : 'Tracking paused')}',
              style: Theme.of(context).textTheme.bodySmall),
        ])),
        Icon(CupertinoIcons.map_pin_ellipse,
            color: s.homeLat == null ? Theme.of(context).hintColor : sprout,
            size: 30),
      ]),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFDCE7D5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sprout.withValues(alpha: .20),
                border: Border.all(
                    color: forest.withValues(alpha: .7), width: 1.5)),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: forest.withValues(alpha: .12), blurRadius: 8)
                ]),
            child:
                const Icon(CupertinoIcons.house_fill, color: forest, size: 23),
          ),
          Positioned(
            top: 34,
            right: 32,
            child: Image.asset('assets/mascot/datsuro_mascot.png',
                width: 42,
                height: 42,
                errorBuilder: (_, __, ___) => const Icon(
                    CupertinoIcons.leaf_arrow_circlepath,
                    color: forest,
                    size: 32)),
          ),
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(99)),
              child: Text('${s.radius} ${AppStrings.tr('m radius')}',
                  style: const TextStyle(
                      color: forest,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            try {
              await store.setHomeFromCurrentLocation();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Home coordinates saved locally. Background tracking is not available in this build.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            }
          },
          icon: const Icon(CupertinoIcons.location_fill),
          label: Text(AppStrings.tr(s.homeLat == null
              ? 'Set home to current location'
              : 'Update home location')),
        ),
      ),
      if (s.homeLat != null)
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(CupertinoIcons.location_circle),
          title: Text(AppStrings.tr(s.trackingEnabled
              ? 'Automatic tracking is on'
              : 'Automatic tracking is off')),
          subtitle: const Text(
              'Leave location services enabled. Android shows a persistent notification while tracking.'),
          value: s.trackingEnabled,
          onChanged: (enabled) async {
            try {
              if (enabled &&
                  !await DatsuroLocationTracker.instance
                      .requestBackgroundPermission()) {
                throw StateError(
                    'Allow background location access to start tracking.');
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
    ]));
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0xFFF6F3E9)
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke;
    final path1 = Path()
      ..moveTo(-20, size.height * .25)
      ..lineTo(size.width * .25, size.height * .60)
      ..lineTo(size.width * .52, size.height * .25)
      ..lineTo(size.width + 20, size.height * .55);
    final path2 = Path()
      ..moveTo(size.width * .20, -10)
      ..lineTo(size.width * .4, size.height * .4)
      ..lineTo(size.width * .32, size.height + 10);
    canvas.drawPath(path1, road);
    canvas.drawPath(path2, road);
    final park = Paint()..color = const Color(0xFFC8DDBB);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * .03, size.height * .66, size.width * .2,
                size.height * .22),
            const Radius.circular(12)),
        park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * .75, size.height * .05, size.width * .18,
                size.height * .22),
            const Radius.circular(12)),
        park);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
