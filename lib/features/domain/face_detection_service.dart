import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:faceapp/features/models/detection_result.dart';

class FaceDetectionService {
  static const _detectUrl = "https://api.luxand.cloud/photo/detect";
  static const _emotionUrl = "https://api.luxand.cloud/photo/emotions";
  static const _token = "24546598ae9d4802a0dded847d128a94";

  Future<DetectionResult> detectFaceDetails(File imageFile) async {
    final detectResult = await _callDetectAPI(imageFile);
    final emotionResult = await _callEmotionAPI(imageFile);

    String age = "Unknown";
    String gender = "Unknown";
    String emotion = "Unknown";

    if (detectResult != null && detectResult.isNotEmpty) {
      final face = detectResult[0];
      age = face['age']?.toStringAsFixed(1) ?? "Unknown";
      gender = face['gender']?['value'] ?? "Unknown";
    }

    if (emotionResult != null &&
        emotionResult['status'] == 'success' &&
        (emotionResult['faces'] as List).isNotEmpty) {
      final face = emotionResult['faces'][0];
      emotion = face['dominant_emotion'] ?? "Unknown";
    }

    return DetectionResult(dominantEmotion: emotion, age: age, gender: gender);
  }

  Future<List<dynamic>?> _callDetectAPI(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(_detectUrl))
      ..headers['token'] = _token
      ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _callEmotionAPI(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(_emotionUrl))
      ..headers['token'] = _token
      ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }
}
