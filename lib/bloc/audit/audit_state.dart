part of 'audit_bloc.dart';

@immutable
sealed class AuditState {}

final class AuditInitial extends AuditState {}

final class AuditLoading extends AuditState {}

final class AuditLoaded extends AuditState {
  final AuditModel audit;
  AuditLoaded(this.audit);
}

final class AuditError extends AuditState {
  final String message;
  AuditError(this.message);
}
