import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
import 'package:bars/shared/widgets/coming_soon.dart';
import 'package:material_ui/material_ui.dart';

/// Home destination.
///
/// The header glow, quick access, carousels, most played, activity and
/// statistics arrive in a later step; until then this is a deliberate
/// placeholder, not fake content.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarsPageHeader(title: l10n.homeTitle),
          Expanded(child: ComingSoon(label: l10n.comingSoon)),
        ],
      ),
    );
  }
}
