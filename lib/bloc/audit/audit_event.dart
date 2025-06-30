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

class LoadAuditFromLocal extends AuditEvent {
  final String auditId;
  LoadAuditFromLocal(this.auditId);
}

class LoadAuditDetailsByCIF extends AuditEvent {
  final String auditId;
  final String cif;

  LoadAuditDetailsByCIF({required this.auditId, required this.cif});
}

class UpdateVisitStatusOffline extends AuditEvent {
  final String auditId;
  final String invoiceCode;
  final String visitStatus;

  UpdateVisitStatusOffline({
    required this.auditId,
    required this.invoiceCode,
    required this.visitStatus,
  });
}
