import 'package:material_ui/material_ui.dart';

/// Settings screen.
///
/// Content is added in a later phase; the route exists so the shell can switch
/// between both destinations.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}
