part of 'camera_bloc.dart';

@immutable
sealed class CameraEvent {}

class TakePhotoEvent extends CameraEvent {
  final BuildContext context;
  final XFile photo;
  final String idAudit;
  final String cif;
  final double latitude;
  final double longitude;

  TakePhotoEvent({
    required this.context,
    required this.photo,
    required this.idAudit,
    required this.cif,
    required this.latitude,
    required this.longitude,
  });
}
