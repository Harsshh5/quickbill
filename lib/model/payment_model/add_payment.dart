import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class AddPaymentModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.registerPayment;

  Future<Map<String, dynamic>> registerPayment({
    required String clientId,
    required String businessName,
    required double amount,
    required List<String> billNos,
    required String paymentMode,
    String? notes,

    // Cheque Specific
    String? bankName,
    String? chequeNumber,
    String? issueDate,
    String? clearanceDate,

    // Online Specific
    String? transactionId,
    String? transactionDate,

    // Cash Specific
    String? cashDate,
    Map<String, int>? cashDenominations,
  }) async {
    try {

      final Map<String, dynamic> body = {
        "clientId": clientId,
        "businessName": businessName,
        "amount": amount,
        "billNos": billNos,
        "payment_mode": paymentMode.toLowerCase(),
        "notes": notes ?? "",
      };

      if (paymentMode == "Cheque") {
        if (bankName != null) body["bankName"] = bankName;
        if (chequeNumber != null) body["chequeNumber"] = chequeNumber;
        if (issueDate != null) body["issueDate"] = issueDate;
        if (clearanceDate != null) body["clearanceDate"] = clearanceDate;
      }
      else if (paymentMode == "Online") {
        if (transactionId != null) body["transactionId"] = transactionId;
        if (transactionDate != null) body["transactionDate"] = transactionDate;
      }
      else if (paymentMode == "Cash") {
        if (cashDate != null) body["cashDate"] = cashDate;
        if (cashDenominations != null) body["cashDenominations"] = cashDenominations;
      }

      log(jsonEncode(body));

      var response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));

      log("Server Response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {"success": false, "data": data};
      } else {
        return {"success": false, "message": "Failed to register payment"};
      }
    } catch (e) {
      log("Fetch error: $e");
      return {"success": false, "message": e};
    }
  }
}
