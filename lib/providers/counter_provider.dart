import 'package:flutter/cupertino.dart';

class CounterState {
  int _value = 1;

  int get value => _value;

  void inc() => _value++;
  void dec() => _value--;

  //retorna true se old._value (bool) é diferente de _value (objeto)
  bool diff(CounterState old) => old == null || old._value != _value;
}

class CounterProvider extends InheritedWidget {
  final CounterState state = CounterState();

  CounterProvider({Widget child}) : super(child: child);

  static CounterProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CounterProvider>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
