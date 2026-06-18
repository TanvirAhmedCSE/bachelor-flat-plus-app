part of 'home_bloc.dart';

abstract class HomeEvent {}

class HomeUserLoaded extends HomeEvent {}

class HomeJoinRequestSubmitted extends HomeEvent {
  final String flatCode;
  HomeJoinRequestSubmitted(this.flatCode);
}
