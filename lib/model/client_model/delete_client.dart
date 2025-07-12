import 'dart:convert';
import 'dart:developer';

import '../../config/app_url.dart';
import 'package:http/http.dart' as http;

class DeleteClientModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.deleteClient;

  Future<Map<String, dynamic>> deleteClient(String clientId) async {
    try{
      var response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "clientId": clientId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "data": data,
        };
      } else if(response.statusCode == 400) {
        final data = json.decode(response.body);
        return {
          "success" : false,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to delete client",
        };
      }
    } catch(e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}