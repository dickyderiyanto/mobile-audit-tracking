// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
import 'package:mobile_audit_tracking/repository/audit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_helper.dart';

part 'audit_event.dart';
part 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository repository;
  final _dbHelper = DatabaseHelper();

  AuditBloc(this.repository) : super(AuditInitial()) {
    on<FetchAuditData>((event, emit) async {
      emit(AuditLoading());
      try {
        final data = await repository.fetchAuditData(event.token);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('id_audit', data.idAudit);
        print("Saved ID AUDIT: ${data.idAudit}");
        await DatabaseHelper().clearAuditData();
        await DatabaseHelper().insertAudit(data);

        //simpan ke sqlite
        final exists = await _dbHelper.auditExists(data.idAudit);
        if (!exists) {
          await _dbHelper.clearAuditData();
          await _dbHelper.insertAudit(data);
        } else {
          // Optional: update atau clear+insert ulang kalau mau data always fresh
          await _dbHelper.clearAuditData();
          await _dbHelper.insertAudit(data);
        }
        emit(AuditLoaded(data));
      } catch (e) {
        emit(AuditError(e.toString()));
      }
    });

    on<FetchAuditDataById>((event, emit) async {
      emit(AuditLoading());
      try {
        final data = await repository.fetchAuditById(
          event.token,
          event.idAudit,
          event.cif,
        );
        emit(AuditLoaded(data));
      } catch (e) {
        emit(AuditError(e.toString()));
      }
    });

    on<LoadAuditFromLocal>((event, emit) async {
      emit(AuditLoading());

      final audit = await DatabaseHelper().getAuditById(event.auditId);
      if (audit != null) {
        emit(AuditLoaded(audit));
        print('✅ AuditLoaded dari lokal emit sukses!');
      } else {
        emit(AuditError("Audit lokal tidak ditemukan"));
        print('❌ Audit tidak ditemukan di SQLite');
      }
    });

    on<LoadAuditDetailsByCIF>((event, emit) async {
      emit(AuditLoading());
      try {
        final details = await _dbHelper.getAuditDetailsByCIF(
          event.auditId,
          event.cif,
        );
        emit(AuditDetailLoaded(details));
      } catch (e) {
        emit(AuditDetailError("Gagal load data lokal: $e"));
      }
    });

    on<UpdateVisitStatusOffline>((event, emit) async {
      try {
        await _dbHelper.updateAuditDetailStatus(
          auditId: event.auditId,
          invoiceCode: event.invoiceCode,
          visitStatus: event.visitStatus,
          payment: event.payment,
        );
        print("Visit status updated locally for ${event.invoiceCode}");
      } catch (e) {
        print("Gagal update visit status lokal: $e");
      }
    });
  }
}
