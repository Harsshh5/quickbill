import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class InvoiceCountModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invTotal;

  Future<Map<String, dynamic>> fetchInvoiceCount() async {
    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print("Clients fetched successfully:\n$data");
        return data;
      } else {
        return {
          "success": false,
          "message": "Failed to fetch clients count",
        };
      }
    } catch (e) {
      // print("Fetch error: $e");
      return {"success": false, "message": "Exception occurred"};
    }
  }
}
