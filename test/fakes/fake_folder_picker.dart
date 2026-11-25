import 'package:alloy/core/platform/folder_picker.dart';

/// [FolderPicker] that returns a preset folder without a native dialog.
final class FakeFolderPicker implements FolderPicker {
  /// Folder returned by the next pick; `null` simulates cancel.
  String? folder;

  /// When set, [pickFolder] throws it instead of returning.
  Exception? error;

  /// Number of [pickFolder] calls.
  int calls = 0;

  @override
  Future<String?> pickFolder() async {
    calls++;
    final error = this.error;
    if (error != null) throw error;
    return folder;
  }
}
