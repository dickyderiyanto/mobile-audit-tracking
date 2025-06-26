part of 'audit_bloc.dart';

@immutable
sealed class AuditEvent {}

class FetchAuditData extends AuditEvent {
  final String token;
  FetchAuditData(this.token);
}

class FetchAuditDataById extends AuditEvent {
  final String token;
  final String idAudit;
  final String cif;

  FetchAuditDataById(this.token, this.idAudit, this.cif);
}
