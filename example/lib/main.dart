// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_table_field. Registers the SuperThemeData +
// AutoSuggestionsBoxThemeData extensions (so both components theme light/dark in
// parity), exposes a global Light/Dark + LTR/RTL toggle, and lists the two
// shipped demos:
//   • SuperTable — the unified grid with rowMenuBuilder, submenus, column
//     filters, pinned gutter, and combo keyboard navigation.
//   • Auto Suggestion Box — the typeahead on its own.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _dir = TextDirection.ltr;

  ThemeData _theme(SuperThemeData s) => ThemeData(
        brightness: s.brightness,
        scaffoldBackgroundColor: s.bg,
        extensions: [
          s,
          s.brightness == Brightness.dark
              ? AutoSuggestionsBoxThemeData.dark
              : AutoSuggestionsBoxThemeData.light,
        ],
      );

  void _toggleTheme() => setState(
      () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void _toggleDir() => setState(
      () => _dir = _dir == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Table Field',
      themeMode: _mode,
      theme: _theme(SuperThemeData.light),
      darkTheme: _theme(SuperThemeData.dark),
      builder: (context, child) =>
          Directionality(textDirection: _dir, child: child!),
      home: _Launcher(
        mode: _mode,
        dir: _dir,
        onToggleTheme: _toggleTheme,
        onToggleDir: _toggleDir,
      ),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  const _Demo(this.title, this.subtitle, this.icon, this.builder);
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.dir,
    required this.onToggleTheme,
    required this.onToggleDir,
  });

  final ThemeMode mode;
  final TextDirection dir;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDir;

  static final List<_Demo> _demos = [
    _Demo(
      'Super Table',
      'Editable/readable grid · 15 column types · row menus · submenus · grouping · filters · pagination · combo ⇒ AutoSuggestionsBox',
      Icons.grid_on_outlined,
      (_) => const SuperTableDemo(),
    ),
    _Demo(
      'Auto Suggestion Box',
      'Typeahead · groups · multi-select · fuzzy · remote fallback · advanced search · restoreOnBlur',
      Icons.manage_search_outlined,
      (_) => const AutoSuggestionBoxDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SuperTokens.space10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SuperTokens.contentColumn),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SUPER TABLE FIELD \u2022 GALLERY',
                      style: SuperText.eyebrow.copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Component Demos مكتبة المكونات',
                      style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space8),
                  for (final d in _demos) ...[
                    _DemoCard(demo: d),
                    const SizedBox(height: SuperTokens.space3),
                  ],
                  const SizedBox(height: SuperTokens.space6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SuperButton(
                        label: mode == ThemeMode.dark ? 'Light Theme' : 'Dark Theme',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleTheme,
                      ),
                      const SizedBox(width: SuperTokens.space3),
                      SuperButton(
                        label: dir == TextDirection.ltr ? 'العربية (RTL)' : 'English (LTR)',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleDir,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: demo.builder)),
        child: Container(
          padding: const EdgeInsets.all(SuperTokens.space4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
            border: Border.all(color: t.border),
            boxShadow: t.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                      SuperTokens.accent.withValues(alpha: 0.14), t.surface),
                  borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
                ),
                child: Icon(demo.icon, size: 22, color: SuperTokens.accent),
              ),
              const SizedBox(width: SuperTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(demo.title, style: SuperText.heading.copyWith(color: t.fg1)),
                    const SizedBox(height: 2),
                    Text(demo.subtitle, style: SuperText.caption.copyWith(color: t.fg3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: t.fg4),
            ],
          ),
        ),
      ),
    );
  }
}
