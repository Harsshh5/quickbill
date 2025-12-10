import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/payment_controller/add_payment.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/drop_down.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/payment_controller/edit_payment.dart';
import '../../controller/client_controller/client_list.dart';
import '../../controller/invoice_controller/invoice_list.dart';
import '../commons/capitalize_text.dart';
import '../commons/card_text_field.dart';
import '../commons/snackbar.dart';
import '../commons/submit_button.dart';
import '../commons/text_style.dart';

class AddPayment extends StatelessWidget {
  AddPayment({super.key});

  final String tag = Get.arguments["tag"];

  final AddPaymentController aCC = Get.put(AddPaymentController());
  final EditPaymentController eCC = Get.put(EditPaymentController());
  final ClientListController clientListController = Get.put(ClientListController());
  final InvoiceListController invoiceListController = Get.put(InvoiceListController());

  final String businessName = AppConstants.abbreviation;

  void _submitOnTap() {
    String mode = aCC.selectedMode.value;
    String clientName = capitalizeEachWord(aCC.clientName.text.trim());
    String amount = aCC.amount.text.trim();
    String billNo = aCC.billNo.text.trim();
    String notes = aCC.notes.text.trim();

    aCC.clientError.value = '';
    aCC.amountError.value = '';
    aCC.billNoError.value = '';

    aCC.bankError.value = '';
    aCC.chqNoError.value = '';
    aCC.chqDtError.value = '';
    aCC.clearDtError.value = '';

    aCC.transactionIdError.value = '';
    aCC.transactionDtError.value = '';
    aCC.cashDtError.value = '';

    if (clientName.isEmpty) {
      aCC.clientError.value = "Enter client name.";
      aCC.clientFocus.requestFocus();
      return;
    }

    if (billNo.isEmpty) {
      aCC.billNoError.value = "Select at least one bill.";
      aCC.billNoFocus.requestFocus();
      return;
    }

    if (amount.isEmpty || double.tryParse(amount) == 0) {
      aCC.amountError.value = "Enter valid amount.";
      aCC.amountFocus.requestFocus();
      return;
    }

    if (mode == "Cheque") {
      String bankName = capitalizeEachWord(aCC.bankName.text.trim());
      String chqNo = aCC.chqNo.text.trim();
      String chqDt = aCC.chqDt.text.trim();
      String clearDt = aCC.clearDt.text.trim();

      if (bankName.isEmpty) {
        aCC.bankError.value = "Enter bank name.";
        aCC.bankFocus.requestFocus();
        return;
      }
      if (chqNo.isEmpty) {
        aCC.chqNoError.value = "Enter Cheque No.";
        aCC.chqNoFocus.requestFocus();
        return;
      }
      if (chqDt.isEmpty) {
        aCC.chqDtError.value = "Select Cheque Date.";
        aCC.chqDtFocus.requestFocus();
        return;
      }
      if (clearDt.isEmpty) {
        aCC.clearDtError.value = "Select Clearance Date.";
        aCC.clearDtFocus.requestFocus();
        return;
      }
    } else if (mode == "Online") {
      String transId = aCC.transactionId.text.trim();
      String transDt = aCC.transactionDt.text.trim();

      if (transId.isEmpty) {
        aCC.transactionIdError.value = "Enter Transaction ID.";
        return;
      }
      if (transDt.isEmpty) {
        aCC.transactionDtError.value = "Select Transaction Date.";
        return;
      }
    } else if (mode == "Cash") {
      String cashDt = aCC.cashDt.text.trim();
      if (cashDt.isEmpty) {
        aCC.cashDtError.value = "Select Cash Date.";
        return;
      }
    }

    aCC.addPayment(
      paymentMode: mode,
      clientId: aCC.clientId.text,
      amount: amount,
      billNos: aCC.selectedBillIds,
      businessName: businessName,
      notes: notes,

      bankName: (mode == "Cheque") ? capitalizeEachWord(aCC.bankName.text.trim()) : null,
      chequeNumber: (mode == "Cheque") ? aCC.chqNo.text.trim() : null,
      issueDate: (mode == "Cheque") ? aCC.chqDt.text.trim() : null,
      clearanceDate: (mode == "Cheque") ? aCC.clearDt.text.trim() : null,

      transactionId: (mode == "Online") ? aCC.transactionId.text.trim() : null,
      transactionDate: (mode == "Online") ? aCC.transactionDt.text.trim() : null,

      cashDate: (mode == "Cash") ? aCC.cashDt.text.trim() : null,
      cashDenominations:
          (mode == "Cash")
              ? Map.fromEntries(
                aCC.denomControllers.entries
                    .map((e) => MapEntry(e.key.toString(), int.tryParse(e.value.text) ?? 0))
                    .where((e) => e.value > 0),
              )
              : null,
    );
  }

  void _updateOnTap() {
    String mode = eCC.selectedMode.value;
    String clientName = capitalizeEachWord(eCC.clientName.text.trim());
    String amount = eCC.amount.text.trim();
    String billNo = eCC.billNo.text.trim();
    String notes = eCC.notes.text.trim();

    eCC.clientError.value = '';
    eCC.amountError.value = '';
    eCC.billNoError.value = '';
    eCC.bankError.value = '';
    eCC.chqNoError.value = '';
    eCC.chqDtError.value = '';
    eCC.clearDtError.value = '';

    if (clientName.isEmpty) {
      eCC.clientError.value = "Enter client name.";
      eCC.clientFocus.requestFocus();
      return;
    }
    if (billNo.isEmpty) {
      eCC.billNoError.value = "Select at least one bill.";
      eCC.billNoFocus.requestFocus();
      return;
    }
    if (amount.isEmpty || double.tryParse(amount) == 0) {
      eCC.amountError.value = "Enter valid amount.";
      eCC.amountFocus.requestFocus();
      return;
    }

    if (mode == "Cheque") {
      String bankName = capitalizeEachWord(eCC.bankName.text.trim());
      String chqNo = eCC.chqNo.text.trim();
      String chqDt = eCC.chqDt.text.trim();
      String clearDt = eCC.clearDt.text.trim();

      if (bankName.isEmpty) {
        eCC.bankError.value = "Enter bank name.";
        eCC.bankFocus.requestFocus();
        return;
      }
      if (chqNo.isEmpty) {
        eCC.chqNoError.value = "Enter Cheque No.";
        eCC.chqNoFocus.requestFocus();
        return;
      }
      if (chqDt.isEmpty) {
        eCC.chqDtError.value = "Enter Cheque Date.";
        eCC.chqDtFocus.requestFocus();
        return;
      }
      if (clearDt.isEmpty) {
        eCC.clearDtError.value = "Enter Clearance Date.";
        eCC.clearDtFocus.requestFocus();
        return;
      }
    } else if (mode == "Online") {
      if (eCC.transactionId.text.trim().isEmpty) {
        Get.snackbar("Error", "Enter Transaction ID", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
      if (eCC.transactionDt.text.trim().isEmpty) {
        Get.snackbar("Error", "Select Transaction Date", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    } else if (mode == "Cash") {
      if (eCC.cashDt.text.trim().isEmpty) {
        Get.snackbar("Error", "Select Cash Date", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    eCC.editPayment(
      paymentMode: mode,
      amount: amount,
      notes: notes,
      billNos: eCC.selectedBillIds,
      businessName: businessName,
      clientId: aCC.clientId.text,

      // Cheque
      bankName: (mode == "Cheque") ? capitalizeEachWord(eCC.bankName.text.trim()) : null,
      chequeNumber: (mode == "Cheque") ? eCC.chqNo.text.trim() : null,
      issueDate: (mode == "Cheque") ? eCC.chqDt.text.trim() : null,
      clearanceDate: (mode == "Cheque") ? eCC.clearDt.text.trim() : null,

      // Online
      transactionId: (mode == "Online") ? eCC.transactionId.text.trim() : null,
      transactionDate: (mode == "Online") ? eCC.transactionDt.text.trim() : null,

      // Cash
      cashDate: (mode == "Cash") ? eCC.cashDt.text.trim() : null,
      cashDenominations:
          (mode == "Cash")
              ? Map.fromEntries(
                aCC.denomControllers.entries
                    .map((e) => MapEntry(e.key.toString(), int.tryParse(e.value.text) ?? 0))
                    .where((e) => e.value > 0),
              )
              : null,
    );
  }

  Future showCompanyList(String tag) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: Get.context!,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: Get.height / 2,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Company", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              CommonTextField(
                hintText: "Search",
                suffixIcon: const Icon(Icons.search, color: Colors.black),
                onChanged: (val) {
                  clientListController.filterItems(val);
                },
              ),

              Expanded(
                child: Obx(() {
                  if (clientListController.filteredList.isEmpty && !clientListController.isLoading.value) {
                    return const Center(child: Text("No clients found"));
                  }

                  return Skeletonizer(
                    enabled: clientListController.isLoading.value,
                    child: ListView.builder(
                      itemCount: clientListController.isLoading.value ? 5 : clientListController.filteredList.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (clientListController.isLoading.value) {
                          return const ListTile(title: Text("Loading..."), subtitle: Text("Loading..."));
                        }

                        final item = clientListController.filteredList[index];

                        return ListTile(
                          title: Text(item["companyName"] ?? ""),
                          subtitle: Text(item["clientName"] ?? ""),
                          onTap: () {
                            if (tag == "add_payment") {
                              aCC.clientName.text = item["companyName"]!;
                              aCC.clientId.text = item["id"]!;
                              aCC.clientError.value = '';
                            } else {
                              eCC.clientName.text = item["companyName"]!;
                              eCC.clientId.text = item["id"]!;
                              eCC.clientError.value = '';
                            }

                            Get.back();
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future showBankList(String tag) {
    RxList<String> filteredList = RxList<String>.from(aCC.bankNameList);

    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: Get.context!,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: Get.height / 2,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Banks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              CommonTextField(
                hintText: "Search",
                suffixIcon: const Icon(Icons.search, color: Colors.black),
                onChanged: (val) {
                  if (val.isEmpty) {
                    filteredList.assignAll(aCC.bankNameList);
                  } else {
                    filteredList.assignAll(
                      aCC.bankNameList.where((bank) => bank.toLowerCase().contains(val.toLowerCase())),
                    );
                  }
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (filteredList.isEmpty) {
                    return const Center(child: Text("No banks found"));
                  }
                  return ListView.builder(
                    itemCount: filteredList.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredList[index]),
                        onTap: () {
                          String selectedBank = filteredList[index];

                          if (tag == "add_payment") {
                            aCC.bankName.text = selectedBank;
                            aCC.bankError.value = '';
                          } else {
                            eCC.bankName.text = selectedBank;
                            eCC.bankError.value = '';
                          }
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future showInvoiceList(String tag) async {
    String selectedClientName = (tag == "add_payment") ? aCC.clientName.text.trim() : eCC.clientName.text.trim();

    if (selectedClientName.isEmpty) {
      AppSnackBar.show(message: "Select Client.");
      return Future.value();
    }

    if (!invoiceListController.isLoading.value) {
      await invoiceListController.getInvoiceList();
    }

    RxList<String> currentSelectionIds = (tag == "add_payment") ? aCC.selectedBillIds : eCC.selectedBillIds;
    RxList<String> currentSelectionNumbers = (tag == "add_payment") ? aCC.selectedBillNumbers : eCC.selectedBillNumbers;
    TextEditingController currentTextController = (tag == "add_payment") ? aCC.billNo : eCC.billNo;

    List<String> existingBills = [];
    if (currentTextController.text.trim().isNotEmpty) {
      existingBills = currentTextController.text.trim().split(',').map((e) => e.trim()).toList();
    }

    List<dynamic> clientSpecificInvoices =
        invoiceListController.filteredList.where((invoice) {
          String invoiceClient = invoice["companyName"]?.toString() ?? "";
          bool isClientMatch = invoiceClient.toLowerCase() == selectedClientName.toLowerCase();

          String status = invoice["status"]?.toString().toLowerCase() ?? "";
          String invoiceNo = invoice["invoiceNumber"].toString();

          bool isUnpaid = status == "unpaid";
          bool isCurrentlySelected = existingBills.contains(invoiceNo);

          return isClientMatch && (isUnpaid || isCurrentlySelected);
        }).toList();

    RxList<dynamic> filteredInvoices = RxList.from(clientSpecificInvoices);

    currentSelectionIds.clear();
    currentSelectionNumbers.clear();

    if (existingBills.isNotEmpty) {
      currentSelectionNumbers.assignAll(existingBills);

      for (var invoice in clientSpecificInvoices) {
        String invNo = invoice["invoiceNumber"].toString();
        String invId = invoice["id"].toString();

        if (existingBills.contains(invNo)) {
          currentSelectionIds.add(invId);
        }
      }
    } else {
      filteredInvoices.assignAll(clientSpecificInvoices);
    }

    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          height: Get.height / 1.5,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Bills", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("For: $selectedClientName", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      currentSelectionIds.clear();
                      currentSelectionNumbers.clear();
                      currentTextController.text = "";
                    },
                    child: const Text("Clear All"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              CommonTextField(
                hintText: "Search Invoice No",
                suffixIcon: const Icon(Icons.search, color: Colors.black),
                onChanged: (val) {
                  if (val.isEmpty) {
                    filteredInvoices.assignAll(clientSpecificInvoices);
                  } else {
                    filteredInvoices.assignAll(
                      clientSpecificInvoices.where((inv) => inv["invoiceNumber"].toString().contains(val)).toList(),
                    );
                  }
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (filteredInvoices.isEmpty) {
                    return Center(child: Text("No unpaid bills found.", style: TextStyle(color: Colors.grey[600])));
                  }

                  return ListView.builder(
                    itemCount: filteredInvoices.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      final String invoiceNo = invoice["invoiceNumber"].toString();
                      final String invoiceId = invoice["id"].toString();

                      return Obx(() {
                        bool isSelected = currentSelectionIds.contains(invoiceId);

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [Text("Bill No: $invoiceNo"), const Spacer(), Text("₹${invoice["totalAmount"]}")],
                          ),
                          subtitle: Text("${invoice["date"]}"),
                          activeColor: Colors.deepPurple,
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              if (!currentSelectionIds.contains(invoiceId)) {
                                currentSelectionIds.add(invoiceId);
                              }
                              if (!currentSelectionNumbers.contains(invoiceNo)) {
                                currentSelectionNumbers.add(invoiceNo);
                              }
                            } else {
                              currentSelectionIds.remove(invoiceId);
                              currentSelectionNumbers.remove(invoiceNo);
                            }

                            currentTextController.text = currentSelectionNumbers.join(', ');

                            if (currentSelectionIds.isNotEmpty) {
                              if (tag == "add_payment") {
                                aCC.billNoError.value = '';
                              } else {
                                eCC.billNoError.value = '';
                              }
                            }
                          },
                        );
                      });
                    },
                  );
                }),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () => Get.back(),
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDenomRow(int amount, String tag) {
    final controller = (tag == "add_payment") ? aCC.denomControllers[amount] : eCC.denomControllers[amount];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text("$amount  x ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),

          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                onTapOutside: (event) {
                  FocusScope.of(Get.context!).unfocus();
                },
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  hintText: "0",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(" =  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() {
                  int total = (tag == "add_payment") ? (aCC.denomTotals[amount] ?? 0) : (eCC.denomTotals[amount] ?? 0);

                  return Text("$total", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget generateModeDetailsBox(String mode) {
    // --- CASE 1: CHEQUE ---
    if (mode == "Cheque") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const CommonFromHeading(data: "Bank"),
          const SizedBox(height: 10),

          Obx(
            () => CommonTextField(
              autofocus: false,
              readOnly: true,
              hintText: "Bank Name",
              controller: (tag == "add_payment") ? aCC.bankName : eCC.bankName,
              focusNode: (tag == "add_payment") ? aCC.bankFocus : eCC.bankFocus,
              errorText:
                  (tag == "add_payment")
                      ? (aCC.bankError.value.isEmpty ? null : aCC.bankError.value)
                      : (eCC.bankError.value.isEmpty ? null : eCC.bankError.value),
              onTap: () => showBankList(tag),
            ),
          ),

          const SizedBox(height: 15),
          const CommonFromHeading(data: "Cheque Number"),
          const SizedBox(height: 10),

          Obx(
            () => CommonTextField(
              hintText: "Cheque Number",
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: (tag == "add_payment") ? aCC.chqNo : eCC.chqNo,
              focusNode: (tag == "add_payment") ? aCC.chqNoFocus : eCC.chqNoFocus,
              errorText:
                  (tag == "add_payment")
                      ? (aCC.chqNoError.value.isEmpty ? null : aCC.chqNoError.value)
                      : (eCC.chqNoError.value.isEmpty ? null : eCC.chqNoError.value),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  if (tag == "add_payment") {
                    aCC.chqNoError.value = '';
                  } else {
                    eCC.chqNoError.value = '';
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 15),
          const CommonFromHeading(data: "Cheque Date"),
          const SizedBox(height: 10),

          CommonTextField(
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_month),
            hintText: "Cheque Date",
            controller: (tag == "add_payment") ? aCC.chqDt : eCC.chqDt,
            focusNode: (tag == "add_payment") ? aCC.chqDtFocus : eCC.chqDtFocus,
            onTap: () => selectDate(Get.context!, (tag == "add_payment") ? aCC.chqDt : eCC.chqDt),
          ),

          const SizedBox(height: 15),
          const CommonFromHeading(data: "Clearance Date"),
          const SizedBox(height: 10),

          CommonTextField(
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_month),
            hintText: "Clearance Date",
            controller: (tag == "add_payment") ? aCC.clearDt : eCC.clearDt,
            onTap: () => selectDate(Get.context!, (tag == "add_payment") ? aCC.clearDt : eCC.clearDt),
          ),
        ],
      );
    }
    // --- CASE 2: ONLINE ---
    else if (mode == "Online") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const CommonFromHeading(data: "Transaction ID"),
          const SizedBox(height: 10),

          CommonTextField(
            hintText: "Enter Transaction ID",
            controller: (tag == "add_payment") ? aCC.transactionId : eCC.transactionId,
          ),

          const SizedBox(height: 15),
          const CommonFromHeading(data: "Transaction Date"),
          const SizedBox(height: 10),

          CommonTextField(
            readOnly: true,
            hintText: "Select Date",
            suffixIcon: const Icon(Icons.calendar_month),
            controller: (tag == "add_payment") ? aCC.transactionDt : eCC.transactionDt,
            onTap: () => selectDate(Get.context!, (tag == "add_payment") ? aCC.transactionDt : eCC.transactionDt),
          ),
        ],
      );
    }
    // --- CASE 3: CASH ---
    else if (mode == "Cash") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const CommonFromHeading(data: "Cash Received Date"),
          const SizedBox(height: 10),

          CommonTextField(
            readOnly: true,
            hintText: "Select Date",
            suffixIcon: const Icon(Icons.calendar_month),
            controller: (tag == "add_payment") ? aCC.cashDt : eCC.cashDt,
            onTap: () => selectDate(Get.context!, (tag == "add_payment") ? aCC.cashDt : eCC.cashDt),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const CommonFromHeading(data: "Denominations"),
          const SizedBox(height: 10),

          Column(
            children:
                aCC.denominations.map((denom) {
                  return _buildDenomRow(denom, tag);
                }).toList(),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Cash:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Obx(
                  () => Text(
                    "₹ ${aCC.grandCashTotal.value}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    void showExitConfirmation() {
      Get.defaultDialog(
        radius: 22,
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 10),
        title: "Discard Payment?",
        titleStyle: appTextStyle(),
        content: const Column(
          children: [
            Divider(),
            SizedBox(height: 20),
            Text("You have unsaved changes. Are you sure you want to discard them?", textAlign: TextAlign.center),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Keep Editing")),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          showExitConfirmation();
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: [
                // Page Header
                CommonPageHeader(
                  mainHeading: (tag == "add_payment") ? "Add Payment" : "Edit Payment",
                  subHeading: "Payments",
                  onTap: () => showExitConfirmation(),
                  icon: Icons.chevron_left_rounded,
                ),

                const SizedBox(height: 20),

                // Cheque details
                Expanded(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CommonCardContainer(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonFromHeading(data: "Mode of Payment"),
                                const SizedBox(height: 10),

                                CommonCardContainer(
                                  child: CommonDropDown(
                                    hintText: "Mode",
                                    borderSideBorder: BorderSide.none,
                                    borderSideEnable: BorderSide.none,
                                    borderSideFocused: BorderSide.none,
                                    dropdownMenuEntries: aCC.modeDropdownEntries,
                                    initialSelection: aCC.selectedMode.value,
                                    onSelected: (value) {
                                      if (value != null) {
                                        aCC.selectedMode.value = value.toString();
                                      }
                                    },
                                  ),
                                ),

                                Obx(() {
                                  return generateModeDetailsBox(aCC.selectedMode.value);
                                }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          CommonCardContainer(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15),

                                CommonFromHeading(data: "Client"),

                                const SizedBox(height: 10),
                                Obx(
                                  () => CommonTextField(
                                    autofocus: false,
                                    readOnly: true,
                                    hintText: "Client Name",
                                    controller: (tag == "add_payment") ? aCC.clientName : eCC.clientName,
                                    focusNode: (tag == "add_payment") ? aCC.clientFocus : eCC.clientFocus,
                                    errorText:
                                        (tag == "add_payment")
                                            ? (aCC.clientError.value.isEmpty ? null : aCC.clientError.value)
                                            : (eCC.clientError.value.isEmpty ? null : eCC.clientError.value),

                                    onChanged: (value) {
                                      if (value.trim().isNotEmpty) {
                                        if (tag == "add_payment") {
                                          aCC.clientError.value = '';
                                        } else {
                                          eCC.clientError.value = '';
                                        }
                                      }
                                    },
                                    onTap: () {
                                      showCompanyList(tag);

                                      clientListController.filterItems("");
                                    },
                                  ),
                                ),

                                const SizedBox(height: 15),

                                CommonFromHeading(data: "Amount (₹)"),

                                const SizedBox(height: 10),
                                Obx(
                                  () => CommonTextField(
                                    autofocus: false,
                                    hintText: "Amount",
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    // Allow decimal keyboard
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],

                                    readOnly:
                                        (tag == "add_payment")
                                            ? (aCC.selectedMode.value == "Cash")
                                            : (eCC.selectedMode.value == "Cash"),

                                    controller: (tag == "add_payment") ? aCC.amount : eCC.amount,
                                    focusNode: (tag == "add_payment") ? aCC.amountFocus : eCC.amountFocus,

                                    errorText:
                                        (tag == "add_payment")
                                            ? (aCC.amountError.value.isEmpty ? null : aCC.amountError.value)
                                            : (eCC.amountError.value.isEmpty ? null : eCC.amountError.value),

                                    onChanged: (value) {
                                      if (value.trim().isNotEmpty) {
                                        if (tag == "add_payment") {
                                          aCC.amountError.value = '';
                                        } else {
                                          eCC.amountError.value = '';
                                        }
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 15),

                                CommonFromHeading(data: "Bill Numbers"),

                                const SizedBox(height: 10),
                                Obx(
                                  () => CommonTextField(
                                    autofocus: false,
                                    readOnly: true,
                                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                                    hintText: "Select Bill Numbers",

                                    controller: (tag == "add_payment") ? aCC.billNo : eCC.billNo,
                                    focusNode: (tag == "add_payment") ? aCC.billNoFocus : eCC.billNoFocus,

                                    errorText:
                                        (tag == "add_payment")
                                            ? (aCC.billNoError.value.isEmpty ? null : aCC.billNoError.value)
                                            : (eCC.billNoError.value.isEmpty ? null : eCC.billNoError.value),

                                    onChanged: (value) {
                                      if (value.trim().isNotEmpty) {
                                        if (tag == "add_payment") {
                                          aCC.billNoError.value = '';
                                        } else {
                                          eCC.billNoError.value = '';
                                        }
                                      }
                                    },

                                    onTap: () {
                                      showInvoiceList(tag);
                                    },
                                  ),
                                ),

                                const SizedBox(height: 15),

                                CommonFromHeading(data: "Notes"),

                                const SizedBox(height: 10),
                                CommonTextField(
                                  autofocus: false,
                                  hintText: "Notes",
                                  controller: (tag == "add_payment") ? aCC.notes : eCC.notes,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          CommonSubmit(
                            data: (tag == "add_payment") ? "Submit" : "Update",
                            onTap: (tag == "add_payment") ? _submitOnTap : _updateOnTap,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
