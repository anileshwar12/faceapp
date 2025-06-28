import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../widgets/face_result_card.dart';
import '../domain/face_detection_service.dart';
import '../models/detection_result.dart';

class FaceDetectionScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceDetectionScreen({super.key, required this.camera});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isDetecting = false;
  Timer? _timer;
  final picker = ImagePicker();
  DetectionResult? _result;
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

      await _fetchDetections(File(filePath));
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _fetchDetections(File(picked.path));
    }
  }

  Future<void> _fetchDetections(File file) async {
    final result = await _service.detect(file);
    setState(() {
      _result = result;
    });
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
                CameraPreview(_controller),
                Center(
                  child: Lottie.asset('assets/face_tracking.json', height: 250),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_result != null)
                        FaceResultCard(result: _result!)
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Analyzing...",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
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
