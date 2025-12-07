import 'dart:convert';
import 'dart:developer';

import '../../config/app_url.dart';
import 'package:http/http.dart' as http;

class DeleteChequeModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.deleteCheque;

  Future<Map<String, dynamic>> deleteCheque(String chequeId) async {
    try {
      var response = await http.delete(Uri.parse(url), headers: headers, body: json.encode({"id": chequeId}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else {
        final data = json.decode(response.body);
        return {"success": false, "message": "Failed to delete cheque", "data": data};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
