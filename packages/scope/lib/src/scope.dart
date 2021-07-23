import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A function that creates an object of type [T].
///
/// See also:
///
///  * [Dispose], to free the resources associated to the value created.
typedef Create<T> = T Function(BuildContext context);

/// A function that disposes an object of type [T].
///
/// See also:
///
///  * [Create], to create a value that will later be disposed of.
typedef Dispose<T> = void Function(BuildContext context, T value);

/// Scope, dependency injector/provider
///
/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `value` using [Scope.of].
class Scope<T extends Object> extends StatefulWidget {
  /// Expose to its descendants an existing value,
  Scope.value({
    required T value,
    this.builder,
    this.child,
    Key? key,
  })  : _scopeDelegate = _ValueScopeDelegate<T>(value),
        super(key: key);

  /// Obtains the nearest [Scope]<T> up its widget tree and returns its
  /// value.
  ///
  /// If not found searches in [GlobalScope].of<T>.
  ///
  /// And then calls the callback [fallback]
  ///
  /// And then calls the callback [GlobalScope.noSuchDependency](T)
  static T of<T extends Object?>({
    bool listen = false,
    T Function()? fallback,
  }) =>
      throw UnimplementedError();

  /// Syntax sugar for obtaining a [BuildContext] that can read the scope
  /// created.
  final TransitionBuilder? builder;

  /// Child widget.
  final Widget? child;

  final _IScopeDelegate<T> _scopeDelegate;

  @override
  State<Scope> createState() => _scopeDelegate.createState();
}

abstract class _IScopeDelegate<T extends Object> {
  State<Scope> createState();
}

class _ValueScopeDelegate<T extends Object> implements _IScopeDelegate<T> {
  _ValueScopeDelegate(this.value);

  final T value;

  @override
  State<Scope<T>> createState() {
    // TODO: implement call
    throw UnimplementedError();
  }
}

class _ValueScopeState<T extends Object> extends State<Scope> {
  @override
  Widget build(BuildContext context) =>
      widget.builder?.call(context, widget.child) ??
      widget.child ??
      const Offstage();
}
