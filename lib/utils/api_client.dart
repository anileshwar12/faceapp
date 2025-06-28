import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String token = "API_KEY";

  Future<List<dynamic>?> sendImageToDetectAPI(File imageFile) async {
    const url = "https://api.luxand.cloud/photo/detect";

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['token'] = token
      ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendImageToEmotionAPI(File imageFile) async {
    const url = "https://api.luxand.cloud/photo/emotions";

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['token'] = token
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
