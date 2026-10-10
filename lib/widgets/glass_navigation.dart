import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/i18n/app_strings.dart';

class GlassNavigation extends StatelessWidget {
  const GlassNavigation(
      {super.key, required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (CupertinoIcons.house_fill, AppStrings.tr('Home')),
      (CupertinoIcons.square_grid_2x2_fill, AppStrings.tr('Grassdex')),
      (CupertinoIcons.camera_fill, AppStrings.tr('Camera')),
      (CupertinoIcons.book_fill, AppStrings.tr('Diary')),
      (CupertinoIcons.settings_solid, AppStrings.tr('Settings')),
    ];
    const barHeight = 64.0;
    final safeBottom =
        MediaQuery.viewPaddingOf(context).bottom.clamp(8.0, 48.0);
    // Bound the bar itself and reserve system navigation space outside it.
    // Without both constraints Scaffold can give the Row the full screen height.
    return SizedBox(
      height: barHeight + safeBottom,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, safeBottom),
        child: SizedBox(
          height: barHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xEE25342B)
                    : Colors.white.withValues(alpha: .98),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withValues(alpha: .75), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: forest.withValues(alpha: .12),
                      blurRadius: 22,
                      offset: const Offset(0, 8))
                ],
              ),
              // Keep a little headroom for font metrics that vary by device.
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: List.generate(items.length, (i) {
                  final selected = this.selected == i;
                  if (i == 2) {
                    return Expanded(
                      child: Tooltip(
                        message: 'Create today’s memory',
                        child: Center(
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onSelect(i),
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: forest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: .7),
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: forest.withValues(alpha: .24),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Icon(CupertinoIcons.camera_fill,
                                  color: Colors.white, size: 23),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? sprout.withValues(alpha: .16)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(items[i].$1,
                                size: 21,
                                color: selected
                                    ? forest
                                    : Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 3),
                          Text(items[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? forest
                                    : Theme.of(context).hintColor,
                              )),
                        ]),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
