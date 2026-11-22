import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Starts the app and installs the platform-specific provider overrides.
void bootstrap() {
  runApp(const ProviderScope(child: BarsApp()));
}

/// Root widget: theme, router and localization configuration.
class BarsApp extends ConsumerWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Bars',
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
