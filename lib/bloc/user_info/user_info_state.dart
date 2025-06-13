part of 'user_info_bloc.dart';

@immutable
sealed class UserInfoState {}

final class UserInfoInitial extends UserInfoState {}

final class UserInfoLoading extends UserInfoState {}

final class UserInfoLoaded extends UserInfoState {
  final UserInfo userInfo;
  UserInfoLoaded(this.userInfo);
}

final class UserInfoError extends UserInfoState {
  final String message;
  UserInfoError(this.message);
}
