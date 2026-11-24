/// Accent colors offered in the appearance settings.
///
/// The first entry is the design default, so the list always shows the color
/// the app uses before the user picks one.
abstract final class AppAccents {
  /// Accent applied before the user picks one.
  static const int fallback = 0xFFFFB300;

  /// Selectable accent colors as ARGB values.
  static const List<int> palette = [
    fallback, // Amber, the design default.
    0xFF8BD3E6, // Ice blue.
    0xFF6A3FB5, // Violet.
    0xFFF5D74A, // Lemon.
    0xFF3F9E5B, // Forest green.
    0xFF3B82F6, // Blue.
    0xFFE05A5A, // Coral red.
    0xFFD81B60, // Magenta.
    0xFFF08A1E, // Orange.
    0xFF8E9AA6, // Slate.
    0xFF17838C, // Deep teal.
    0xFFC6EC1B, // Lime.
    0xFFF2C58A, // Peach.
    0xFFFFFFFF, // White.
    0xFF4F5BBF, // Indigo.
    0xFF8D6E63, // Brown.
    0xFFBFE8E4, // Mint.
    0xFF6DBF8C, // Sage.
  ];
}
