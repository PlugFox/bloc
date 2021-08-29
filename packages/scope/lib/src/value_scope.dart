// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'inherited_scope.dart';
import 'interface_scope.dart';

@internal
@immutable
class ValueScope<T extends Object> extends StatelessWidget
    implements IScope<T> {
  const ValueScope(
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
  IScope<T> copyWith({
    T? newValue,
    Widget? newChild,
    UpdateShouldNotify<T>? newShouldNotify,
    TransitionBuilder? newBuilder,
    Key? newKey,
  }) =>
      ValueScope(
        newValue ?? value,
        newBuilder ?? builder,
        newChild ?? child,
        newShouldNotify ?? shouldNotify,
        newKey ?? key,
      );

  @override
  StatelessElement createElement() => _ValueScopeElement<T>(this);

  @override
  Widget build(BuildContext context) => InheritedScope<T>(
        value: value,
        child: builder?.call(context, child) ?? child ?? scopePlaceholder,
        shouldNotify: shouldNotify,
      );
}

class _ValueScopeElement<T extends Object> extends StatelessElement {
  _ValueScopeElement(ValueScope<T> widget) : super(widget);

  T get value => (super.widget as ValueScope<T>).value;
}
