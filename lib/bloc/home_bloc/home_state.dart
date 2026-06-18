part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeUserActive extends HomeState {
  final UserModel user;
  HomeUserActive(this.user);
}

class HomeUserPending extends HomeState {
  final UserModel user;
  HomeUserPending(this.user);
}

class HomeUserRemoved extends HomeState {}

class HomeJoinRequestSent extends HomeState {}

class HomeFailure extends HomeState {
  final String message;
  HomeFailure(this.message);
}
