import 'dart:io';

import 'package:faceapp/utils/api_client.dart';
import 'package:faceapp/features/models/detection_result.dart';

class FaceDetectionService {
  final ApiClient _apiClient = ApiClient();

  Future<DetectionResult> detect(File imageFile) async {
    final detectResponse = await _apiClient.sendImageToDetectAPI(imageFile);
    final emotionResponse = await _apiClient.sendImageToEmotionAPI(imageFile);

    String age = "Unknown";
    String gender = "Unknown";
    String emotion = "Unknown";

    if (detectResponse != null && detectResponse.isNotEmpty) {
      final face = detectResponse[0];
      age = face['age']?.toStringAsFixed(1) ?? "Unknown";
      gender = face['gender']?['value'] ?? "Unknown";
    }

    if (emotionResponse != null &&
        emotionResponse['status'] == 'success' &&
        (emotionResponse['faces'] as List).isNotEmpty) {
      final face = emotionResponse['faces'][0];
      emotion = face['dominant_emotion'] ?? "Unknown";
    }

    return DetectionResult(
      dominantEmotion: emotion,
      age: age,
      gender: gender,
    );
  }
}
