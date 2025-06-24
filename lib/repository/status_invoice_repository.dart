// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:mobile_audit_tracking/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice_status_model.dart' show InvoiceStatusModel;

class StatusInvoiceRepository {
  Future<String> updateInvoiceStatus(InvoiceStatusModel request) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}${ApiConstants.statusInvoiceEndPoint}",
    );
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    print('Payload dikirim: ${jsonEncode(request.toJson())}');
    print('URL: $url');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal Update invoice');
    }
  }

  Future<void> postKeteranganToko(
    String auditId,
    String cif,
    String keterangan,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/audit-cif/keterangan');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "audit_id": auditId,
        "cif": cif,
        "keterangan": keterangan,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal kirim keterangan toko');
    }
  }
}
