import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:faceapp/features/face_detection.dart';

class App extends StatelessWidget {
  final CameraDescription camera;

  const App({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FaceDetectionScreen(camera: camera),
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}
