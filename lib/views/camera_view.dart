// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _cameraController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController.initialize();
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takeAndUploadPhoto() async {
    try {
      final XFile photo = await _cameraController.takePicture();

      final dir = await getTemporaryDirectory();
      final savedPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await photo.saveTo(savedPath);

      // await _uploadToApi(savedPath);
    } catch (e) {
      print("Gagal ambil atau upload foto: $e");
    }
  }

  // Future<void> _uploadToApi(String filePath) async {
  //   final url = Uri.parse('https://yourapi.com/upload'); // Ganti API sesuai
  //   final request = http.MultipartRequest('POST', url);
  //   request.files.add(await http.MultipartFile.fromPath('photo', filePath));

  //   final response = await request.send();

  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Upload berhasil")),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Upload gagal: ${response.statusCode}")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isInitialized
              ? Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController.value.previewSize!.height,
                        height: _cameraController.value.previewSize!.width,
                        child: CameraPreview(_cameraController),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _takeAndUploadPhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
