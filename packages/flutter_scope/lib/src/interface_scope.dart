// ignore_for_file: comment_references

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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
typedef Dispose<T> = void Function(T value);

/// {@template scope}
/// Scope, dependency injector/provider/scope
///
/// A generic implementation of an [InheritedWidget].
///
/// Any descendant of this widget can obtain `value` using [Scope.of].
/// {@endtemplate}
abstract class IScope<T extends Object> extends Widget {
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

  /// Copy with new fields
  IScope copyWith({
    Widget? newChild,
    UpdateShouldNotify<T>? newShouldNotify,
    TransitionBuilder? newBuilder,
    Key? newKey,
  });
}

/// Placeholder replacing missing widgets
@internal
const Widget scopePlaceholder = SizedBox.shrink();
