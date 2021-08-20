// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc/src/state_stream.dart';
import 'package:meta/meta.dart';

import 'bloc_unhandled_error_exception.dart';
import 'transition.dart';

/// Signature for a mapper function which takes an [Event] as input
/// and outputs a [Stream] of [Transition] objects.
typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event event);

/// {@template i_bloc_sink}
/// A [Bloc] Sink interface that accepts events both synchronously
/// and asynchronously.
///
/// The [IBlocSink] methods can't be used while the [addStream] is called.
/// As soon as the [addStream]'s [Future] completes with a value, the
/// [EventSink] methods can be used again.
///
/// If [addStream] is called after any of the [EventSink] methods, it'll
/// be delayed until the underlying system has consumed the data added by the
/// [EventSink] methods.
///
/// When [EventSink] methods are used, the [done] [Future] can be used to
/// catch any errors.
///
/// When [close] is called, it will return the [done] [Future].
/// {@endtemplate}
abstract class IBlocSink<Event extends Object?> implements StreamSink<Event> {
  /// Reports an [error] which triggers [onError] with an optional [StackTrace].
  /// If [close] has already been called, any subsequent calls to [addError]
  /// will be ignored and will not result in any subsequent state changes.
  @override
  @protected
  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace]);

  /// Notifies the [Bloc] of a new [event]
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
  @override
  void add(Event event);

  /// Called whenever an [event] is [add]ed to the [Bloc].
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  ///
  /// **Note: `super.onEvent` should always be called first.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  ///
  ///   // Custom onEvent logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [IBlocObserver.onEvent] for observing events globally.
  ///
  @protected
  @mustCallSuper
  @visibleForOverriding
  void onEvent(Event event);

  /// Called whenever an [error] occurs and notifies [IBlocObserver.onError].
  ///
  /// In debug mode, [onError] throws a [BlocUnhandledErrorException] for
  /// improved visibility.
  ///
  /// In release mode, [onError] does not throw and will instead only report
  /// the error to [IBlocObserver.onError].
  ///
  /// **Note: `super.onError` should always be called last.**
  /// ```dart
  /// @override
  /// void onError(Object error, StackTrace stackTrace) {
  ///   // Custom onError logic goes here
  ///
  ///   // Always call super.onError with the current error and stackTrace
  ///   super.onError(error, stackTrace);
  /// }
  /// ```
  @protected
  @mustCallSuper
  @visibleForOverriding
  void onError(Object error, StackTrace stackTrace);

  /// Closes the `event` and `state` `Streams`.
  /// This method should be called when a [Bloc] is no longer needed.
  /// Once [close] is called, `events` that are [add]ed will not be
  /// processed.
  /// In addition, if [close] is called while `events` are still being
  /// processed, the [Bloc] will finish processing the pending `events`.
  @override
  @mustCallSuper
  @visibleForOverriding
  Future<void> close();

  /// Pass all [eventStream] events to the [Bloc]
  /// If [close] has already been called, any subsequent calls to [addStream]
  /// will be ignored and will not result in any subsequent state changes.
  @override
  Future<void> addStream(Stream<Event> eventStream);

  /// Return a future which is completed when the [IBlocSink] is finished.
  ///
  /// If the `IBlocSink` fails with an error,
  /// perhaps in response to adding events using [add], [addStream], [addError]
  /// or [close], the [done] future will complete with that error.
  ///
  /// Otherwise, the returned future will complete when either:
  ///
  /// * all events have been processed and the sink has been closed, or
  /// * the sink has otherwise been stopped from handling more events
  ///   (for example by canceling a stream subscription).
  @override
  Future<void> get done;
}

/// {@template i_state_observable}
/// An interface to observe states stream.
/// Current [state] available as property.
/// State subject to implement the Observer (Dependents) pattern
/// {@endtemplate}
abstract class IStateObservable<T extends Object?> {
  /// The current [state].
  T get state;

  /// The state stream.
  StateStream<T> get stream;
}

/// {@template i_bloc_subject}
/// Interface to observe states stream.
/// Current [state] available as property.
/// [Bloc] Subject to implement the Publisher/Subscriber pattern
/// {@endtemplate}
abstract class IBlocSubject<State extends Object?>
    implements IStateObservable<State> {
  /// Updates the [state] to the provided [state].
  /// [setState] does nothing if the instance has been closed.
  @protected
  @mustCallSuper
  void setState(State state);

  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `bloc` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `bloc`.
  ///
  /// **Note: `super.onChange` should always be called first.**
  /// ```dart
  /// @override
  /// void onChange(Change change) {
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  ///
  ///   // Custom onChange logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [IBlocObserver] for observing [Bloc] behavior globally.
  @protected
  @mustCallSuper
  @visibleForOverriding
  void onChange(Change<State> change);
}

/// {@template i_bloc}
/// An interface to implement the Publisher/Subscriber pattern for [Bloc].
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class IBloc<Event extends Object?, State extends Object?>
    implements IBlocSink<Event>, IBlocSubject<State> {
  /// Transforms the [events] stream along with a [transitionFn] function into
  /// a `Stream<Transition>`.
  /// Events that should be processed by [mapEventToState] need to be passed to
  /// [transitionFn].
  /// By default `asyncExpand` is used to ensure all [events] are processed in
  /// the order in which they are received.
  /// You can override [transformEvents] for advanced usage in order to
  /// manipulate the frequency and specificity with which [mapEventToState] is
  /// called as well as which [events] are processed.
  ///
  /// For example, if you only want [mapEventToState] to be called on the most
  /// recent [Event] you can use `switchMap` instead of `asyncExpand`.
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformEvents(events, transitionFn) {
  ///   return events.switchMap(transitionFn);
  /// }
  /// ```
  ///
  /// Alternatively, if you only want [mapEventToState] to be called for
  /// distinct [events]:
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformEvents(events, transitionFn) {
  ///   return super.transformEvents(
  ///     events.distinct(),
  ///     transitionFn,
  ///   );
  /// }
  /// ```
  @visibleForOverriding
  Stream<Transition<Event, State>> transformEvents(
    Stream<Event> events,
    TransitionFunction<Event, State> transitionFn,
  );

  /// Must be implemented when a class extends [Bloc].
  /// [mapEventToState] is called whenever an [event] is [add]ed
  /// and is responsible for converting that [event] into a new [state].
  /// [mapEventToState] can `yield` zero, one, or multiple states for an event.
  @protected
  @visibleForOverriding
  Stream<State> mapEventToState(Event event);

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and [mapEventToState]
  /// executed.
  /// [onTransition] is called before a [Bloc]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  ///
  /// **Note: `super.onTransition` should always be called first.**
  /// ```dart
  /// @override
  /// void onTransition(Transition<Event, State> transition) {
  ///   // Always call super.onTransition with the current transition
  ///   super.onTransition(transition);
  ///
  ///   // Custom onTransition logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [IBlocObserver.onTransition] for observing transitions globally.
  ///
  @protected
  @mustCallSuper
  @visibleForOverriding
  void onTransition(Transition<Event, State> transition);

  /// Transforms the `Stream<Transition>` into a new `Stream<Transition>`.
  /// By default [transformTransitions] returns
  /// the incoming `Stream<Transition>`.
  /// You can override [transformTransitions] for advanced usage in order to
  /// manipulate the frequency and specificity at which `transitions`
  /// (state changes) occur.
  ///
  /// For example, if you want to debounce outgoing state changes:
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformTransitions(
  ///   Stream<Transition<Event, State>> transitions,
  /// ) {
  ///   return transitions.debounceTime(Duration(seconds: 1));
  /// }
  /// ```
  @protected
  @visibleForOverriding
  Stream<Transition<Event, State>> transformTransitions(
    Stream<Transition<Event, State>> transitions,
  );
}

/// {@template bloc}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class Bloc<Event extends Object?, State extends Object?>
    extends IBloc<Event, State> {
  /// {@macro bloc}
  Bloc(State initialState) : _state = initialState {
    _bindEventsToStates();
    _ObserverManager.observer?.onCreate(this);
  }

  /// Runs [body] in its own zone.
  /// Observing all BLoC's inside this zone with [observer] instance.
  static R observe<R extends Object?>(
    R Function() body, {
    required IBlocObserver observer,
  }) =>
      _ObserverManager.observe<R>(body, observer);

  @override
  State get state => _state;
  State _state;

  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();

  @override
  StateStream<State> get stream => StateStream<State>(_stateController.stream);
  StreamController<State>? _lazyStateController;
  StreamController<State> get _stateController =>
      _lazyStateController ??= StreamController<State>.broadcast();

  StreamSubscription<Transition<Event, State>>? _transitionSubscription;

  @override
  void onChange(Change<State> change) =>
      _ObserverManager.observer?.onChange(this, change);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      onError(error, stackTrace ?? StackTrace.current);

  @override
  void add(Event event) {
    if (_eventController.isClosed) return;
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  @override
  void onEvent(Event event) => _ObserverManager.observer?.onEvent(this, event);

  @override
  void onError(Object error, StackTrace stackTrace) {
    _ObserverManager.observer?.onError(
      this,
      error,
      stackTrace,
    );
    assert(_throwUnhandledException(
      error,
      stackTrace,
    ));
  }

  @alwaysThrows
  Never _throwUnhandledException(Object error, StackTrace stackTrace) =>
      throw BlocUnhandledErrorException(this, error, stackTrace);

  @override
  Stream<Transition<Event, State>> transformEvents(
    Stream<Event> events,
    TransitionFunction<Event, State> transitionFn,
  ) =>
      events.asyncExpand(transitionFn);

  @override
  void setState(State state) {
    if (_stateController.isClosed) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
  }

  @override
  void onTransition(Transition<Event, State> transition) =>
      _ObserverManager.observer?.onTransition(this, transition);

  @override
  Stream<Transition<Event, State>> transformTransitions(
    Stream<Transition<Event, State>> transitions,
  ) =>
      transitions;

  @override
  Future<void> close() async {
    await _eventController.close();
    await _transitionSubscription?.cancel();
    _ObserverManager.observer?.onClose(this);
    await _stateController.close();
  }

  @override
  Future<void> addStream(Stream<Event> eventStream) =>
      _eventController.addStream(eventStream);

  @override
  Future<void> get done => _eventController.done;

  void _bindEventsToStates() => _transitionSubscription = transformTransitions(
        transformEvents(
          _eventController.stream,
          (event) => mapEventToState(event).map(
            (nextState) => Transition(
              currentState: state,
              event: event,
              nextState: nextState,
            ),
          ),
        ),
      ).listen(
        (transition) {
          try {
            onTransition(transition);
            setState(transition.nextState);
          } on Object catch (error, stackTrace) {
            onError(error, stackTrace);
          }
        },
        onError: onError,
        cancelOnError: false,
      );
}

/// Observe BLoC's with [IBlocObserver]
@protected
abstract class _ObserverManager {
  const _ObserverManager._();

  /// Observe all zone BLoC's with [observer]
  @internal
  static R observe<R extends Object?>(
    R Function() body,
    IBlocObserver observer,
  ) =>
      runZoned<R>(
        body,
        zoneValues: <Type, IBlocObserver>{
          _ObserverManager: observer,
        },
      );

  /// Get current BlocObserver for nearest zone
  @internal
  static IBlocObserver? get observer {
    Zone? zone = Zone.current;
    while (zone != null) {
      final Object? observer = zone[_ObserverManager];
      if (observer is IBlocObserver) {
        return observer;
      }
      zone = zone.parent;
    }
    return null;
  }
}
