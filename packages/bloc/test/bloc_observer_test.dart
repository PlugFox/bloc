import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

void main() {
  final bloc = CounterBloc();
  const event = CounterEvent.increment;
  const change = Change(currentState: 0, nextState: 1);
  const transition = Transition(
    currentState: 0,
    event: CounterEvent.increment,
    nextState: 1,
  );
  group('BlocObserver', () {
    group('onCreate', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onCreate(bloc);
      });
    });

    group('onEvent', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onEvent(bloc, event);
      });
    });

    group('onChange', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onChange(bloc, change);
      });
    });

    group('onTransition', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onTransition(bloc, transition);
      });
    });

    group('onError', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onError(bloc, event, StackTrace.current);
      });
    });

    group('onClose', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        SimpleBlocObserver().onClose(bloc);
      });
    });
  });
}

class SimpleBlocObserver extends IBlocObserver {
  @override
  void onCreate(IBloc bloc) {
    super.onCreate(bloc);
    print('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(IBloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(IBloc bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(IBloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(IBloc bloc, Object error, StackTrace stackTrace) {
    print('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(IBloc bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}
