import 'dart:convert';

import 'package:mobile_audit_tracking/core/config/api_constants.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mobile_audit_tracking/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<LoginModel> fetchLoginData(LoginRequestModel request) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}${ApiConstants.loginEndPoint}",
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        LoginRequestModel(
          username: request.username,
          password: request.password,
        ).toJson(),
      ),
    );
    print(response);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LoginModel.fromJson(json['data']);
    } else {
      throw Exception('Failed to load user data : ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
