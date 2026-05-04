import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class EditInvoiceModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invUpdate;

  Future<Map<String, dynamic>> updateInvoice({
    required String invoiceId,
    required String clientId,
    required String invoiceDate,
    required List<Map<String, dynamic>> designDetails,
    required double subTotal,
    double? cgst,
    double? sgst,
    required double totalAmount,
  }) async {
    try {
      Map<String, dynamic> amountDetails = {
        "subTotal": subTotal,
        "totalAmount": totalAmount,
      };

      if (cgst != null) amountDetails["cgst"] = cgst;
      if (sgst != null) amountDetails["sgst"] = sgst;

      var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "_id": invoiceId,
          "invoiceId": invoiceId,
          "clientId": clientId,
          "invoiceDate": invoiceDate,
          "designDetails": designDetails,
          "amountDetails": amountDetails,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {"success": false, "data": data};
      } else {
        return {"success": false, "message": "Failed to edit invoice"};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
