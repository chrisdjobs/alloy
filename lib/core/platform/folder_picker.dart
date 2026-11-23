import 'package:file_picker/file_picker.dart';

/// Lets the user pick a music folder on this platform.
abstract interface class FolderPicker {
  /// Returns the chosen directory path, or `null` when the user cancels.
  Future<String?> pickFolder();
}

/// [FolderPicker] backed by the native file picker.
final class FilePickerFolderPicker implements FolderPicker {
  /// Creates the picker adapter.
  const new();

  @override
  Future<String?> pickFolder() {
    // `pickDirectory` returns a SAF content URI on Android, which dart:io
    // cannot list. v1 scans a real path with the read-audio permission; the
    // MediaStore/SAF migration is tracked in memory/decisions/0010.
    // ignore: deprecated_member_use
    return FilePicker.getDirectoryPath();
  }
}
