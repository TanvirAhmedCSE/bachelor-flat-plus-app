part of 'bazar_bloc.dart';

abstract class BazarEvent {}

class BazarInitialized extends BazarEvent {}

class BazarMonthChanged extends BazarEvent {
  final int month;
  BazarMonthChanged(this.month);
}
