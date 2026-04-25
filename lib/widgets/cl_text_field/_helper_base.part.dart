part of '../cl_text_field.widget.dart';

/// Base for private helpers — gives them access to the parent state.
abstract class _Helper {
  _Helper(this.s);
  final CLTextFieldState s;
  CLTextField get w => s.widget;
}
