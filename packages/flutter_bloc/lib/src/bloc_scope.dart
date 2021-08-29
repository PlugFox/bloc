import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fox_core_bloc/bloc.dart';
import 'package:fox_flutter_scope/scope.dart';

/// TODO: doc
typedef Create<T> = T Function(BuildContext context);

/// {@template bloc_scope}
/// Takes a [Create] function that is responsible for
/// creating the [Bloc] and a [child] which will have access
/// to the instance via `BlocScope.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [Bloc] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// BlocScope(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// It automatically handles closing the instance when used with [Create].
/// By default, [Create] is called only when the instance is accessed.
///
/// ```dart
/// BlocScope(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// {@endtemplate}
class BlocScope<T extends IStateObservable<Object?>> extends StatelessWidget {
  /// {@macro bloc_scope}
  BlocScope.create({
    required Create<T> create,
    this.child,
    Key? key,
  })  : _create = create,
        _value = null,
        super(key: key);

  /// Takes a [value] and a [child] which will have access to the [value] via
  /// `BlocScope.of(context)`.
  /// When `BlocScope.value` is used, the [Bloc]
  /// will not be automatically closed.
  /// As a result, `BlocScope.value` should only be used for providing
  /// existing instances to new subtrees.
  ///
  /// A new [Bloc] should not be created in `BlocScope.value`.
  /// New instances should always be created using the
  /// default constructor within the [Create] function.
  ///
  /// ```dart
  /// BlocScope.value(
  ///   value: BlocScope.of<BlocA>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  BlocScope.value({
    required T value,
    this.child,
    Key? key,
  })  : _value = value,
        _create = null,
        super(key: key);

  /// Widget which will have access to the [Bloc].
  final Widget? child;

  final Create<T>? _create;

  final T? _value;

  /// Method that allows widgets to access a [Bloc] instance
  /// as long as their `BuildContext` contains a [BlocScope] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocScope.of<BlocA>(context);
  /// ```
  static T of<T extends IStateObservable<Object?>>(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return Scope.of<T>(
        context,
        listen: listen,
      );
    } on ScopeNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        BlocScope.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to BlocScope.of<$T>().

        This can happen if the context you used comes from a widget above the BlocScope.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final create = _create;
    if (value != null) {
      return Scope.value<T>(
        value: value,
        child: child,
      );
    } else if (create != null) {
      return Scope.create<T>(
        create: create,
        dispose: (bloc) {
          if (bloc is StreamConsumer || bloc is Sink || bloc is IBlocSink) {
            (bloc as dynamic).close();
          }
        },
        child: child,
      );
    } else {
      throw UnsupportedError('BlocScope.build without value or create');
    }
  }
}
