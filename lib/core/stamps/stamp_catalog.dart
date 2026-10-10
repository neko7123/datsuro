import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/local_state.dart';
import '../i18n/app_strings.dart';

class StampDefinition {
  const StampDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.icon,
    required this.rarity,
    this.countryCode,
    this.countryName,
  });

  final String id;
  final String name;
  final String description;
  final String condition;
  final IconData icon;
  final String rarity;
  final String? countryCode;
  final String? countryName;

  String get flag {
    final code = countryCode;
    if (code == null) return '';
    return String.fromCharCodes(
        code.codeUnits.map((unit) => 0x1F1E6 + unit - 65));
  }
}

class StampCatalog {
  StampCatalog._();

  static const core = <StampDefinition>[
    StampDefinition(
        id: 'first_escape',
        name: 'First Escape',
        description: 'Your first confirmed trip beyond your home radius.',
        condition: 'Record an automatic exit from your home radius.',
        icon: Icons.door_front_door_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'escape_days_3',
        name: 'Fresh Air Trio',
        description: 'Three different days spent outside your home radius.',
        condition: 'Escape on 3 distinct days.',
        icon: Icons.air_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'five_escape_days',
        name: 'Frequent Flyer',
        description: 'Five different days with an outdoor escape.',
        condition: 'Escape on 5 distinct days.',
        icon: Icons.flight_takeoff_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'escape_days_10',
        name: 'Doorstep Regular',
        description: 'Ten days out in the wider world.',
        condition: 'Escape on 10 distinct days.',
        icon: Icons.directions_walk_rounded,
        rarity: 'Rare'),
    StampDefinition(
        id: 'escape_days_25',
        name: 'Neighborhood Friend',
        description: 'A quarter-century of outdoor days.',
        condition: 'Escape on 25 distinct days.',
        icon: Icons.park_rounded,
        rarity: 'Rare'),
    StampDefinition(
        id: 'escape_days_50',
        name: 'Local Explorer',
        description: 'Fifty days beyond your home radius.',
        condition: 'Escape on 50 distinct days.',
        icon: Icons.explore_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'escape_days_100',
        name: 'Outside Enthusiast',
        description: 'One hundred outdoor days recorded.',
        condition: 'Escape on 100 distinct days.',
        icon: Icons.hiking_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'escape_days_250',
        name: 'Seasoned Wanderer',
        description: 'A remarkable 250 outdoor days.',
        condition: 'Escape on 250 distinct days.',
        icon: Icons.landscape_rounded,
        rarity: 'Legendary'),
    StampDefinition(
        id: 'escape_days_500',
        name: 'World Walker',
        description: 'Five hundred outdoor days and counting.',
        condition: 'Escape on 500 distinct days.',
        icon: Icons.public_rounded,
        rarity: 'Mythic'),
    StampDefinition(
        id: 'morning_explorer',
        name: 'Morning Explorer',
        description: 'A fresh-air start before the day gets busy.',
        condition: 'Escape before 9:00 AM.',
        icon: Icons.wb_sunny_rounded,
        rarity: 'Rare'),
    StampDefinition(
        id: 'night_owl',
        name: 'Moonlight Stroll',
        description: 'The outside world after sunset.',
        condition: 'Escape after 8:00 PM.',
        icon: Icons.nightlight_round,
        rarity: 'Rare'),
    StampDefinition(
        id: 'weekend_wanderer',
        name: 'Weekend Wanderer',
        description: 'An escape on both weekend days.',
        condition: 'Escape on Saturday and Sunday.',
        icon: Icons.weekend_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'weekday_roamer',
        name: 'Weekday Roamer',
        description: 'Found a little room for fresh air all week.',
        condition: 'Escape on all 5 weekdays in one week.',
        icon: Icons.calendar_view_week_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'seven_day_explorer',
        name: 'Seven-Day Explorer',
        description: 'One small escape every day for a week.',
        condition: 'Escape on 7 consecutive local days.',
        icon: Icons.date_range_rounded,
        rarity: 'Legendary'),
    StampDefinition(
        id: 'thirty_day_explorer',
        name: 'A Month Outside',
        description: 'A month of steady outdoor days.',
        condition: 'Escape on 30 consecutive local days.',
        icon: Icons.calendar_month_rounded,
        rarity: 'Mythic'),
    StampDefinition(
        id: 'first_diary',
        name: 'Time Capsule',
        description: 'Saved your first photo memory.',
        condition: 'Save one diary entry.',
        icon: Icons.photo_camera_back_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'diary_days_7',
        name: 'One Week Remembered',
        description: 'A week of little memories.',
        condition: 'Save diary entries on 7 different days.',
        icon: Icons.auto_stories_rounded,
        rarity: 'Rare'),
    StampDefinition(
        id: 'diary_days_30',
        name: 'Memory Keeper',
        description: 'Thirty days preserved in your diary.',
        condition: 'Save diary entries on 30 different days.',
        icon: Icons.collections_bookmark_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'home_base_set',
        name: 'Home Sweet Home',
        description: 'Marked your home base for your quest.',
        condition: 'Set a home location.',
        icon: Icons.home_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'tracking_started',
        name: 'Quest Activated',
        description: 'Started automatic escape tracking.',
        condition: 'Enable location tracking.',
        icon: Icons.my_location_rounded,
        rarity: 'Common'),
    StampDefinition(
        id: 'countries_5',
        name: 'Five Horizons',
        description: 'Recorded visits in five countries.',
        condition: 'Collect 5 country stamps.',
        icon: Icons.travel_explore_rounded,
        rarity: 'Epic'),
    StampDefinition(
        id: 'countries_25',
        name: 'Continental Collector',
        description: 'A growing collection of country stamps.',
        condition: 'Collect 25 country stamps.',
        icon: Icons.public_rounded,
        rarity: 'Legendary'),
    StampDefinition(
        id: 'countries_100',
        name: 'Around the World',
        description: 'A hundred country stamps collected.',
        condition: 'Collect 100 country stamps.',
        icon: Icons.language_rounded,
        rarity: 'Mythic'),
    StampDefinition(
        id: 'stamps_25',
        name: 'Stamp Collector',
        description: 'Built a collection of 25 achievements.',
        condition: 'Collect 25 unique stamps.',
        icon: Icons.workspace_premium_rounded,
        rarity: 'Rare'),
    StampDefinition(
        id: 'stamps_100',
        name: 'Grassdex Grandmaster',
        description: 'A hundred unique achievements collected.',
        condition: 'Collect 100 unique stamps.',
        icon: Icons.military_tech_rounded,
        rarity: 'Mythic'),
  ];

  static Future<List<Map<String, String>>> loadCountries() async {
    final json = await rootBundle.loadString('assets/data/countries.json');
    return (jsonDecode(json) as List)
        .whereType<Map>()
        .map((item) => MapEntry(
              '${item['code']}'.toUpperCase(),
              '${item['name']}',
            ))
        .where((entry) => RegExp(r'^[A-Z]{2}$').hasMatch(entry.key))
        .map((entry) => {'code': entry.key, 'name': entry.value})
        .toList();
  }

  static List<StampDefinition> countries(List<Map<String, String>> values) =>
      values
          .map((country) => StampDefinition(
                id: 'country_${country['code']}',
                name: switch (AppStrings.languageCode) {
                  'ja' => '${country['name']}で外出',
                  'ko' => '${country['name']} 방문',
                  'zh' => '到访${country['name']}',
                  _ => 'Visit ${country['name']}',
                },
                description: switch (AppStrings.languageCode) {
                  'ja' => '${country['name']}で外出を検出しました。',
                  'ko' => '${country['name']}에서 외출이 감지되었습니다.',
                  'zh' => '已在${country['name']}检测到外出。',
                  _ => 'An outdoor escape was detected in ${country['name']}.',
                },
                condition: switch (AppStrings.languageCode) {
                  'ja' => '${country['name']}で外出を記録する。',
                  'ko' => '${country['name']}에서 외출을 기록하세요.',
                  'zh' => '在${country['name']}记录一次外出。',
                  _ => 'Record a qualifying escape in ${country['name']}.',
                },
                icon: Icons.flag_rounded,
                rarity: 'Country',
                countryCode: country['code'],
                countryName: country['name'],
              ))
          .toList();

  static String flagFor(String code) => String.fromCharCodes(
        code.toUpperCase().codeUnits.map((unit) => 0x1F1E6 + unit - 65),
      );

  static List<String> earnedIds(LocalState state) {
    final days = state.escapes
        .map((event) => DateTime.tryParse('${event['timestamp'] ?? ''}'))
        .whereType<DateTime>()
        .toList();
    final dayKeys =
        days.map((date) => DateFormat('yyyy-MM-dd').format(date)).toSet();
    final diaryDays = state.entries.map((entry) => '${entry['date']}').toSet();
    final earned = <String>{};
    void count(int threshold, String id) {
      if (dayKeys.length >= threshold) earned.add(id);
    }

    count(1, 'first_escape');
    count(3, 'escape_days_3');
    count(5, 'five_escape_days');
    count(10, 'escape_days_10');
    count(25, 'escape_days_25');
    count(50, 'escape_days_50');
    count(100, 'escape_days_100');
    count(250, 'escape_days_250');
    count(500, 'escape_days_500');
    if (days.any((date) => date.hour < 9)) earned.add('morning_explorer');
    if (days.any((date) => date.hour >= 20)) earned.add('night_owl');
    final weekendDaysByWeek = <String, Set<int>>{};
    for (final date in days.where((date) => date.weekday >= 6)) {
      final monday =
          DateTime(date.year, date.month, date.day - date.weekday + 1);
      final key = DateFormat('yyyy-MM-dd').format(monday);
      weekendDaysByWeek.putIfAbsent(key, () => <int>{}).add(date.weekday);
    }
    if (weekendDaysByWeek.values.any((weekend) =>
        weekend.containsAll({DateTime.saturday, DateTime.sunday}))) {
      earned.add('weekend_wanderer');
    }
    final weekdaysByWeek = <String, Set<int>>{};
    for (final date in days.where((date) => date.weekday < 6)) {
      final monday =
          DateTime(date.year, date.month, date.day - date.weekday + 1);
      final key = DateFormat('yyyy-MM-dd').format(monday);
      weekdaysByWeek.putIfAbsent(key, () => <int>{}).add(date.weekday);
    }
    if (weekdaysByWeek.values.any((week) => week.length == 5)) {
      earned.add('weekday_roamer');
    }
    final sortedDays =
        dayKeys.map(DateTime.tryParse).whereType<DateTime>().toList()..sort();
    var run = 0;
    DateTime? previous;
    for (final date in sortedDays) {
      run = previous != null && date.difference(previous).inDays == 1
          ? run + 1
          : 1;
      if (run >= 7) earned.add('seven_day_explorer');
      if (run >= 30) earned.add('thirty_day_explorer');
      previous = date;
    }
    if (diaryDays.isNotEmpty) earned.add('first_diary');
    if (diaryDays.length >= 7) earned.add('diary_days_7');
    if (diaryDays.length >= 30) earned.add('diary_days_30');
    if (state.homeLat != null && state.homeLon != null) {
      earned.add('home_base_set');
    }
    if (state.trackingEnabled) earned.add('tracking_started');
    final countries = state.visitedCountryCodes.toSet().length;
    if (countries >= 5) earned.add('countries_5');
    if (countries >= 25) earned.add('countries_25');
    if (countries >= 100) earned.add('countries_100');
    final collected = state.stamps.map((stamp) => '${stamp['id']}').toSet()
      ..addAll(earned);
    if (collected.length >= 25) earned.add('stamps_25');
    if (collected.length >= 100) earned.add('stamps_100');
    return earned.toList();
  }
}
