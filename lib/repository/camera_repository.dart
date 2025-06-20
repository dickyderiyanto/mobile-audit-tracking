// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_audit_tracking/core/config/api_constants.dart';
import 'package:mobile_audit_tracking/views/home_view.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraRepository {
  Future<void> uploadPhoto({
    required BuildContext context,
    required XFile imageFile,
    required String idAudit,
    required String cif,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final fixedCif = cif.replaceAll('/', '-');
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/checkin-visit/$idAudit/$fixedCif",
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..headers.addAll({
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            })
            ..fields['visit_latitude'] = latitude.toString()
            ..fields['visit_longitude'] = longitude.toString()
            ..files.add(
              await http.MultipartFile.fromPath(
                'checkin_image', // harus sama persis dengan key di Postman
                imageFile.path,
                filename: path.basename(imageFile.path),
              ),
            );

      print('Sending request to $uri');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.map((f) => f.filename)}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Token tidak ditemukan.")),
          );
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeView()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saat upload: $e")));
    }
  }
}
