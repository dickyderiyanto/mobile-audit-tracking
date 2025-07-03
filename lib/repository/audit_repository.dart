// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:mobile_audit_tracking/core/config/api_constants.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuditRepository {
  final dbHelper = DatabaseHelper();

  Future<AuditModel> fetchAuditData(String token) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}${ApiConstants.auditEndPoint}",
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final audit = AuditModel.fromJson(jsonData['data']);

      // 🧠 Cek apakah sudah ada di database
      final exists = await dbHelper.auditExists(audit.idAudit);
      if (!exists) {
        await dbHelper.clearAuditData();
        await dbHelper.insertAudit(audit);
        print("✅ Audit data saved to SQLite");
      } else {
        print("ℹ️ Audit data already exists in SQLite");
      }

      return audit;
    } else {
      throw Exception('Failed to load audit data : ${response.statusCode}');
    }
  }

  Future<AuditModel> fetchAuditById(
    String token,
    String idAudit,
    String cif,
  ) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}${ApiConstants.auditEndPoint}/$idAudit?cif=$cif",
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return AuditModel.fromJson(jsonData['data']);
    } else {
      throw Exception(
        'Failed to load audit data by ID: ${response.statusCode}',
      );
    }
  }

  /// ⬇️ Ambil data dari SQLite (lokal)
  Future<AuditModel?> getAuditFromLocal(String auditId) async {
    return await dbHelper.getAuditById(auditId);
  }

  /// 🔁 Hapus semua data audit dari SQLite
  Future<void> clearAllLocalAudits() async {
    await dbHelper.clearAuditData();
  }

  Future<void> updateStatusVisit({
    required String auditId,
    required String userId,
    String statusVisit = "1",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse("${ApiConstants.baseUrl}/audit-status-visit");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': "Bearer $token",
      },
      body: jsonEncode({
        "id_audit": auditId,
        "user_id": userId,
        "status_visit": statusVisit,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('❌ Gagal update status visit: ${response.body}');
    }
  }
}

Future<Map<String, List<String>>> fetchFakturOptions() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.get(
    Uri.parse("${ApiConstants.baseUrl}${ApiConstants.fakturOptions}"),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    final Map<String, dynamic> body = json.decode(response.body);

    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      return data.map((key, value) {
        final List<String> options = List<String>.from(value ?? []);
        return MapEntry(key, options);
      });
    } else {
      throw Exception("Respon sukses = false");
    }
  } else {
    throw Exception(
      "Gagal fetch faktur options. Status: ${response.statusCode}",
    );
  }
}
