/// A page route whose page can follow a downward drag before dismissing.
///
/// The now-playing screen drives the route through this interface, so the
/// screen does not depend on the app-level route implementation.
abstract interface class DragDismissRoute {
  /// Stops the entry animation and starts following the drag.
  ///
  /// Returns false while the page is still animating in; the screen ignores
  /// the gesture then.
  bool beginDrag();

  /// Moves the page down by [fraction] of its height.
  ///
  /// Negative values move it back up, so a drag that turns around restores
  /// the page.
  void updateDrag(double fraction);

  /// Dismisses the page from its current position.
  void dismiss();

  /// Returns the page to its open position.
  void settle();
}
