import 'dart:convert';

import 'package:mobile_audit_tracking/core/config/api_constants.dart';
import 'package:mobile_audit_tracking/models/user_info.dart';
import 'package:http/http.dart' as http;

class UserInfoRepository {
  Future<UserInfo> fetchUserInfo(String token) async {
    final url = ("${ApiConstants.baseUrl}${ApiConstants.userInfoEndPoint}");
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserInfo.fromJson(json['data']);
    } else {
      throw Exception("Gagal memuat data user");
    }
  }
}
