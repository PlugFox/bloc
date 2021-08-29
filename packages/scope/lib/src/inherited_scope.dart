// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'interface_scope.dart';

@internal
@immutable
class InheritedScope<T extends Object> extends InheritedWidget {
  const InheritedScope({
    required this.value,
    required Widget child,
    required this.shouldNotify,
    Key? key,
  }) : super(key: key, child: child);

  final T value;

  static T? of<T extends Object>(BuildContext ctx, bool listen) =>
      listen ? watch<T>(ctx) : read<T>(ctx);

  static T? watch<T extends Object>(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<InheritedScope<T>>()?.value;

  static T? read<T extends Object>(BuildContext ctx) {
    final e = ctx.getElementForInheritedWidgetOfExactType<InheritedScope<T>>();
    final w = e?.widget;
    return w is InheritedScope<T> ? w.value : null;
  }

  final UpdateShouldNotify<T>? shouldNotify;

  @override
  bool updateShouldNotify(covariant InheritedScope<T> oldWidget) {
    final prev = oldWidget.value;
    final next = value;
    if (identical(prev, value)) {
      return false;
    }
    return shouldNotify?.call(prev, next) ?? prev != next;
  }
}
