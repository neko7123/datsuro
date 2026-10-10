import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/datsuro_store.dart';
import '../../widgets/glass_card.dart';
import '../../core/i18n/app_strings.dart';

class DailyMemoryScreen extends StatefulWidget {
  const DailyMemoryScreen({super.key});
  @override
  State<DailyMemoryScreen> createState() => _DailyMemoryScreenState();
}

class _DailyMemoryScreenState extends State<DailyMemoryScreen> {
  final picker = ImagePicker();
  final note = TextEditingController();
  String? photo;

  Future<void> choose(ImageSource source) async {
    try {
      final x = await picker.pickImage(source: source, imageQuality: 92);
      if (x != null && mounted) setState(() => photo = x.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open image picker: $e')));
      }
    }
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = DatsuroStore.instance.entryFor(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.tr("Today's Memory"))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (existing != null)
          GlassCard(
              child: Text(AppStrings.tr(
                  "Today's memory is already sealed. You can view it in Diary, but cannot change it.")))
        else ...[
          Container(
            height: 300,
            decoration: BoxDecoration(
                color: sprout.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: sprout.withValues(alpha: .5))),
            clipBehavior: Clip.antiAlias,
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(CupertinoIcons.photo_on_rectangle,
                            size: 58, color: forest),
                        const SizedBox(height: 12),
                        Text(AppStrings.tr('One photo for today'),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                            AppStrings.tr('Choose a moment worth remembering.'),
                            style: Theme.of(context).textTheme.bodySmall),
                      ])
                : Image.file(File(photo!), fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => choose(ImageSource.camera),
                    icon: const Icon(CupertinoIcons.camera),
                    label: Text(AppStrings.tr('Take photo')))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => choose(ImageSource.gallery),
                    icon: const Icon(CupertinoIcons.photo),
                    label: Text(AppStrings.tr('Choose photo')))),
          ]),
          const SizedBox(height: 18),
          Text(AppStrings.tr('A note to future me'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: note,
            maxLength: 500,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  AppStrings.tr('What do you want to remember about today?'),
              filled: true,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          Text(
              AppStrings.tr(
                  'After saving, this entry cannot be edited or replaced in the app.'),
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: photo == null
                ? null
                : () {
                    Navigator.pop(
                        context, {'photo': photo!, 'note': note.text});
                  },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(AppStrings.tr("Save today's memory")),
            ),
          ),
        ],
      ]),
    );
  }
}
