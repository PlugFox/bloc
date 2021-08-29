import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fox_flutter_bloc/bloc.dart';

/// Custom [IBlocObserver] which observes all bloc instances.
class SimpleBlocObserver extends IBlocObserver {
  @override
  void onEvent(IBloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log(event.toString());
  }

  @override
  void onTransition(IBloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition.toString());
  }

  @override
  void onError(IBloc bloc, Object error, StackTrace stackTrace) {
    log(error.toString());
    super.onError(bloc, error, stackTrace);
  }
}

void main() => Bloc.observe(
      () => runApp(const App()),
      observer: SimpleBlocObserver(),
    );

/// A [StatelessWidget] which uses:
/// * [bloc](https://pub.dev/packages/bloc)
/// * [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  ///
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: BlocScope.create(
          create: (_) => CounterBloc(),
          child: const CounterPage(),
        ),
      );
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class CounterPage extends StatelessWidget {
  ///
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: BlocBuilder<CounterBloc, int>(
          builder: (_, count) {
            return Center(
              child:
                  Text('$count', style: Theme.of(context).textTheme.headline1),
            );
          },
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () =>
                    context.read<CounterBloc>().add(CounterEvent.increment),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                child: const Icon(Icons.remove),
                onPressed: () =>
                    context.read<CounterBloc>().add(CounterEvent.decrement),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: const Icon(Icons.error),
                onPressed: () =>
                    context.read<CounterBloc>().add(CounterEvent.error),
              ),
            ),
          ],
        ),
      );
}

/// Event being processed by [CounterBloc].
enum CounterEvent {
  /// Notifies bloc to increment state.
  increment,

  /// Notifies bloc to decrement state.
  decrement,

  /// Notifies the bloc of an error
  error,
}

/// {@template counter_bloc}
/// A simple [Bloc] which manages an `int` as its state.
/// {@endtemplate}
class CounterBloc extends Bloc<CounterEvent, int> {
  /// {@macro counter_bloc}
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.error:
        addError(UnsupportedError('Unsupported event'));
    }
  }
}
