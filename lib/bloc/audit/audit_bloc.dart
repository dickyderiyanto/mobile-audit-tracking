import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
import 'package:mobile_audit_tracking/repository/audit_repository.dart';

part 'audit_event.dart';
part 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository repository;
  AuditBloc(this.repository) : super(AuditInitial()) {
    on<FetchAuditData>((event, emit) async {
      emit(AuditLoading());
      try {
        final data = await repository.fetchAuditData(event.token);
        emit(AuditLoaded(data));
      } catch (e) {
        emit(AuditError(e.toString()));
      }
    });
  }
}
