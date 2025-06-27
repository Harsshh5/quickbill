import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../../config/app_url.dart';

class CheckPasswordModel {
  final headers = {'Content-Type': 'application/json'};
  final uri = Uri.parse(AppUrl.checkPassword);

  Future<Map<String, dynamic>> checkPassword({
    required String businessId,
    required int inputPassword,
  }) async {
    try {

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          "businessId": businessId,
          "inputPassword": inputPassword,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        log("Password check success: ${responseBody.toString()}");

        return {
          "success": true,
          "message": responseBody['message'] ?? "Password matches",
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        log("Password check failed: ${responseBody.toString()}");

        return {
          "success": false,
          "message": responseBody['message'] ?? "Password does not match",
        };
      }
    } catch (e) {
      log("Error in checkPassword: $e");
      return {
        "success": false,
        "message": "Something went wrong: $e",
      };
    }
  }
}
