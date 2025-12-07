import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/controller/cheque_controller/add_cheque.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/cheque_controller/edit_cheque.dart';
import '../../controller/client_controller/client_list.dart';
import '../../controller/invoice_controller/invoice_list.dart';
import '../commons/capitalize_text.dart';
import '../commons/card_text_field.dart';
import '../commons/snackbar.dart';
import '../commons/submit_button.dart';

class AddCheque extends StatelessWidget {
  AddCheque({super.key});

  final String tag = Get.arguments["tag"];

  final AddChequeController aCC = Get.put(AddChequeController());
  final EditChequeController eCC = Get.put(EditChequeController());
  final ClientListController clientListController = Get.put(ClientListController());
  final InvoiceListController invoiceListController = Get.put(InvoiceListController());

  final String businessName = AppConstants.abbreviation;

  void _submitOnTap() {
    String bankName = capitalizeEachWord(aCC.bankName.text.trim());
    String clientName = capitalizeEachWord(aCC.clientName.text.trim());
    String amount = aCC.amount.text.trim();
    String chqNo = aCC.chqNo.text.trim();
    String chqDt = aCC.chqDt.text.trim();
    String clearDt = aCC.clearDt.text.trim();
    String billNo = aCC.billNo.text.trim();
    String notes = aCC.notes.text.trim();

    aCC.bankError.value = '';
    aCC.clientError.value = '';
    aCC.amountError.value = '';
    aCC.chqNoError.value = '';
    aCC.chqDtError.value = '';
    aCC.clearDtError.value = '';
    aCC.billNoError.value = '';

    if (bankName.isEmpty) {
      aCC.bankError.value = "Enter bank name.";
      aCC.bankFocus.requestFocus();
      return;
    }

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

    if (amount.isEmpty) {
      aCC.amountError.value = "Enter amount.";
      aCC.amountFocus.requestFocus();
      return;
    }

    if (chqNo.isEmpty) {
      aCC.chqNoError.value = "Enter Cheque No.";
      aCC.chqNoFocus.requestFocus();
      return;
    }

    if (chqDt.isEmpty) {
      aCC.chqDtError.value = "Enter Cheque Date.";
      aCC.chqDtFocus.requestFocus();
      return;
    }

    if (clearDt.isEmpty) {
      aCC.clearDtError.value = "Enter Clearance Date.";
      aCC.clearDtFocus.requestFocus();
      return;
    }

    aCC.addCheque(
      bankName: bankName,
      clientId: aCC.clientId.text,
      amount: amount,
      chequeNumber: chqNo,
      billNos: aCC.selectedBillIds,
      issueDate: chqDt,
      clearanceDate: clearDt,
      businessName: businessName,
      notes: notes,
    );
  }

  void _updateOnTap() {
    String bankName = capitalizeEachWord(eCC.bankName.text.trim());
    String clientName = capitalizeEachWord(eCC.clientName.text.trim());
    String amount = eCC.amount.text.trim();
    String chqNo = eCC.chqNo.text.trim();
    String chqDt = eCC.chqDt.text.trim();
    String clearDt = eCC.clearDt.text.trim();
    String billNo = eCC.billNo.text.trim();
    String notes = eCC.notes.text.trim();

    eCC.bankError.value = '';
    eCC.clientError.value = '';
    eCC.amountError.value = '';
    eCC.chqNoError.value = '';
    eCC.chqDtError.value = '';
    eCC.clearDtError.value = '';
    eCC.billNoError.value = '';

    if (bankName.isEmpty) {
      eCC.bankError.value = "Enter bank name.";
      eCC.bankFocus.requestFocus();
      return;
    }

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

    if (amount.isEmpty) {
      eCC.amountError.value = "Enter amount.";
      eCC.amountFocus.requestFocus();
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

    eCC.editCheque(
      bankName: bankName,
      amount: amount,
      notes: notes,
      clientName: clientName,
      chqNo: chqNo,
      chqDt: chqDt,
      clearDt: clearDt,
      billNo: eCC.selectedBillIds,
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
                            if (tag == "add_cheque") {
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

                          if (tag == "add_cheque") {
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
    String selectedClientName = (tag == "add_cheque") ? aCC.clientName.text.trim() : eCC.clientName.text.trim();

    if (selectedClientName.isEmpty) {
      AppSnackBar.show(message: "Select Client.");
      return Future.value();
    }

    if (!invoiceListController.isLoading.value) {
      await invoiceListController.getInvoiceList();
    }

    RxList<String> currentSelectionIds = (tag == "add_cheque") ? aCC.selectedBillIds : eCC.selectedBillIds;
    RxList<String> currentSelectionNumbers = (tag == "add_cheque") ? aCC.selectedBillNumbers : eCC.selectedBillNumbers;
    TextEditingController currentTextController = (tag == "add_cheque") ? aCC.billNo : eCC.billNo;

    List<String> existingBills = [];
    if (currentTextController.text.trim().isNotEmpty) {
      existingBills = currentTextController.text.trim().split(',').map((e) => e.trim()).toList();
    }

    List<dynamic> clientSpecificInvoices = invoiceListController.filteredList.where((invoice) {
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
                    return Center(
                      child: Text("No unpaid bills found.", style: TextStyle(color: Colors.grey[600])),
                    );
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
                              if (tag == "add_cheque") {
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
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              // Page Header
              CommonPageHeader(
                mainHeading: (tag == "add_cheque") ? "Add Cheque" : "Edit Cheque",
                subHeading: "Cheques",
                onTap: () => Get.back(),
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
                              CommonFromHeading(data: "Bank"),

                              const SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  readOnly: true,
                                  hintText: "Bank Name",
                                  controller: (tag == "add_cheque") ? aCC.bankName : eCC.bankName,
                                  focusNode: (tag == "add_cheque") ? aCC.bankFocus : eCC.bankFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.bankError.value.isEmpty ? null : aCC.bankError.value)
                                          : (eCC.bankError.value.isEmpty ? null : eCC.bankError.value),
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      if (tag == "add_cheque") {
                                        aCC.bankError.value = '';
                                      } else {
                                        eCC.bankError.value = '';
                                      }
                                    }
                                  },
                                  onTap: () {
                                    showBankList(tag);
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              CommonFromHeading(data: "Client"),

                              const SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  readOnly: true,
                                  hintText: "Client Name",
                                  controller: (tag == "add_cheque") ? aCC.clientName : eCC.clientName,
                                  focusNode: (tag == "add_cheque") ? aCC.clientFocus : eCC.clientFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.clientError.value.isEmpty ? null : aCC.clientError.value)
                                          : (eCC.clientError.value.isEmpty ? null : eCC.clientError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      if (tag == "add_cheque") {
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

                              CommonFromHeading(data: "Cheque Number"),

                              const SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  maxLength: 6,
                                  hintText: "Cheque Number",
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  controller: (tag == "add_cheque") ? aCC.chqNo : eCC.chqNo,
                                  focusNode: (tag == "add_cheque") ? aCC.chqNoFocus : eCC.chqNoFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.chqNoError.value.isEmpty ? null : aCC.chqNoError.value)
                                          : (eCC.chqNoError.value.isEmpty ? null : eCC.chqNoError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_cheque") {
                                      aCC.chqNoError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_cheque") {
                                      eCC.chqNoError.value = '';
                                    }
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
                                  keyboardType: TextInputType.number,
                                  controller: (tag == "add_cheque") ? aCC.amount : eCC.amount,
                                  focusNode: (tag == "add_cheque") ? aCC.amountFocus : eCC.amountFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.amountError.value.isEmpty ? null : aCC.amountError.value)
                                          : (eCC.amountError.value.isEmpty ? null : eCC.amountError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_cheque") {
                                      aCC.amountError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_cheque") {
                                      eCC.amountError.value = '';
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              CommonFromHeading(data: "Cheque Date"),

                              const SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  readOnly: true,
                                  suffixIcon: Icon(Icons.calendar_month),
                                  hintText: "Cheque Date",
                                  controller: (tag == "add_cheque") ? aCC.chqDt : eCC.chqDt,
                                  focusNode: (tag == "add_cheque") ? aCC.chqDtFocus : eCC.chqDtFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.chqDtError.value.isEmpty ? null : aCC.chqDtError.value)
                                          : (eCC.chqDtError.value.isEmpty ? null : eCC.chqDtError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_cheque") {
                                      aCC.chqDtError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_cheque") {
                                      eCC.chqDtError.value = '';
                                    }
                                  },
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: Get.context!,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2030),
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

                                      if (tag == "add_cheque") {
                                        aCC.chqDt.text = formattedDate;
                                        aCC.chqDtError.value = '';
                                      } else {
                                        eCC.chqDt.text = formattedDate;
                                        eCC.chqDtError.value = '';
                                      }
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              CommonFromHeading(data: "Clearance Date"),

                              const SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  readOnly: true,
                                  suffixIcon: Icon(Icons.calendar_month),
                                  hintText: "Clearance Date",
                                  controller: (tag == "add_cheque") ? aCC.clearDt : eCC.clearDt,
                                  focusNode: (tag == "add_cheque") ? aCC.clearDtFocus : eCC.clearDtFocus,
                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.clearDtError.value.isEmpty ? null : aCC.clearDtError.value)
                                          : (eCC.clearDtError.value.isEmpty ? null : eCC.clearDtError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_cheque") {
                                      aCC.clearDtError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_cheque") {
                                      eCC.clearDtError.value = '';
                                    }
                                  },
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: Get.context!,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2030),
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

                                      if (tag == "add_cheque") {
                                        aCC.clearDt.text = formattedDate;
                                        aCC.clearDtError.value = '';
                                      } else {
                                        eCC.clearDt.text = formattedDate;
                                        eCC.clearDtError.value = '';
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

                                  controller: (tag == "add_cheque") ? aCC.billNo : eCC.billNo,
                                  focusNode: (tag == "add_cheque") ? aCC.billNoFocus : eCC.billNoFocus,

                                  errorText:
                                      (tag == "add_cheque")
                                          ? (aCC.billNoError.value.isEmpty ? null : aCC.billNoError.value)
                                          : (eCC.billNoError.value.isEmpty ? null : eCC.billNoError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      if (tag == "add_cheque") {
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
                                controller: (tag == "add_cheque") ? aCC.notes : eCC.notes,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        CommonSubmit(
                          data: (tag == "add_cheque") ? "Submit" : "Update",
                          onTap: (tag == "add_cheque") ? _submitOnTap : _updateOnTap,
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
    );
  }
}
