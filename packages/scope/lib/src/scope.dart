import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'create_scope.dart';
import 'exceptions.dart';
import 'inherited_scope.dart';
import 'interface_scope.dart';
import 'value_scope.dart';

/// {@template scope}
/// Scope, dependency injector/provider/scope
///
/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `value` using [Scope.of].
/// {@endtemplate}
abstract class Scope implements Widget, IScope {
  const Scope._();

  /// Creates a value, then expose it to its descendants.
  ///
  /// The value will be disposed of when [IScope] is removed from
  /// the widget tree.
  @factory
  static IScope<T> create<T extends Object>({
    required Create<T> create,
    Update<T>? update,
    Dispose<T>? dispose,
    TransitionBuilder? builder,
    Widget? child,
    UpdateShouldNotify<T>? shouldNotify,
    Key? key,
  }) =>
      CreateScope<T>(
        create,
        update,
        dispose,
        builder,
        child,
        shouldNotify,
        key,
      );

  /// Expose to its descendants an existing value,
  @factory
  static IScope<T> value<T extends Object>({
    required T value,
    TransitionBuilder? builder,
    Widget? child,
    UpdateShouldNotify<T>? shouldNotify,
    Key? key,
  }) =>
      ValueScope<T>(
        value,
        builder,
        child,
        shouldNotify,
        key,
      );

  /// Obtains the nearest [Scope]<T> up its widget tree and returns its
  /// value.
  ///
  /// If not found searches in GlobalScope.of<T>.
  ///
  /// And then calls the callback GlobalScope.fallback(T)
  ///
  /// Throw [ScopeNotFoundException] if [T] not exist.
  static T of<T extends Object>(
    BuildContext context, {
    bool listen = false,
  }) {
    T? value;
    value = maybeOf<T>(context, listen: listen);
    if (value == null) {
      throw ScopeNotFoundException(T);
    }
    return value;
  }

  /// Obtains the nearest [Scope]<T> up its widget tree and returns its
  /// value.
  ///
  /// If not found searches in GlobalScope.of<T>.
  ///
  /// And then calls the callback GlobalScope.fallback(T)
  ///
  /// Return null if [T] not exist.
  static T? maybeOf<T extends Object>(
    BuildContext context, {
    bool listen = false,
  }) {
    T? value;
    value = InheritedScope.of<T>(context, listen);
    return value;
  }
}
