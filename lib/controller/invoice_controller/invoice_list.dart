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
  var isFinancialYearFilterEnabled = false.obs;
  var selectedFinancialYear = ''.obs;
  RxList<String> financialYears = <String>[].obs;

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
      final format = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 1,
      );
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

  DateTime? _parseDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Invalid date') {
      return null;
    }
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  int _financialYearStart(DateTime date) {
    return date.month >= 4 ? date.year : date.year - 1;
  }

  String _financialYearLabel(DateTime date) {
    final startYear = _financialYearStart(date);
    return "$startYear-${startYear + 1}";
  }

  int _financialYearStartFromLabel(String financialYear) {
    return int.tryParse(financialYear.split('-').first) ?? 0;
  }

  bool _isInvoiceInSelectedFinancialYear(Map<String, String> item) {
    if (!isFinancialYearFilterEnabled.value ||
        selectedFinancialYear.value.isEmpty) {
      return true;
    }

    final invoiceDate = _parseDisplayDate(item["invoiceDate"]);
    if (invoiceDate == null) return false;

    return _financialYearLabel(invoiceDate) == selectedFinancialYear.value;
  }

  void _updateFinancialYears(List<Map<String, String>> invoices) {
    final yearSet = <String>{};

    for (var invoice in invoices) {
      final invoiceDate = _parseDisplayDate(invoice["invoiceDate"]);
      if (invoiceDate != null) {
        yearSet.add(_financialYearLabel(invoiceDate));
      }
    }

    final sortedYears =
        yearSet.toList()..sort(
          (a, b) => _financialYearStartFromLabel(
            b,
          ).compareTo(_financialYearStartFromLabel(a)),
        );

    financialYears.assignAll(sortedYears);

    if (!isFinancialYearFilterEnabled.value) return;

    if (financialYears.isEmpty) {
      selectedFinancialYear.value = '';
    } else if (selectedFinancialYear.value.isEmpty ||
        !financialYears.contains(selectedFinancialYear.value)) {
      selectedFinancialYear.value = financialYears.first;
    }
  }

  List<DropdownMenuEntry<String>> get financialYearDropdownEntries {
    return financialYears
        .map((item) => DropdownMenuEntry(value: item, label: item))
        .toList();
  }

  void filterItems(String query) {
    setSearchQuery(query);
  }

  void _applyFilters() {
    List<Map<String, String>> tempBaseList = List.from(allInvoices);

    tempBaseList =
        tempBaseList.where(_isInvoiceInSelectedFinancialYear).toList();

    if (currentSearchQuery.value.isNotEmpty) {
      String query = currentSearchQuery.value.toLowerCase();
      tempBaseList =
          tempBaseList
              .where(
                (item) =>
                    (item["invoiceNumber"] ?? "").toLowerCase().contains(
                      query,
                    ) ||
                    (item["companyName"] ?? "").toLowerCase().contains(query) ||
                    (item["totalAmount"] ?? "").toLowerCase().contains(query),
              )
              .toList();
    }

    if (currentDateRange.value != null) {
      DateTime start = currentDateRange.value!.start;
      DateTime end = currentDateRange.value!.end;

      tempBaseList =
          tempBaseList.where((item) {
            String dateStr = item['date'] ?? '';
            if (dateStr.isEmpty || dateStr == 'Invalid date') return false;
            try {
              DateTime itemDate = DateFormat('dd-MM-yyyy').parse(dateStr);
              return (itemDate.isAtSameMomentAs(start) ||
                      itemDate.isAfter(start)) &&
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
      tempBaseList =
          tempBaseList
              .where(
                (item) =>
                    (item['status'] ?? '').toLowerCase() ==
                    currentStatusFilter.value.toLowerCase(),
              )
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

  void enableFinancialYearFilter() {
    isFinancialYearFilterEnabled.value = true;
    _updateFinancialYears(allInvoices);
    _applyFilters();
  }

  void setFinancialYearFilter(String financialYear) {
    selectedFinancialYear.value = financialYear;
    _applyFilters();
  }

  void disableFinancialYearFilter() {
    isFinancialYearFilterEnabled.value = false;
    selectedFinancialYear.value = '';
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
            "totalAmount":
                item["amountDetails"]?["totalAmount"]?.toString() ?? "",
            "invoiceNumber": item["invoiceNumber"]?.toString() ?? "",
            "invoiceDate": formatDateToDMY(item["invoiceDate"]),
            "status": item["status"] ?? "",
            "date": formatDateToDMY(item["createdAt"]),
          });
        }
        allInvoices.assignAll(tempList);
        _updateFinancialYears(tempList);
        _applyFilters();
      } else {
        allInvoices.clear();
        filteredList.clear();
        financialYears.clear();
        selectedFinancialYear.value = '';
        pendingTotal.value = 0.0;
        receivedTotal.value = 0.0;
      }
    } catch (e) {
      log("Error: $e");
      allInvoices.clear();
      filteredList.clear();
      financialYears.clear();
      selectedFinancialYear.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
