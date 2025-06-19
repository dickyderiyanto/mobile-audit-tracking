import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../repository/camera_repository.dart'; // Sesuaikan path

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraRepository repository;

  CameraBloc(this.repository) : super(CameraInitial()) {
    on<TakePhotoEvent>((event, emit) async {
      emit(CameraUploading());

      try {
        await repository.uploadPhoto(
          context: event.context,
          imageFile: event.photo,
          idAudit: event.idAudit,
          cif: event.cif,
          latitude: event.latitude,
          longitude: event.longitude,
        );
        emit(CameraUploadSuccess());
      } catch (e) {
        emit(CameraUploadFailure(e.toString()));
      }
    });
  }
}
