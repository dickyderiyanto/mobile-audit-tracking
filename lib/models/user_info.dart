class UserInfo {
  final String idUser;
  final String userCode;
  final String roleCode;
  final String name;
  final String username;

  UserInfo({
    required this.idUser,
    required this.userCode,
    required this.roleCode,
    required this.name,
    required this.username,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      idUser: json['id_user'],
      userCode: json['user_code'],
      roleCode: json['role_code'],
      name: json['name'],
      username: json['username'],
    );
  }
}
