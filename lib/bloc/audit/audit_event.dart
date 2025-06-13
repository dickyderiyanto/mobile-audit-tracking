part of 'audit_bloc.dart';

@immutable
sealed class AuditEvent {}

class FetchAuditData extends AuditEvent {
  final String token;
  FetchAuditData(this.token);
}
