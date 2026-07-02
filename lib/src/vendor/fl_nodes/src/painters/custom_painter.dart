import 'dart:ui';

import 'package:genai_components/src/vendor/fl_nodes/fl_nodes.dart';

export 'package:genai_components/src/vendor/fl_nodes/src/core/events/events.dart';
export 'package:genai_components/src/vendor/fl_nodes/src/core/models/paint.dart';
export 'package:flutter/gestures.dart';

abstract class FlCustomPainter {
  final FlNodesController controller;

  bool needsPaint = true;

  FlCustomPainter(this.controller);

  void paint(Canvas canvas, Rect viewport);
}
