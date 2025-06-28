import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class RegisterClientModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.registerClient;

  Future<Map<String, dynamic>> registerNewClient(String companyName, String clientName, String contact, String address, String gstNo) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "companyName": companyName,
          "clientName": clientName,
          "contact": contact,
          "address": address,
          "gstNo": gstNo,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        log("Client registered successfully:\n$data");
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
          "message": "Failed to register client",
        };
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
