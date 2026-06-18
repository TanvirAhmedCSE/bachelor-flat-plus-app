import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/sos_alert_model.dart';
import '../../services/firestore_service.dart';
part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  final Set<String> _shownAlerts = {};

  SosBloc() : super(SosIdle()) {
    on<SosListenerStarted>(_onListenerStarted);
    on<SosAlertDismissed>(_onAlertDismissed);
  }

  Future<void> _onListenerStarted(
    SosListenerStarted event,
    Emitter<SosState> emit,
  ) async {
    await emit.forEach<List<SosAlertModel>>(
      FirestoreService.getActiveSosAlerts(event.flatId),
      onData: (alerts) {
        for (final id in List.of(_shownAlerts)) {
          final stillActive = alerts.any((a) => a.id == id && a.isActive);
          if (!stillActive) {
            _shownAlerts.remove(id);
            return SosAlertCancelled(id);
          }
        }

        for (final alert in alerts) {
          if (!_shownAlerts.contains(alert.id) &&
              alert.victimUid != event.currentUserUid) {
            _shownAlerts.add(alert.id);
            return SosAlertReceived(alert);
          }
        }

        return SosIdle();
      },
    );
  }

  void _onAlertDismissed(SosAlertDismissed event, Emitter<SosState> emit) {
    emit(SosIdle());
  }
}
