import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config/app_url.dart';

class EditPaymentModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.updatePayment;

  String? _formatDateForApi(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    for (final pattern in ['dd-MM-yyyy', 'd-M-yyyy', 'yyyy-MM-dd']) {
      try {
        final parsed = DateFormat(pattern).parseStrict(trimmed);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}
    }

    return trimmed;
  }

  Future<Map<String, dynamic>> updatePayment({
    required String id,
    required String paymentMode,
    required double amount,
    required List<String> billNos,
    String? notes,

    String? bankName,
    String? chequeNumber,
    String? issueDate,
    String? clearanceDate,

    String? transactionId,
    String? transactionDate,

    String? cashDate,
    Map<String, int>? cashDenominations,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "id": id,
        "amount": amount,
        "billNos": billNos,
        "payment_mode": paymentMode.toLowerCase(),
        "notes": notes ?? "",
      };

      if (paymentMode == "Cheque") {
        if (bankName != null) body["bankName"] = bankName;
        if (chequeNumber != null) body["chequeNumber"] = chequeNumber;
        if (issueDate != null) body["issueDate"] = _formatDateForApi(issueDate);
        if (clearanceDate != null) {
          body["clearanceDate"] = _formatDateForApi(clearanceDate);
        }
      } else if (paymentMode == "Online") {
        if (transactionId != null) body["transactionId"] = transactionId;
        if (transactionDate != null) {
          body["transactionDate"] = _formatDateForApi(transactionDate);
        }
      } else if (paymentMode == "Cash") {
        if (cashDate != null) body["cashDate"] = _formatDateForApi(cashDate);
        if (cashDenominations != null) {
          body["cashDenominations"] = cashDenominations;
        }
      }

      var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      log("Update Payment Response: ${response.statusCode} - ${response.body}");

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
