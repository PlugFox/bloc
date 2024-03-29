import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

void main() {
  group('MockBloc', () {
    late CounterBloc counterBloc;

    setUpAll(() {
      registerFallbackValue<CounterEvent>(CounterEvent.increment);
    });

    setUp(() {
      counterBloc = MockCounterBloc();
    });

    test('is compatible with when', () {
      when(() => counterBloc.state).thenReturn(10);
      expect(counterBloc.state, 10);
    });

    test('is compatible with listen', () {
      expect(counterBloc.stream.listen((_) {}), isA<StreamSubscription>());
    });

    test('is compatible with emit', () {
      counterBloc.setState(10);
    });

    test('is compatible with add', () {
      counterBloc.add(CounterEvent.increment);
    });

    test('is compatible with addError without StackTrace', () {
      counterBloc.addError(Exception('oops'));
    });

    test('is compatible with addError with StackTrace', () {
      counterBloc.addError(Exception('oops'), StackTrace.empty);
    });

    test('is compatible with onEvent', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onEvent(CounterEvent.increment);
    });

    test('is compatible with onError', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onError(Exception('oops'), StackTrace.empty);
    });

    test('is compatible with onTransition', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onTransition(
        const Transition(
          currentState: 0,
          event: CounterEvent.increment,
          nextState: 1,
        ),
      );
    });

    test('is compatible with close', () {
      expect(counterBloc.close(), completes);
    });

    test('is compatible with mapEventToState', () {
      expect(
        counterBloc.mapEventToState(CounterEvent.increment),
        isA<Stream<int>>(),
      );
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
        counterBloc,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterBloc.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });
  });
}
