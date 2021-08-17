import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'global_scope.dart';

/// Global scope
@experimental
class ZonedScope {
  ZonedScope._();

  /// Provide value with zone
  static R inject<R extends Object?>(
    R Function() body,
    Iterable<Object> values,
  ) =>
      runZoned<R>(
        body,
        zoneValues: <Type, _GlobalScopeKey>{
          _GlobalScopeKey: _GlobalScopeKey.fromValues(values),
        },
      );

  /// Read data from [ZonedScope]
  static T? read<T extends Object>() {
    Zone? zone = Zone.current;
    while (zone != null) {
      final Object? provider = zone[_GlobalScopeKey];
      if (provider is _GlobalScopeKey) {
        final data = provider[T];
        if (data is T) {
          return data;
        } else {
          continue;
        }
      }
      zone = zone.parent;
    }
    return GlobalScope.read<T>();
  }
}

@immutable
class _GlobalScopeKey extends UnmodifiableMapBase<Type, Object> {
  _GlobalScopeKey.fromValues(Iterable<Object> values)
      : _internalMap = HashMap.fromIterable(
          values,
          key: (Object? element) => element!.runtimeType,
          value: (Object? element) => element!,
        );

  final Map<Type, Object> _internalMap;

  @override
  Object? operator [](Object? key) => key is Type ? _internalMap[key] : null;

  @override
  Iterable<Type> get keys => _internalMap.keys;
}
