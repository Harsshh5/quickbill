import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class AddChequeModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.registerCheque;


  Future<Map<String, dynamic>> registerCheque(
      String bankName,
      String clientId,
      String amount,
      String chequeNumber,
      String businessName,
      String issueDate,
      String clearanceDate,
      List<String> billNos,
      String notes
      ) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "bankName": bankName,
          "clientId": clientId,
          "amount": amount,
          "billNos": billNos,
          "chequeNumber": chequeNumber,
          "businessName": businessName,
          "issueDate": issueDate,
          "clearanceDate": clearanceDate,
          "notes": notes
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {"success": false, "data": data};
      } else {
        return {"success": false, "message": "Failed to register cheque"};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
