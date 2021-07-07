import 'dart:async';

import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();

  blocMain();
}

void blocMain() async {
  print('----------BLOC----------');

  /// Create a `CounterBloc` instance.
  final bloc = CounterBloc();

  /// Access the state of the `bloc` via `state`.
  print(bloc.state);

  /// Interact with the `bloc` to trigger `state` changes.
  bloc.add(CounterEvent.increment);

  /// Wait for next iteration of the event-loop
  /// to ensure event has been processed.
  await Future<void>.delayed(Duration.zero);

  /// Access the new `state`.
  print(bloc.state);

  /// Close the `bloc` when it is no longer needed.
  await bloc.close();
}

/// The events which `CounterBloc` will react to.
enum CounterEvent { increment }

/// A `CounterBloc` which handles converting `CounterEvent`s into `int`s.
class CounterBloc extends Bloc<CounterEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {

      /// When a `CounterEvent.increment` event is added,
      /// the current `state` of the bloc is accessed via the `state` property
      /// and a new state is emitted via `yield`.
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
