// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/camera/camera_bloc.dart';
import '../database/database_helper.dart';

class PreviewCameraScreen extends StatelessWidget {
  final XFile imageFile;
  final String idAudit;
  final String cif;
  final double latitude;
  final double longitude;

  const PreviewCameraScreen({
    super.key,
    required this.imageFile,
    required this.idAudit,
    required this.cif,
    required this.latitude,
    required this.longitude,
  });

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
                              final isOnline = await isConnected();
                              if (isOnline) {
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
                              } else {
                                // Simpan ke SQLite
                                final db = DatabaseHelper();
                                await db.insertOfflinePhoto(
                                  auditId: idAudit,
                                  cif: cif,
                                  filePath: imageFile.path,
                                  latitude: latitude.toString(),
                                  longitude: longitude.toString(),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("📷 Foto disimpan offline"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );

                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              }
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

Future<bool> isConnected() async {
  try {
    final result = await InternetAddress.lookup('audit.jessindo.net');
    final connected = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    print("🌐 Internet status: $connected");
    return connected;
  } catch (e) {
    print("🚫 Tidak ada koneksi internet: $e");
    return false;
  }
}
