// ignore_for_file: public_member_api_docs, sort_constructors_first
class LoginModel {
  final String accessToken;
  final String tokenType;
  final String userId;
  final String roleCode;

  LoginModel({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.roleCode,
  });

  //json decode
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      userId: json['user_id'],
      roleCode: json['role_code'],
    );
  }
}

class LoginRequestModel {
  final String username;
  final String password;

  LoginRequestModel({required this.username, required this.password});

  // json encode
  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
