import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';

import 'package:faceapp/features/face_detection.dart';
import 'package:faceapp/widgets/widgets.dart';

class FaceDetectionScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceDetectionScreen({super.key, required this.camera});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  DetectionResult? _result;
  bool _isDetecting = false;
  Timer? _timer;
  final picker = ImagePicker();
  final _service = FaceDetectionService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      startAutoDetection();
    });
  }

  void startAutoDetection() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isDetecting) return;
      await detectFromCamera();
    });
  }

  Future<void> detectFromCamera() async {
    try {
      setState(() {
        _isDetecting = true;
      });
      await _initializeControllerFuture;

      final XFile image = await _controller.takePicture();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(tempDir.path, '${DateTime.now()}.jpg');
      await File(image.path).copy(filePath);

      final result = await _service.detectFaceDetails(File(filePath));

      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = DetectionResult(
          dominantEmotion: "Error: $e",
          age: "Unknown",
          gender: "Unknown",
        );
      });
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final result = await _service.detectFaceDetails(File(picked.path));
      setState(() {
        _result = result;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final previewHeight = constraints.maxHeight;
                    final previewWidth = constraints.maxWidth;

                    return Stack(
                      children: [
                        SizedBox(
                          width: previewWidth,
                          height: previewHeight,
                          child: CameraPreview(_controller),
                        ),
                        Positioned(
                          left: (previewWidth / 2) - (250 / 2),
                          top: (previewHeight / 2) - (250 / 2),
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Lottie.asset('assets/face_tracking.json'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Facial Analysis",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FaceResultCard(
                    result: _result,
                    onUploadPressed: _isDetecting ? null : pickFromGallery,
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
