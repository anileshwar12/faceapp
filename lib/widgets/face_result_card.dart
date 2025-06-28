import 'package:flutter/material.dart';
import 'package:faceapp/features/models/detection_result.dart';

class FaceResultCard extends StatelessWidget {
  final DetectionResult? result;
  final VoidCallback? onUploadPressed;

  const FaceResultCard({super.key, this.result, this.onUploadPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result != null
                ? "Emotion: ${result!.dominantEmotion}\n"
                      "Age: ${result!.age}\n"
                      "Gender: ${result!.gender}"
                : "Analyzing...",
            style: TextStyle(
              fontSize: 20,
              color: Colors.teal[700],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onUploadPressed,
            icon: const Icon(Icons.upload),
            label: const Text("Upload from Gallery"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
