part of 'sos_bloc.dart';

abstract class SosEvent {}

class SosListenerStarted extends SosEvent {
  final String flatId;
  final String currentUserUid;
  SosListenerStarted({required this.flatId, required this.currentUserUid});
}

class SosAlertDismissed extends SosEvent {
  final String alertId;
  SosAlertDismissed(this.alertId);
}
