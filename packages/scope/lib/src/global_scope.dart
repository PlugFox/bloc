import 'package:meta/meta.dart';

/// Global scope
@experimental
class GlobalScope {
  /// Singleton
  factory GlobalScope.singleton() => _instance ??= GlobalScope._();

  GlobalScope._();

  static GlobalScope? _instance;
}
