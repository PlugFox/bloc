// ignore_for_file: comment_references

/// The error that will be thrown if [Scope.of] fails to find a [Scope]
class ScopeNotFoundException implements Exception {
  /// Create a ScopeNotFoundException error with
  /// the type represented as a String.
  ScopeNotFoundException(this.valueType);

  /// The type of the value being retrieved
  final Type valueType;

  @override
  String toString() => 'Value type ${valueType.runtimeType} not found.';
}
