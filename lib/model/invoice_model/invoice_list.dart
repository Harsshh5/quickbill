import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickbill/config/app_url.dart';

class InvoiceListModel {
  final headers = {'Content-Type': 'application/json'};
  final url = AppUrl.invList;

  Future<Map<String, dynamic>> fetchInvoices() async {
    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          "success": false,
          "message": "Failed to fetch invoices",
          "invoices": [],
        };
      }
    } catch (e) {
      // print("Fetch error: $e");
      return {"success": false, "message": "Exception occurred", "invoices": []};
    }
  }
}
