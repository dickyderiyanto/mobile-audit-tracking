import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile_audit_tracking/models/user_info.dart';
import 'package:mobile_audit_tracking/repository/user_info_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_info_event.dart';
part 'user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final UserInfoRepository repository;
  UserInfoBloc(this.repository) : super(UserInfoInitial()) {
    on<LoadUserInfo>((event, emit) async {
      emit(UserInfoLoading());
      try {
        final userInfo = await repository.fetchUserInfo(event.token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_code', userInfo.userCode);
        emit(UserInfoLoaded(userInfo));
      } catch (e) {
        emit(UserInfoError(e.toString()));
      }
    });
  }
}
