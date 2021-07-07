import 'dart:async';

/// {@template state_stream}
/// Broadcast [State] stream view for BLoC pattern.
/// {@endtemplate}
class StateStream<State extends Object?> extends StreamView<State> {
  /// {@macro state_stream}
  ///
  /// Input stream must be broadcast.
  StateStream(Stream<State> stream)
      : assert(stream.isBroadcast, 'State stream must be broadcast'),
        super(stream);

  /// This transformer is a shorthand for Stream.where followed by Stream.cast.
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereState<T extends State>() =>
      where((state) => state is T).cast<T>();

  /// Filter with whereState<T>() and after that
  /// skips [State]'s if they are equal to the previous data event.
  Stream<T> whereUnique<T extends State>() => whereState<T>().distinct();

  ///
  ///
  ///
  Stream<T> whereStates<T extends State>(bool Function(State state) filter) =>
      where(filter).where((state) => state is T).cast<T>();

  ///
  ///
  ///
  Stream<T> whereUniques<T extends State>(bool Function(State state) filter) =>
      whereStates<T>(filter).distinct();
}
