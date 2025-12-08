import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/payment_controller/delete_payment.dart';
import '../../controller/payment_controller/edit_payment.dart';
import '../../controller/payment_controller/payment_list.dart';
import '../commons/card_container.dart';
import '../commons/card_text_field.dart';
import '../commons/cheque_detail_dialogue.dart';
import '../commons/text_style.dart';
import 'add_payment.dart';

class PaymentList extends StatelessWidget {
  PaymentList({super.key});

  final PaymentsListController cLC = Get.put(PaymentsListController());
  final EditPaymentController eCC = Get.put(EditPaymentController());
  final DeletePaymentController dCC = Get.put(DeletePaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Payment List",
                subHeading: "Payments",
                onTap: () {
                  Get.back();
                },
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              CommonTextField(
                hintText: "Search Client, Bank, Cheque No. or Amount",
                suffixIcon: const Icon(Icons.search, color: Colors.black),
                onChanged: (val) {
                  cLC.filterItems(val);
                },
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Get.to(() => AddPayment(), arguments: {"tag": "add_payment"}, transition: Transition.fadeIn);
                },
                child: CommonCardContainer(
                  height: 100,
                  width: Get.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_card_rounded, color: AppColors.dark, size: 24),
                      Text("Add Payment", style: appTextStyle(fontSize: 18)),
                      Text(
                        "Add latest payment details, cash, online or cheque.",
                        style: appTextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              paymentsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentsList() {
    return Expanded(
      child: Obx(() {
        if (cLC.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(itemCount: 5, itemBuilder: (context, index) => _buildListItem(context, {}, true)),
          );
        }

        if (cLC.filteredList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("No Payments Found", style: appTextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          backgroundColor: Colors.white,
          color: AppColors.dark,
          onRefresh: () => cLC.getPaymentsList(),
          child: ListView.builder(
            itemCount: cLC.filteredList.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var payment = cLC.filteredList[index];
              return _buildListItem(context, payment, false);
            },
          ),
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> payment, bool isFake) {
    String id = isFake ? "0" : (payment["id"] ?? "0");
    String clientName = isFake ? "Client Name" : (payment["clientName"] ?? "Unknown");
    String amount = isFake ? "0" : (payment["amount"] ?? "0");
    String date = isFake ? "01-01-2025" : (payment["issueDate"] ?? "");
    String mode = isFake ? "cheque" : (payment["payment_mode"] ?? "cheque").toString().toLowerCase();

    String subtitle = "";
    if (isFake) {
      subtitle = "Bank - 000000";
    } else {
      String refNo = payment["chequeNumber"] ?? "";
      String bankOrType = payment["bankName"] ?? "";

      if (mode == 'cash') {
        subtitle = "Cash Received";
      } else if (mode == 'online') {
        subtitle = "Ref: $refNo";
      } else {
        subtitle = "$bankOrType - $refNo";
      }
    }

    IconData modeIcon;
    Color iconColor;

    switch (mode) {
      case 'online':
        modeIcon = Icons.phone_iphone_rounded;
        iconColor = Colors.blue.shade700;
        break;
      case 'cash':
        modeIcon = Icons.payments_outlined;
        iconColor = Colors.green.shade700;
        break;
      case 'cheque':
      default:
        modeIcon = Icons.description_outlined;
        iconColor = Colors.purple.shade700;
        break;
    }

    Widget cardContent = Material(
      type: MaterialType.transparency,
      child: CommonCardContainer(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(modeIcon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Text Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clientName, style: appTextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: appTextStyle(fontSize: 13, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹$amount", style: appTextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 5),
                Row(children: [Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              ],
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () async {
        if (isFake) return;
        Get.to(
          () => ChequeDetailDialog(
            cheque: payment,
            onDeletePressed: () {
              Get.defaultDialog(
                radius: 12,
                titlePadding: const EdgeInsets.only(top: 20),
                title: "Delete Payment?",
                content: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Are you sure you want to remove this payment entry?", textAlign: TextAlign.center),
                ),
                actions: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                  TextButton(
                    onPressed: () {
                      dCC.removePayment(id);
                      Get.back();
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
            onEditPressed: () {
              log(payment.toString());
              Get.back();
              eCC.setEditableValues(payment, id);

              Get.to(() => AddPayment(), transition: Transition.rightToLeft, arguments: {"tag": "edit_payment"});
            },
          ),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 200),
          opaque: false,
          fullscreenDialog: true,
        );
      },
      child: isFake ? cardContent : Hero(tag: 'payment-$id', child: cardContent),
    );
  }
}
