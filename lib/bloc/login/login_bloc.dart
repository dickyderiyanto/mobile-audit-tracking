// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile_audit_tracking/models/login_model.dart';
import 'package:mobile_audit_tracking/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthRepository repository;
  LoginBloc(this.repository) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final data = await repository.fetchLoginData(
          LoginRequestModel(username: event.username, password: event.password),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data.accessToken);
        await prefs.setString('user_id', data.userId);
        await prefs.setString('role_code', data.roleCode);

        emit(LoginSuccess(data));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
