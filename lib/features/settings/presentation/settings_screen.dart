import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
import 'package:bars/shared/widgets/coming_soon.dart';
import 'package:material_ui/material_ui.dart';

/// Settings hub, reached from the "Me" destination.
///
/// The grouped rows (appearance, language, storage) arrive in a later step;
/// until then this is a deliberate placeholder, not fake content.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarsPageHeader(title: l10n.settingsTitle),
          Expanded(child: ComingSoon(label: l10n.comingSoon)),
        ],
      ),
    );
  }
}
