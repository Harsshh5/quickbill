import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/model/invoice_model/invoice_list.dart';

class InvoiceListController extends GetxController {
  RxList<Map<String, String>> allInvoices = <Map<String, String>>[].obs;
  RxList<Map<String, String>> filteredList = <Map<String, String>>[].obs;

  Rx<DateTimeRange?> currentDateRange = Rx<DateTimeRange?>(null);
  var isLoading = false.obs;

  var currentStatusFilter = 'unpaid'.obs;
  var currentSearchQuery = ''.obs;

  RxDouble pendingTotal = 0.0.obs;
  RxDouble receivedTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getInvoiceList();
  }

  String formatIndianCurrency(dynamic amount) {
    try {
      // Handle both String and Double input
      double number = (amount is String) ? double.parse(amount) : amount;
      final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 1);
      return format.format(number);
    } catch (e) {
      return "₹0.00";
    }
  }

  String formatDateToDMY(String inputDate) {
    try {
      final date = DateTime.parse(inputDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  double _parseAmount(String? amountStr) {
    if (amountStr == null) return 0.0;
    String clean = amountStr.replaceAll(',', '').replaceAll('₹', '');
    return double.tryParse(clean) ?? 0.0;
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(allInvoices);
    } else {
      filteredList.assignAll(
        allInvoices.where(
              (item) =>
          item["invoiceNumber"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["companyName"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["totalAmount"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["date"]!.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void _applyFilters() {
    List<Map<String, String>> tempBaseList = List.from(allInvoices);

    if (currentSearchQuery.value.isNotEmpty) {
      String query = currentSearchQuery.value.toLowerCase();
      tempBaseList = tempBaseList.where((item) =>
      (item["invoiceNumber"] ?? "").toLowerCase().contains(query) ||
          (item["companyName"] ?? "").toLowerCase().contains(query) ||
          (item["totalAmount"] ?? "").toLowerCase().contains(query)
      ).toList();
    }

    if (currentDateRange.value != null) {
      DateTime start = currentDateRange.value!.start;
      DateTime end = currentDateRange.value!.end;

      tempBaseList = tempBaseList.where((item) {
        String dateStr = item['date'] ?? '';
        if (dateStr.isEmpty || dateStr == 'Invalid date') return false;
        try {
          DateTime itemDate = DateFormat('dd-MM-yyyy').parse(dateStr);
          return (itemDate.isAtSameMomentAs(start) || itemDate.isAfter(start)) &&
              (itemDate.isAtSameMomentAs(end) || itemDate.isBefore(end));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    double pTotal = 0.0;
    double rTotal = 0.0;

    for (var item in tempBaseList) {
      String status = (item['status'] ?? '').toLowerCase();
      double amount = _parseAmount(item['totalAmount']);

      if (status == 'unpaid') {
        pTotal += amount;
      } else if (status == 'paid' || status == 'received') {
        rTotal += amount;
      }
    }

    pendingTotal.value = pTotal;
    receivedTotal.value = rTotal;
    
    if (currentStatusFilter.value.isNotEmpty) {
      tempBaseList = tempBaseList
          .where((item) => (item['status'] ?? '').toLowerCase() == currentStatusFilter.value.toLowerCase())
          .toList();
    }

    filteredList.assignAll(tempBaseList);
  }

  void setStatusFilter(String status) {
    currentStatusFilter.value = status;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    currentSearchQuery.value = query;
    _applyFilters();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    currentDateRange.value = range;
    _applyFilters();
  }

  Future<void> getInvoiceList() async {
    isLoading.value = true;
    try {
      var res = await InvoiceListModel().fetchInvoices();

      if (res["success"] == true) {
        List<Map<String, String>> tempList = [];
        for (var item in res["invoices"]) {
          tempList.add({
            "id": item["_id"] ?? "",
            "companyName": item["clientId"]?["companyName"] ?? "",
            "totalAmount": item["amountDetails"]?["totalAmount"]?.toString() ?? "",
            "invoiceNumber": item["invoiceNumber"]?.toString() ?? "",
            "status": item["status"] ?? "",
            "date": formatDateToDMY(item["createdAt"]),
          });
        }
        allInvoices.assignAll(tempList);
        _applyFilters();
      } else {
        allInvoices.clear();
        filteredList.clear();
        pendingTotal.value = 0.0;
        receivedTotal.value = 0.0;
      }
    } catch (e) {
      log("Error: $e");
      allInvoices.clear();
      filteredList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}


