import 'dart:convert';

import 'package:mobile_audit_tracking/core/config/api_constants.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class AuditRepository {
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
      return AuditModel.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load audit data : ${response.statusCode}');
    }
  }
}
