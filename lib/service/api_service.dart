import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {


  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<Map<String, dynamic>> predictLandmark(
      File image) async {

    final uri = Uri.parse('$baseUrl/predict');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data;
    }

    throw Exception(
      'Prediction failed: ${response.body}',
    );
  }
}