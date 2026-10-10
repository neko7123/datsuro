import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/stamps/stamp_catalog.dart';
import '../../core/storage/datsuro_store.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class GrassdexScreen extends StatefulWidget {
  const GrassdexScreen({super.key});
  @override
  State<GrassdexScreen> createState() => _GrassdexScreenState();
}

class _GrassdexScreenState extends State<GrassdexScreen> {
  bool historyExpanded = false;
  DateTimeRange? range;
  List<StampDefinition> definitions = StampCatalog.core;
  String query = '';
  String? _catalogLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Localizations.localeOf(context);
    if (_catalogLanguage == AppStrings.languageCode) return;
    _catalogLanguage = AppStrings.languageCode;
    StampCatalog.loadCountries().then((countries) {
      if (mounted && _catalogLanguage == AppStrings.languageCode) {
        setState(() => definitions = [
              ...StampCatalog.core,
              ...StampCatalog.countries(countries)
            ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = DatsuroStore.instance.state;
    final stamps = state.stamps;
    final history = stamps
        .where((stamp) {
          final date = DateTime.tryParse('${stamp['earnedAt'] ?? ''}');
          if (date == null || range == null) return true;
          final end =
              DateTime(range!.end.year, range!.end.month, range!.end.day + 1);
          return !date.isBefore(range!.start) && date.isBefore(end);
        })
        .toList()
        .reversed
        .toList();
    final shownHistory = historyExpanded ? history : history.take(3).toList();
    final collected = stamps.map((stamp) => '${stamp['id']}').toSet();
    final definitionsById = {for (final stamp in definitions) stamp.id: stamp};
    final visible = definitions
        .where((stamp) =>
            query.isEmpty ||
            AppStrings.tr(stamp.name)
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            AppStrings.tr(stamp.condition)
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (stamp.countryCode?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          GlassCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(AppStrings.tr('Grassdex'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                Text(AppStrings.tr('Outdoor milestones and country stamps.')),
                const SizedBox(height: 14),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('Stamp collection'),
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${collected.length} / ${definitions.length}'),
                    ]),
                const SizedBox(height: 8),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                        value: definitions.isEmpty
                            ? 0
                            : (collected.length / definitions.length)
                                .clamp(0, 1),
                        minHeight: 8,
                        color: sprout,
                        backgroundColor: sprout.withValues(alpha: .18))),
                const SizedBox(height: 12),
                TextField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.search),
                        hintText: AppStrings.tr('Search stamps'),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => setState(() => query = ''),
                                icon: const Icon(CupertinoIcons.clear))),
                    onChanged: (value) => setState(() => query = value.trim())),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: .78),
                  itemBuilder: (context, index) {
                    final stamp = visible[index];
                    final has = collected.contains(stamp.id);
                    final hue = stamp.id.codeUnits
                            .fold<int>(0, (sum, unit) => sum + unit) %
                        360;
                    final color = HSLColor.fromAHSL(
                            1, hue.toDouble(), .28, has ? .88 : .94)
                        .toColor();
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: Text(
                                    '${stamp.flag.isEmpty ? '' : '${stamp.flag} '}${AppStrings.tr(stamp.name)}'),
                                content: Text(
                                    '${AppStrings.tr(stamp.description)}\n\n${AppStrings.tr(stamp.condition)}\n\n${has ? AppStrings.tr('Collected') : AppStrings.tr('Not yet collected')}'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(AppStrings.tr('Close')))
                                ],
                              )),
                      child: Container(
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: has
                                    ? sprout
                                    : Theme.of(context)
                                        .dividerColor
                                        .withValues(alpha: .25),
                                width: has ? 1.5 : 1)),
                        padding: const EdgeInsets.all(7),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (stamp.countryCode != null)
                                Text(stamp.flag,
                                    style: TextStyle(
                                        fontSize: 29,
                                        color: has ? null : Colors.black26))
                              else
                                Icon(
                                    has ? stamp.icon : CupertinoIcons.lock_fill,
                                    size: 27,
                                    color: has
                                        ? forest
                                        : Theme.of(context).hintColor),
                              const SizedBox(height: 7),
                              Text(AppStrings.tr(stamp.name),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10)),
                              Text(
                                  has
                                      ? AppStrings.tr('Collected')
                                      : stamp.rarity,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                  textAlign: TextAlign.center),
                            ]),
                      ),
                    );
                  },
                ),
              ])),
          const SizedBox(height: 16),
          GlassCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('Stamp History'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      IconButton(
                          onPressed: () => setState(
                              () => historyExpanded = !historyExpanded),
                          icon: Icon(historyExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down)),
                    ]),
                OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: range);
                      if (picked != null && mounted) {
                        setState(() => range = picked);
                      }
                    },
                    icon: const Icon(CupertinoIcons.calendar),
                    label: Text(range == null
                        ? AppStrings.tr('Filter by date')
                        : '${DateFormat('MMM d').format(range!.start)} – ${DateFormat('MMM d, yyyy').format(range!.end)}')),
                if (range != null)
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => setState(() => range = null),
                          child: Text(AppStrings.tr('Clear filter')))),
                if (shownHistory.isEmpty)
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(AppStrings.tr('No stamps collected yet.'))),
                ...shownHistory.map((stamp) {
                  return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE7ECDD),
                          child: Icon(CupertinoIcons.rosette, color: forest)),
                      title: Text(AppStrings.tr(
                          definitionsById['${stamp['id']}']?.name ??
                              '${stamp['name']}')),
                      subtitle: Text(DateFormat('MMM d, yyyy · HH:mm').format(
                          DateTime.tryParse('${stamp['earnedAt']}') ??
                              DateTime.now())));
                }),
                if (history.length > 3)
                  Center(
                      child: TextButton(
                          onPressed: () => setState(
                              () => historyExpanded = !historyExpanded),
                          child: Text(AppStrings.tr(
                              historyExpanded ? 'Show less' : 'View more')))),
              ])),
        ]);
  }
}
