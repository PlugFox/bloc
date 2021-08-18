import 'package:flutter/widgets.dart' show BuildContext;

import 'exceptions.dart';
import 'scope.dart' show Scope;

/// TODO: doc
extension BuildContextScopeX on BuildContext {
  /// TODO: doc
  T read<T extends Object>({final T Function()? orElse}) {
    final value = Scope.maybeOf<T>(this, listen: false);
    if (value != null) {
      return value;
    } else if (orElse != null) {
      return orElse();
    }
    throw ScopeNotFoundException(T);
  }

  /// TODO: doc
  T watch<T extends Object>({final T Function()? orElse}) {
    final value = Scope.maybeOf<T>(this, listen: true);
    if (value != null) {
      return value;
    } else if (orElse != null) {
      return orElse();
    }
    throw ScopeNotFoundException(T);
  }

  /// TODO: doc
  T? tryRead<T extends Object>() => Scope.maybeOf<T>(this, listen: false);

  /// TODO: doc
  T? tryWatch<T extends Object>() => Scope.maybeOf<T>(this, listen: true);
}
