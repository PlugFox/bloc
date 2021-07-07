import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock Bloc
class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue<CounterEvent>(CounterEvent.increment);
  });
  mainBloc();
}

void mainBloc() {
  group('whenListen', () {
    test("Let's mock the CounterBloc's stream!", () {
      // Create Mock CounterBloc Instance
      final bloc = MockCounterBloc();

      // Stub the listen with a fake Stream
      whenListen(bloc, Stream.fromIterable([0, 1, 2, 3]));

      // Expect that the CounterBloc instance emitted the stubbed Stream of
      // states
      expectLater(bloc.stream, emitsInOrder(<int>[0, 1, 2, 3]));
    });
  });

  group('CounterBloc', () {
    blocTest<CounterBloc, int>(
      'emits [] when nothing is added',
      build: () => CounterBloc(),
      expect: () => const <int>[],
    );

    blocTest<CounterBloc, int>(
      'emits [1] when CounterEvent.increment is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      expect: () => const <int>[1],
    );
  });
}

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
