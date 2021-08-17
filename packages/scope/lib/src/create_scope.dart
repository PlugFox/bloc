// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'inherited_scope.dart';
import 'interface_scope.dart';

@internal
@immutable
class CreateScope<T extends Object> extends StatefulWidget
    implements IScope<T> {
  const CreateScope(
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
  IScope<T> copyWith({
    Create<T>? newCreate,
    Update<T>? newUpdate,
    Dispose<T>? newDispose,
    Widget? newChild,
    UpdateShouldNotify<T>? newShouldNotify,
    TransitionBuilder? newBuilder,
    Key? newKey,
  }) =>
      CreateScope(
        newCreate ?? create,
        newUpdate ?? update,
        newDispose ?? dispose,
        newBuilder ?? builder,
        newChild ?? child,
        newShouldNotify ?? shouldNotify,
        newKey ?? key,
      );

  @override
  StatefulElement createElement() => _CreateScopeElement(this);

  @override
  State<CreateScope<T>> createState() => _CreateScopeState<T>();
}

class _CreateScopeState<T extends Object> = State<CreateScope<T>>
    with _CreateScopeValueMixin<T>, _CreateScopeBuildMixin<T>;

mixin _CreateScopeValueMixin<T extends Object> on State<CreateScope<T>> {
  T? _value;
  T? get value => _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldValue = value;
    final update = widget.update;
    if (value != null && update != null) {
      _value = update(context, oldValue);
    } else {
      _value = widget.create(context);
    }
  }

  @override
  void dispose() {
    final dispose = widget.dispose;
    if (dispose != null) {
      dispose(value!);
    } else if (value is Sink || value is StreamConsumer) {
      (value as dynamic).close();
    }
    super.dispose();
  }
}

mixin _CreateScopeBuildMixin<T extends Object>
    on State<CreateScope<T>>, _CreateScopeValueMixin<T> {
  @override
  Widget build(BuildContext context) => InheritedScope<T>(
        value: value!,
        child: widget.builder?.call(context, widget.child) ??
            widget.child ??
            scopePlaceholder,
        shouldNotify: widget.shouldNotify,
      );
}

class _CreateScopeElement<T extends Object> extends StatefulElement {
  _CreateScopeElement(CreateScope<T> widget) : super(widget);

  @override
  CreateScope<T> get widget => super.widget as CreateScope<T>;

  @override
  _CreateScopeState<T> get state => super.state as _CreateScopeState<T>;

  T? get value => state.value;
}
