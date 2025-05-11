/// A controller for interacting with [MarkerDraggableSheet].
///
/// Allows the parent widget to programmatically control the sheet,
/// such as triggering animations like expanding, collapsing, or snapping
/// to a specific size.
class MarkerSheetController {
  /// Internal callback that is bound to the child sheet's state.
  ///
  /// This is set when the controller is attached to a [MarkerDraggableSheet].
  void Function()? _animateCallback;

  /// Binds a callback from the sheet's internal state.
  ///
  /// This is used internally by the sheet. You should not call this manually.
  void bind(void Function() animateCallback) {
    _animateCallback = animateCallback;
  }

  /// Triggers the sheet to animate to its initial size.
  ///
  /// This will have no effect if the controller has not been bound yet,
  /// or if the sheet is not currently attached to the widget tree.
  void animateSheet() {
    _animateCallback?.call();
  }
}
