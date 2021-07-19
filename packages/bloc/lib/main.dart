import 'bloc.dart';

void main() => Bloc.observe(
      () => MyBloc().add(1),
      observer: Observer(),
    );

///
class MyBloc extends Bloc<int, String> {
  ///
  MyBloc() : super('');

  @override
  Stream<String> mapEventToState(int event) {
    throw UnsupportedError('123');
  } //Stream.value(event.toString());

}

///
class Observer extends IBlocObserver {
  @override
  void onCreate(IBloc<Object?, Object?> bloc) {
    print(bloc);
    super.onCreate(bloc);
  }
}
