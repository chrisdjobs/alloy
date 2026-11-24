import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
import 'package:bars/shared/widgets/coming_soon.dart';
import 'package:material_ui/material_ui.dart';

/// Discover destination.
///
/// Card-swipe discovery needs a catalog, which is out of scope for now; the
/// screen stays a placeholder until a local source is designed.
class DiscoverScreen extends StatelessWidget {
  /// Creates the discover screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarsPageHeader(title: l10n.discoverTitle),
          Expanded(child: ComingSoon(label: l10n.comingSoon)),
        ],
      ),
    );
  }
}
