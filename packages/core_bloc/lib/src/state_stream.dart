import 'dart:async';

/// {@template state_stream}
/// Broadcast [State] stream view for BLoC pattern.
/// {@endtemplate}
class StateStream<State extends Object?> extends Stream<State>
    with _StateStreamMixin<State>
    implements StreamView<State> {
  /// {@macro state_stream}
  ///
  /// Input stream must be broadcast.
  StateStream(Stream<State> stream)
      : assert(stream.isBroadcast, 'State stream must be broadcast'),
        _stream = stream;

  final Stream<State> _stream;

  /// This stream is always broadcast
  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<State> listen(
    void Function(State state)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError ?? false,
      );
}

mixin _StateStreamMixin<State extends Object?> on Stream<State> {
  /// This transformer is a shorthand for Stream.where followed by Stream.cast.
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereState<T extends State>() =>
      where((state) => state is T).cast<T>();

  /// Filter with whereState<T>() and after that
  /// skips [State]'s if they are equal to the previous data event.
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereUnique<T extends State>() => whereState<T>().distinct();

  /// This transformer leaves only the necessary states with downcast to [T]
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereStates<T extends State>(bool Function(T state) filter) =>
      whereState<T>().where(filter);

  /// Filter with whereStates<T>() and after that
  /// skips [State]'s if they are equal to the previous data event.
  /// Downcast states to [T]
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereUniques<T extends State>(bool Function(T state) filter) =>
      whereStates<T>(filter).distinct();

  /// Upcast this object to Stream<State>
  Stream<State> toStream() => this;
}
