import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/camera/camera_bloc.dart';

class PreviewCameraScreen extends StatelessWidget {
  final XFile imageFile;
  final String idAudit;
  final String cif;
  final double latitude;
  final double longitude;

  const PreviewCameraScreen({
    Key? key,
    required this.imageFile,
    required this.idAudit,
    required this.cif,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraBloc, CameraState>(
      listener: (context, state) {
        if (state is CameraUploadSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Upload berhasil")));
        } else if (state is CameraUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload gagal: ${state.message}")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Preview Photo')),
        body: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: Image.file(File(imageFile.path))),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      state is CameraUploading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text("Upload Photo"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () async {
                              context.read<CameraBloc>().add(
                                TakePhotoEvent(
                                  context: context,
                                  photo: imageFile,
                                  idAudit: idAudit,
                                  cif: cif,
                                  latitude: latitude,
                                  longitude: longitude,
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
