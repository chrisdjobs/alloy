import 'package:bars/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Library screen.
///
/// Phase 4 replaces this placeholder with the real track list.
class LibraryScreen extends StatelessWidget {
  /// Creates the library screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context).libraryTitle));
  }
}
