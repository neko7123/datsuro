import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/i18n/app_strings.dart';
import 'core/storage/datsuro_store.dart';
import 'core/theme/app_colors.dart';
import 'features/startup/startup_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DatsuroApp());
}

class DatsuroApp extends StatefulWidget {
  const DatsuroApp({super.key});

  @override
  State<DatsuroApp> createState() => _DatsuroAppState();
}

class _DatsuroAppState extends State<DatsuroApp> {
  final store = DatsuroStore.instance;
  late bool dark = store.state.darkMode;
  late String languageCode = store.state.languageCode;

  @override
  void initState() {
    super.initState();
    store.addListener(_syncTheme);
  }

  @override
  void dispose() {
    store.removeListener(_syncTheme);
    super.dispose();
  }

  void _syncTheme() {
    if (dark != store.state.darkMode ||
        languageCode != store.state.languageCode) {
      setState(() {
        dark = store.state.darkMode;
        languageCode = store.state.languageCode;
        AppStrings.languageCode = languageCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: dark ? const Color(0xFF151D18) : paper,
      cardTheme: CardThemeData(
        color: dark
            ? const Color(0xFF26342B)
            : Colors.white.withValues(alpha: .78),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      dialogTheme: DialogThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 13))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12))),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : forest,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
    );

    return MaterialApp(
      title: '脱籠',
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: Locale(languageCode),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: _LaunchAnimation(
        child: StartupGate(
          onThemeChanged: (value) {
            setState(() => dark = value);
            DatsuroStore.instance.state.darkMode = value;
            unawaited(DatsuroStore.instance.save());
          },
        ),
      ),
    );
  }
}

class _LaunchAnimation extends StatefulWidget {
  const _LaunchAnimation({required this.child});
  final Widget child;

  @override
  State<_LaunchAnimation> createState() => _LaunchAnimationState();
}

class _LaunchAnimationState extends State<_LaunchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  bool visible = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => visible = false);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (visible)
            FadeTransition(
              opacity: ReverseAnimation(CurvedAnimation(
                parent: controller,
                curve: const Interval(.62, 1, curve: Curves.easeOut),
              )),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final t = Curves.easeOutBack.transform(controller.value);
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        Transform.scale(
                          scale: .72 + .28 * t,
                          child: Container(
                            width: 156,
                            height: 156,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .72),
                              boxShadow: [
                                BoxShadow(
                                  color: forest.withValues(alpha: .12),
                                  blurRadius: 36,
                                  spreadRadius: 6,
                                )
                              ],
                            ),
                            child: Image.asset(
                                'assets/mascot/datsuro_mascot.png',
                                fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: controller.value.clamp(0, 1),
                          child: const Text('脱籠',
                              style: TextStyle(
                                color: forest,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              )),
                        ),
                      ]);
                    },
                  ),
                ),
              ),
            ),
        ],
      );
}
