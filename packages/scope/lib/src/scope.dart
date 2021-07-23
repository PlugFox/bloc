// ignore_for_file: comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'exceptions.dart';

/// Whether the framework should notify widgets that inherit from this widget.
///
/// A function that returns true when the update from [previous] to [current]
/// should notify listeners, if any.
///
/// See also:
///
///   * [InheritedWidget.updateShouldNotify]
typedef UpdateShouldNotify<T> = bool Function(T previous, T current);

/// A function that creates an object of type [T].
///
/// See also:
///
///  * [Dispose], to free the resources associated to the value created.
typedef Create<T> = T Function(BuildContext context);

/// Called when a dependency of this [T] object changes.
///
/// For example, if the previous call to build referenced an InheritedWidget
///  or Scope that later changed, the framework would call this method
///  to notify this object about the change.
///
/// Method must return old or new version of value.
/// If old value have close/dispose method and you create new one
///  - close old value in this method.
///
/// [shouldNotify] called if instance is changed.
///
/// See also:
///
///  * [State.didChangeDependencies], called when a dependency changes.
typedef Update<T> = T Function(BuildContext context, T? value);

/// A function that disposes an object of type [T].
///
/// See also:
///
///  * [Create], to create a value that will later be disposed of.
typedef Dispose<T> = void Function(BuildContext context, T value);

/// Scope, dependency injector/provider/scope
///
/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `value` using [Scope.of].
abstract class Scope<T extends Object> extends Widget {
  /// Creates a value, then expose it to its descendants.
  ///
  /// The value will be disposed of when [Scope] is removed from
  /// the widget tree.
  factory Scope({
    required Create<T> create,
    Update<T>? update,
    Dispose<T>? dispose,
    TransitionBuilder? builder,
    Widget? child,
    UpdateShouldNotify<T>? shouldNotify,
    Key? key,
  }) =>
      _CreateScope(
        create,
        update,
        dispose,
        builder,
        child,
        shouldNotify,
        key,
      );

  /// Expose to its descendants an existing value,
  factory Scope.value({
    required T value,
    TransitionBuilder? builder,
    Widget? child,
    UpdateShouldNotify<T>? updateShouldNotify,
    Key? key,
  }) =>
      _ValueScope(
        value,
        builder,
        child,
        updateShouldNotify,
        key,
      );

  /// Obtains the nearest [Scope]<T> up its widget tree and returns its
  /// value.
  ///
  /// If not found searches in [GlobalScope].of<T>.
  ///
  /// And then calls the callback [fallback]
  ///
  /// And then calls the callback [GlobalScope.noSuchDependency](T)
  static T of<T extends Object>(
    BuildContext context, {
    bool listen = false,
    T Function()? fallback,
  }) {
    T? value;
    value = _InheritedScope.of<T>(context, listen) ?? fallback?.call();
    if (value == null) {
      throw ScopeNotFoundException(T);
    }
    return value;
  }

  /// A builder that builds a widget given a child.
  ///
  /// The child should typically be part of the returned widget tree.
  ///
  /// See also:
  ///
  ///  * [WidgetBuilder], which is similar but only takes a [BuildContext].
  ///  * [IndexedWidgetBuilder], which is similar but also takes an index.
  ///  * [ValueWidgetBuilder], which is similar but takes a value and a child.
  TransitionBuilder? get builder;

  /// Child widget.
  Widget? get child;

  /// Whether the framework should notify widgets that inherit from this widget.
  ///
  /// See also:
  ///
  ///   * [InheritedWidget.updateShouldNotify]
  UpdateShouldNotify<T>? get shouldNotify;
}

class _ValueScope<T extends Object> extends StatelessWidget
    implements Scope<T> {
  _ValueScope(
    this.value,
    this.builder,
    this.child,
    this.shouldNotify,
    Key? key,
  ) : super(key: key);

  final T value;

  @override
  final TransitionBuilder? builder;

  @override
  final Widget? child;

  @override
  final UpdateShouldNotify<T>? shouldNotify;

  @override
  Widget build(BuildContext context) => _InheritedScope<T>(
        value: value,
        child: builder?.call(context, child) ?? child ?? const Offstage(),
        shouldNotify: shouldNotify,
      );
}

class _CreateScope<T extends Object> extends StatefulWidget
    implements Scope<T> {
  _CreateScope(
    this.create,
    this.update,
    this.dispose,
    this.builder,
    this.child,
    this.shouldNotify,
    Key? key,
  ) : super(key: key);

  final Create<T> create;

  final Update<T>? update;

  final Dispose<T>? dispose;

  @override
  final TransitionBuilder? builder;

  @override
  final Widget? child;

  @override
  final UpdateShouldNotify<T>? shouldNotify;

  @override
  State<_CreateScope<T>> createState() => _CreateScopeState<T>();
}

class _CreateScopeState<T extends Object> extends State<_CreateScope<T>> {
  T? value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldValue = value;
    final update = widget.update;
    if (value != null && update != null) {
      value = update(context, oldValue);
    } else {
      value = widget.create(context);
    }
  }

  @override
  void dispose() {
    final dispose = widget.dispose;
    if (dispose != null) {
      dispose(context, value!);
    } else if (value is Sink || value is StreamConsumer) {
      (value as dynamic).close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InheritedScope<T>(
        value: value!,
        child: widget.builder?.call(context, widget.child) ??
            widget.child ??
            const Offstage(),
        shouldNotify: widget.shouldNotify,
      );
}

@immutable
class _InheritedScope<T extends Object> extends InheritedWidget {
  const _InheritedScope({
    required this.value,
    required Widget child,
    required this.shouldNotify,
    Key? key,
  }) : super(key: key, child: child);

  final T value;

  static T? of<T extends Object>(BuildContext ctx, bool listen) =>
      listen ? watch<T>(ctx) : read<T>(ctx);

  static T? watch<T extends Object>(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<_InheritedScope<T>>()?.value;

  static T? read<T extends Object>(BuildContext ctx) {
    final e = ctx.getElementForInheritedWidgetOfExactType<_InheritedScope<T>>();
    final w = e?.widget;
    return w is _InheritedScope<T> ? w.value : null;
  }

  final UpdateShouldNotify<T>? shouldNotify;

  @override
  bool updateShouldNotify(covariant _InheritedScope<T> oldWidget) {
    final prev = oldWidget.value;
    final next = value;
    if (identical(prev, value)) {
      return false;
    }
    return shouldNotify?.call(prev, next) ?? prev != next;
  }
}

/// TODO: doc
extension BuildContextScopeX on BuildContext {
  /// TODO: doc
  T read<T extends Object?>() => Scope.of(this, listen: false);

  /// TODO: doc
  T watch<T extends Object?>() => Scope.of(this, listen: true);
}

final a = StatefulElement(widget);
final b = StatelessElement(widget);
