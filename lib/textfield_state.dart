import 'package:flutter/widgets.dart';

typedef void _TextChanged(String text);
typedef void _FocusChanged(bool focused);

/// Maintains a [TextEditingController] and a [FocusNode] for a [State] and
/// its [Widget]s.
///
/// Just pass [controller] and/or [focusNode] to your [TextField] or
/// [TextFormField] and be notified via the `*Changed` callbacks.
///
/// Call [update()] during [State.didUpdateWidget()] if your state's widget has
/// a controller or focusNode. Also call it during [State.initState()] if the
/// TextFieldState instance was constructed before initState().
///
/// Don't forget to call [dispose()] from [State.dispose()]!
class TextFieldState {
  /// `controller` and `focusNode` are from the state's widget, if applicable.
  /// They are provided here for convenience instead of having to call
  /// `update()` after construction.
  TextFieldState({
    _TextChanged textChanged,
    _FocusChanged focusChanged,
    _FocusChanged primaryFocusChanged,
    this.initialText,
    TextEditingController controller,
    FocusNode focusNode,
  })  : textChanged = textChanged,
        focusChanged = focusChanged,
        primaryFocusChanged = primaryFocusChanged {
    _updateController(controller);
    _updateFocusNode(focusNode);
  }

  final _TextChanged textChanged;
  final _FocusChanged focusChanged;
  final _FocusChanged primaryFocusChanged;

  /// The [controller] will be initialized with this value.
  final String initialText;

  bool get _usesController => textChanged != null;
  bool get _usesFocusNode =>
      focusChanged != null || primaryFocusChanged != null;

  TextEditingController get controller => _widgetController ?? _controller;
  TextEditingController _widgetController;
  TextEditingController _controller;

  FocusNode get focusNode => _widgetFocusNode ?? _focusNode;
  FocusNode _widgetFocusNode;
  FocusNode _focusNode;

  String _widgetInitialText;
  String _prevText;
  bool _hadFocus;
  bool _hadPrimaryFocus;

  void _updateController(TextEditingController widgetController) {
    if (!_usesController) return;

    if (widgetController != _widgetController) {
      final hasController = widgetController != null;
      final hadController = _widgetController != null;

      if (hadController) {
        _widgetController.removeListener(_handleControllerChanged);

        if (!hasController) {
          assert(_controller == null);
          _controller =
              TextEditingController.fromValue(_widgetController.value);
          _controller.addListener(_handleControllerChanged);
        }
      }

      if (hasController) {
        /// Don't reset text if reconstructing with the same initial value.
        if (widgetController.text == _widgetInitialText) {
          widgetController.value = controller.value;
        } else {
          _widgetInitialText = widgetController.text;
        }
        _controller?.dispose();
        _controller = null;
        widgetController.addListener(_handleControllerChanged);
      }
    }

    _widgetController = widgetController;

    // Ensure initialized
    if (controller == null) {
      _widgetInitialText = null;
      _controller = TextEditingController(text: _prevText ?? initialText ?? '');
      _controller.addListener(_handleControllerChanged);
    }
  }

  void _updateFocusNode(FocusNode widgetFocusNode) {
    if (!_usesFocusNode) return;

    if (widgetFocusNode != _widgetFocusNode) {
      _widgetFocusNode?.removeListener(_handleFocusNodeChanged);

      if (widgetFocusNode != null) {
        _focusNode?.dispose();
        _focusNode = null;
        widgetFocusNode.addListener(_handleFocusNodeChanged);
      }
    }

    _widgetFocusNode = widgetFocusNode;

    // Ensure initialized
    if (focusNode == null) {
      _focusNode = FocusNode();
      _focusNode.addListener(_handleFocusNodeChanged);
    }
  }

  /// Call this during [State.didUpdateWidget()] if your state's widget has a
  /// controller or focusNode.
  ///
  /// Also call it during [State.initState()] if these values weren't passed to
  /// the constructor.
  void update({
    TextEditingController controller,
    FocusNode focusNode,
  }) {
    _updateController(controller);
    _updateFocusNode(focusNode);
  }

  /// Call this during [State.dispose()].
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _focusNode?.dispose();
    _focusNode = null;
    _widgetController?.removeListener(_handleControllerChanged);
    _widgetFocusNode?.removeListener(_handleFocusNodeChanged);
    _prevText = null;
    _hadFocus = null;
    _hadPrimaryFocus = null;
  }

  void _handleControllerChanged() {
    final text = controller.text;
    if (text != _prevText) {
      textChanged?.call(text);
    }
    _prevText = text;
  }

  void _handleFocusNodeChanged() {
    final hasFocus = focusNode.hasFocus;
    final hasPrimaryFocus = focusNode.hasPrimaryFocus;

    if (hasPrimaryFocus != _hadPrimaryFocus) {
      primaryFocusChanged?.call(hasPrimaryFocus);
    }
    if (hasFocus != _hadFocus) {
      focusChanged?.call(hasFocus);
    }
    _hadPrimaryFocus = hasPrimaryFocus;
    _hadFocus = hasFocus;
  }
}
