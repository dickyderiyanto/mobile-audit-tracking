part of 'camera_bloc.dart';

@immutable
sealed class CameraState {}

class CameraInitial extends CameraState {}

class CameraUploading extends CameraState {}

class CameraUploadSuccess extends CameraState {}

class CameraUploadFailure extends CameraState {
  final String message;

  CameraUploadFailure(this.message);
}
