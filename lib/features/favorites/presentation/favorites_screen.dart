import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/alloy_page_header.dart';
import 'package:alloy/shared/widgets/coming_soon.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Favorites destination, reachable from the Home quick actions.
///
/// The list of favorited tracks is not built yet, so the body stays a
/// [ComingSoon] placeholder.
class FavoritesScreen extends StatelessWidget {
  /// Creates the favorites screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AlloyPageHeader(
            title: l10n.favorites,
            leading: IconButton(
              onPressed: () => context.pop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icon(context.icons.back),
            ),
          ),
          Expanded(child: ComingSoon(label: l10n.favoritesComingSoon)),
        ],
      ),
    );
  }
}
