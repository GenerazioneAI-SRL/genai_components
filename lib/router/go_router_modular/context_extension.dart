import 'package:flutter/material.dart';

import 'bind.dart';

extension BindContextExtension on BuildContext {
  T read<T>() {
    final bind = Bind.get<T>();
    return bind;
  }
}
