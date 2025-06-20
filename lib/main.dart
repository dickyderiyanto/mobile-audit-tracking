// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/camera/camera_bloc.dart';
import 'package:mobile_audit_tracking/bloc/login/login_bloc.dart';
import 'package:mobile_audit_tracking/repository/auth_repository.dart';
import 'package:mobile_audit_tracking/repository/camera_repository.dart';
import 'package:mobile_audit_tracking/repository/user_info_repository.dart';
import 'package:mobile_audit_tracking/views/audit_view.dart';
import 'package:mobile_audit_tracking/views/home_view.dart';
import 'package:mobile_audit_tracking/views/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/user_info/user_info_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = AuthRepository();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(
    MyApp(
      authRepository: authRepository,
      initialToken: token,
      userInfoRepository: UserInfoRepository(),
      cameraRepository: CameraRepository(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  final AuthRepository authRepository;
  final UserInfoRepository userInfoRepository;
  final CameraRepository cameraRepository;
  const MyApp({
    super.key,
    required this.authRepository,
    required this.initialToken,
    required this.userInfoRepository,
    required this.cameraRepository,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc(authRepository)),
        BlocProvider(create: (context) => UserInfoBloc(userInfoRepository)),
        BlocProvider(create: (context) => CameraBloc(cameraRepository)),
      ],
      child: MaterialApp(
        title: 'Audit Tracking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 12, 10, 17),
          ),
        ),
        home: initialToken != null ? HomeView() : LoginView(),
        routes: {
          '/home': (context) => AuditView(token: initialToken!),
          '/audit-view': (context) => AuditView(token: initialToken!),
        },
      ),
    );
  }
}
