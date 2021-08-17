import 'dart:collection';

import 'package:meta/meta.dart';

/// Global scope
@experimental
class GlobalScope {
  GlobalScope._() : _delegate = _GlobalScopeDelegate();

  static GlobalScope? _lazyInstance;
  static GlobalScope get _instance => _lazyInstance ??= GlobalScope._();

  final _GlobalScopeDelegate _delegate;

  /// Provide value with [GlobalScope]
  static void inject(Object value) =>
      _instance._delegate[value.runtimeType] = value;

  /// Read data from [GlobalScope]
  static T? read<T extends Object>() => _instance._delegate[T] as T?;
}

class _GlobalScopeDelegate extends MapBase<Type, Object> {
  _GlobalScopeDelegate() : _internalMap = HashMap<Type, Object>();

  final Map<Type, Object> _internalMap;

  @override
  Object? operator [](Object? key) => key is Type ? _internalMap[key] : null;

  @override
  void operator []=(Type key, Object value) => _internalMap[key] = value;

  @override
  void clear() => _internalMap.clear();

  @override
  Iterable<Type> get keys => _internalMap.keys;

  @override
  Object? remove(Object? key) => key is Type ? _internalMap.remove(key) : null;
}
