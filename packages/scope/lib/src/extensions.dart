import 'package:flutter/widgets.dart' show BuildContext;

import 'exceptions.dart';
import 'scope.dart' show Scope;

/// Exposes BuildContext method to [read].
extension BuildContextScopeX on BuildContext {
  /// Obtain a value from the nearest ancestor scope of type [T].
  ///
  /// In opposite of [watch] it will _not_ make widget rebuild when the value changes
  /// and can be called outside [StatelessWidget.build], [State.build] and [State.didChangeDependencies].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// Scope.of<T>(context, listen: false)
  /// ```
  ///
  /// **DON'T** call [read] inside build if the value is used only for events:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // counter is used only for the onPressed of RaisedButton
  ///   final counter = context.read<Counter>();
  ///
  ///   return RaisedButton(
  ///     onPressed: () => counter.increment(),
  ///   );
  /// }
  /// ```
  ///
  /// While this code is not bugged in itself, this is an anti-pattern.
  /// It could easily lead to bugs in the future after refactoring the widget
  /// to use `counter` for other things, but forget to change [read] into [watch].
  ///
  /// **CONSIDER** calling [read] inside event handlers:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return RaisedButton(
  ///     onPressed: () {
  ///       // as performant as the previous solution, but resilient to refactoring
  ///       context.read<Counter>().increment(),
  ///     },
  ///   );
  /// }
  /// ```
  ///
  /// This has the same efficiency as the previous anti-pattern, but does not
  /// suffer from the drawback of being brittle.
  ///
  /// **DON'T** use [read] for creating widgets with a value that never changes
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // using read because we only use a value that never changes.
  ///   final model = context.read<Model>();
  ///
  ///   return Text('${model.valueThatNeverChanges}');
  /// }
  /// ```
  ///
  /// While the idea of not rebuilding the widget if something else changes is
  /// good, this should not be done with [read].
  /// Relying on [read] for optimisations is very brittle and dependent
  /// on an implementation detail.
  ///
  /// **CONSIDER** using [select] for filtering unwanted rebuilds
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // Using select to listen only to the value that used
  ///   final valueThatNeverChanges = context.select((Model model) => model.valueThatNeverChanges);
  ///
  ///   return Text('$valueThatNeverChanges');
  /// }
  /// ```
  ///
  /// While more verbose than [read], using [select] is a lot safer.
  /// It does not rely on implementation details on `Model`, and it makes
  /// impossible to have a bug where our UI does not refresh.
  ///
  /// ## Using [read] to simplify objects depending on other objects
  ///
  /// This method can be freely passed to objects, so that they can read scopes
  /// without having a reference on a [BuildContext].
  ///
  /// For example, instead of:
  ///
  /// ```dart
  /// class Model {
  ///   Model(this.context);
  ///
  ///   final BuildContext context;
  ///
  ///   void method() {
  ///     print(Scope.of<Whatever>(context));
  ///   }
  /// }
  ///
  /// // ...
  ///
  /// Scope(
  ///   create: (context) => Model(context),
  ///   child: ...,
  /// )
  /// ```
  ///
  /// we will prefer to write:
  ///
  /// ```dart
  /// class Model {
  ///   Model(this.read);
  ///
  ///   // `Locator` is a typedef that matches the type of `read`
  ///   final Locator read;
  ///
  ///   void method() {
  ///     print(read<Whatever>());
  ///   }
  /// }
  ///
  /// // ...
  ///
  /// Scope(
  ///   create: (context) => Model(context.read),
  ///   child: ...,
  /// )
  /// ```
  ///
  /// Both snippets behaves the same. But in the second snippet, `Model` has no dependency
  /// on Flutter/[BuildContext]/scope.
  ///
  /// See also:
  ///
  /// - [watch] method, similar to [read], but will make the widget tree rebuild
  ///   when the obtained value changes.
  T read<T extends Object>({final T Function()? orElse}) {
    final value = Scope.maybeOf<T>(this, listen: false);
    if (value != null) {
      return value;
    } else if (orElse != null) {
      return orElse();
    }
    throw ScopeNotFoundException(T);
  }

  /// Obtain a value from the nearest ancestor scope of type [T] and subscribe to the scope.
  ///
  /// If no matching scopes are found, [watch] will searches in [GlobalScope].read<T>().
  ///
  /// Throw [ScopeNotFoundException] if [T] does not exist.
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// Scope.of<T>(context, listen: true)
  /// ```
  /// This method is accessible only inside [StatelessWidget.build], [State.build],
  /// and [State.didChangeDependencies].\
  /// If you need to use it outside of these methods, consider using [Scope.of]
  /// instead, which doesn't have this restriction.\
  ///
  /// See also:
  ///
  /// - [read] method, similar to [watch], but doesn't make widgets rebuild if the value
  ///   obtained changes.
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
