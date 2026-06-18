part of 'sos_bloc.dart';

abstract class SosState {}

class SosIdle extends SosState {}

class SosAlertReceived extends SosState {
  final SosAlertModel alert;
  SosAlertReceived(this.alert);
}

class SosAlertCancelled extends SosState {
  final String alertId;
  SosAlertCancelled(this.alertId);
}
