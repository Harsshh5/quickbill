import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../config/app_url.dart';

class EditChequeModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.updateCheque;

  Future<Map<String, dynamic>> updateCheque(
      String chequeEditId,
      String bankName,
      String clientName,
      String chequeNumber,
      String amount,
      String chequeDate,
      String clearanceDate,
      List<String> billNos,
      String notes,
      ) async {
    try {
      var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "bankName": bankName,
          "clientName": clientName,
          "chequeNumber": chequeNumber,
          "amount": amount,
          "chequeDate": chequeDate,
          "clearanceDate": clearanceDate,
          "billNos": billNos,
          "notes": notes,
          "id": chequeEditId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {"success": false, "data": data};
      } else {
        return {"success": false, "message": "Failed to edit cheque"};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}