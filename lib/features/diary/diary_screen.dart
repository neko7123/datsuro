import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/datsuro_store.dart';
import '../../widgets/glass_card.dart';
import '../../core/i18n/app_strings.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = DatsuroStore.instance;
    return AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final entries = [...store.state.entries]
            ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
          return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
              children: [
                Text(AppStrings.tr('My Memories'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                Text(AppStrings.tr('Your life, one day at a time.'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  GlassCard(
                      child: Column(children: [
                    Image.asset('assets/mascot/datsuro_mascot.png',
                        width: 120,
                        height: 120,
                        errorBuilder: (_, __, ___) =>
                            const Icon(CupertinoIcons.book, size: 72)),
                    const SizedBox(height: 8),
                    Text(AppStrings.tr('Your timeline starts with one photo.'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(AppStrings.tr(
                        'Tap the camera button to save today’s memory. Once saved, entries cannot be edited.')),
                  ]))
                else
                  ...entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => DiaryDetailScreen(entry: e))),
                          child: GlassCard(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                SizedBox(
                                  width: 104,
                                  height: 130,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File('${e['photo']}'),
                                      fit: BoxFit.cover,
                                      cacheWidth: 320,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: sprout.withValues(alpha: .15),
                                        child: const Icon(CupertinoIcons.photo,
                                            size: 32),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          DateFormat('EEEE, MMM d, yyyy')
                                              .format(DateTime.tryParse(
                                                      '${e['date']}') ??
                                                  DateTime.now()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 8),
                                      Text(
                                          '${e['note'] ?? ''}'.isEmpty
                                              ? AppStrings.tr(
                                                  'A quiet moment, saved forever.')
                                              : '${e['note']}',
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        const Icon(CupertinoIcons.lock_fill,
                                            size: 13),
                                        const SizedBox(width: 4),
                                        Text(AppStrings.tr('Sealed memory'),
                                            style:
                                                const TextStyle(fontSize: 11))
                                      ]),
                                    ])),
                              ])),
                        ),
                      )),
              ]);
        });
  }
}

class DiaryDetailScreen extends StatelessWidget {
  const DiaryDetailScreen({super.key, required this.entry});
  final Map<String, dynamic> entry;
  @override
  Widget build(BuildContext context) {
    final file = File('${entry['photo']}');
    final date = DateTime.tryParse('${entry['date']}') ?? DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.tr('Sealed Memory'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(DateFormat('EEEE, MMMM d, yyyy').format(date),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            cacheWidth: MediaQuery.of(context).size.width.toInt(),
            errorBuilder: (_, __, ___) => Container(
              height: 220,
              color: sprout.withValues(alpha: .15),
              child: const Icon(CupertinoIcons.photo, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GlassCard(
            child: Text('${entry['note'] ?? ''}'.isEmpty
                ? AppStrings.tr('No note was saved for this day.')
                : '${entry['note']}')),
        const SizedBox(height: 12),
        Text(
            AppStrings.tr(
                'This entry is read-only. Your diary does not affect your indoor streak.'),
            style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
