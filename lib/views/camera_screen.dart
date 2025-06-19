import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'preview_camera_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String idAudit;
  final String cif;
  final double latitude;
  final double longitude;

  const CameraScreen({
    Key? key,
    required this.cameras,
    required this.idAudit,
    required this.cif,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _controller = CameraController(
      widget.cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isCameraInitialized
              ? Stack(
                children: [
                  CameraPreview(_controller),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: () async {
                          final image = await _controller.takePicture();
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PreviewCameraScreen(
                                    imageFile: image,
                                    idAudit: widget.idAudit,
                                    cif: widget.cif,
                                    latitude: widget.latitude,
                                    longitude: widget.longitude,
                                  ),
                            ),
                          );
                        },
                        child: const Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
