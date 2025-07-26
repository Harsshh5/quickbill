import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class AddInvoiceModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invCreate;



  Future<Map<String, dynamic>> addNewInvoice({
    required String clientId,
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

      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          "clientId": clientId,
          "designDetails": designDetails,
          "amountDetails": amountDetails,
          "status": "unpaid",
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // log("\n\n\n Invoice created successfully:\n\n$data");
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
