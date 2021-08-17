import 'package:flutter/widgets.dart' show BuildContext;

import 'scope.dart' show Scope;

/// TODO: doc
extension BuildContextScopeX on BuildContext {
  /// TODO: doc
  T read<T extends Object>() => Scope.of<T>(this, listen: false);

  /// TODO: doc
  T watch<T extends Object>() => Scope.of<T>(this, listen: true);
}
