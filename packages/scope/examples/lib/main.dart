import 'package:flutter/material.dart';
import 'package:scope/scope.dart';

void main() {
  GlobalScope.inject('Hello world');
  GlobalScope.inject(1);
  runApp(const App());
}

@immutable
class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiScope(
        scopes: [
          Scope.value<String>(value: 'Hello world'),
          Scope.value<int>(value: 3),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: ResultColumn(),
              ),
            ),
          ),
        ),
      );
}

@immutable
class ResultColumn extends StatelessWidget {
  const ResultColumn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ZonedScope.inject<Widget>(
          () => Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('GlobalScope: '),
                      Text(GlobalScope.read<String>()!),
                      const Text(' #'),
                      Text(GlobalScope.read<int>().toString()),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('ZonedScope: '),
                      Text(ZonedScope.read<String>()!),
                      const Text(' #'),
                      Text(ZonedScope.read<int>().toString()),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('Scope: '),
                      Text(Scope.maybeOf<String>(context) ?? '?'),
                      const Text(' #'),
                      Text(Scope.maybeOf<int>(context)?.toString() ?? '?'),
                    ],
                  ),
                ],
              ),
          <Object>[
            'Hello world',
            2,
          ]);
}
