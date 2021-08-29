import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'interface_scope.dart';

/// TODO: doc
@immutable
class MultiScope extends ProxyWidget {
  /// TODO: doc
  MultiScope({
    required List<IScope> scopes,
    Widget? child,
    TransitionBuilder? builder,
    Key? key,
  }) : super(
          key: key,
          child: _buildScopesChain(
            scopes,
            Builder(
              builder: (context) =>
                  builder?.call(context, child) ?? child ?? scopePlaceholder,
            ),
          ),
        );

  static Widget _buildScopesChain(
    List<IScope> scopes,
    Widget child,
  ) =>
      scopes.reversed.fold<Widget>(
        child,
        (prev, next) {
          return next.copyWith(
            newChild: prev,
          );
        },
      );

  @override
  Element createElement() => _MultiScopeElement(this);
}

class _MultiScopeElement extends ProxyElement {
  _MultiScopeElement(ProxyWidget widget) : super(widget);

  @override
  void updated(covariant MultiScope oldWidget) {}

  @override
  void notifyClients(covariant MultiScope oldWidget) {}
}
