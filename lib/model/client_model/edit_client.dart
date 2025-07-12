import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../config/app_url.dart';

class EditClientModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.updateClient;

  Future<Map<String, dynamic>> updateClient(
    String companyName,
    String clientName,
    String clientId,
    String contact,
    String address,
    String gstNo,
  ) async {
    try {
      var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "companyName": companyName,
          "clientName": clientName,
          "contact": contact,
          "address": address,
          "_id": clientId,
          "gstNo": gstNo,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // log("Client registered successfully:\n$data");
        return {"success": true, "data": data};
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {"success": false, "data": data};
      } else {
        return {"success": false, "message": "Failed to register client"};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
