import 'bloc.dart' show IBloc;

/// {@template bloc_unhandled_error_exception}
/// Exception thrown when an unhandled error occurs within a bloc.
///
/// _Note: thrown in debug mode only_
/// {@endtemplate}
class BlocUnhandledErrorException implements Exception {
  /// {@macro bloc_unhandled_error_exception}
  BlocUnhandledErrorException(
    this.bloc,
    this.error, [
    this.stackTrace = StackTrace.empty,
  ]);

  /// The bloc in which the unhandled error occurred.
  final IBloc bloc;

  /// The unhandled [error] object.
  final Object error;

  /// Stack trace which accompanied the error.
  /// May be [StackTrace.empty] if no stack trace was provided.
  final StackTrace stackTrace;

  @override
  String toString() => 'Unhandled error $error occurred in $bloc.\n'
      '$stackTrace';
}
