import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/cheque_controller/cheques_list.dart';
import '../../controller/cheque_controller/delete_cheque.dart';
import '../../controller/cheque_controller/edit_cheque.dart';
import '../commons/card_container.dart';
import '../commons/card_text_field.dart';
import '../commons/cheque_detail_dialogue.dart';
import '../commons/text_style.dart';
import 'add_cheque.dart';

class ChequeList extends StatelessWidget {
  ChequeList({super.key});

  final ChequesListController cLC = Get.put(ChequesListController());
  final EditChequeController eCC = Get.put(EditChequeController());
  final DeleteChequeController dCC = Get.put(DeleteChequeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Cheque List",
                subHeading: "Cheques",
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
                  Get.to(() => AddCheque(), arguments: {"tag": "add_cheque"}, transition: Transition.fadeIn);
                },
                child: CommonCardContainer(
                  height: 100,
                  width: Get.width,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_card_rounded, color: AppColors.dark, size: 24),
                      Text("Add Cheques", style: appTextStyle(fontSize: 18)),
                      Text(
                        "Add latest cheque with all the details.",
                        style: appTextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              chequesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget chequesList() {
    return Expanded(
      child: Obx(() {
        if (cLC.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(itemCount: 5, itemBuilder: (context, index) => _buildListItem(context, {}, true)),
          );
        }

        if (cLC.filteredList.isEmpty) {
          return Center(child: Text("No Cheques Found", style: appTextStyle(color: Colors.grey)));
        }

        return RefreshIndicator(
          backgroundColor: Colors.white,
          color: AppColors.dark,
          onRefresh: () {
            return cLC.getChequeList();
          },
          child: ListView.builder(
            itemCount: cLC.filteredList.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var cheque = cLC.filteredList[index];
              return _buildListItem(context, cheque, false);
            },
          ),
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> cheque, bool isFake) {
    String chequeId = isFake ? "0" : (cheque["id"] ?? "0");
    String clientName = isFake ? "Client Name" : (cheque["clientName"] ?? "Unknown");
    String bankDetails = isFake ? "Bank - 000000" : "${cheque["bankName"]} - ${cheque["chequeNumber"]}";
    String amount = isFake ? "0" : (cheque["amount"] ?? "0");
    String date = isFake ? "01-01-2025" : (cheque["issueDate"] ?? "");

    // 1. The Visual Card (Same as before)
    Widget cardContent = Material(
      type: MaterialType.transparency,
      child: CommonCardContainer(
        width: Get.width,
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Side: Client & Bank Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clientName, style: appTextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(
                    bankDetails,
                    style: appTextStyle(fontSize: 14, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Bills: ${isFake ? '...' : cheque["billNos"]}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right Side: Amount & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹$amount", style: appTextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            cheque: cheque,
            onDeletePressed: () {
              Get.defaultDialog(
                radius: 22,
                backgroundColor: Colors.white,
                titlePadding: const EdgeInsets.only(top: 10),
                title: "Delete Cheque?",
                titleStyle: appTextStyle(),
                content: const Column(
                  children: [
                    Divider(),
                    SizedBox(height: 20),
                    Text("Are you sure you want to \ndelete this cheque?", textAlign: TextAlign.center),
                    SizedBox(height: 10),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      dCC.removeCheque(chequeId);
                      Get.back();
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },

            onEditPressed: () {
              log(cheque.toString());
              Get.back();

              eCC.setEditableValues(cheque, chequeId);

              Get.to(
                () => AddCheque(),
                transition: Transition.fadeIn,
                arguments: {"tag": "edit_cheque"},
              );
            },
          ),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
          opaque: false,
          fullscreenDialog: true,
        );
      },

      child:
          isFake
              ? cardContent
              : Hero(
                tag: 'cheque-$chequeId', // Must match the tag in ChequeDetailDialog
                child: cardContent,
              ),
    );
  }
}
