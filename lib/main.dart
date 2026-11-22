import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Entry point; the real bootstrap arrives in Phase 2.
void main() {
  runApp(const ProviderScope(child: MainApp()));
}

/// Temporary root widget, replaced by the app shell in Phase 2.
class MainApp extends StatelessWidget {
  /// Creates the temporary root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
