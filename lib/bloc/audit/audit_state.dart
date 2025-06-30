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

class AuditDetailLoaded extends AuditState {
  final List<AuditDetail> details;

  AuditDetailLoaded(this.details);
}

class AuditDetailError extends AuditState {
  final String message;

  AuditDetailError(this.message);
}
