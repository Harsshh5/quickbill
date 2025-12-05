import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/cheque_controller/cheques_list.dart';
import '../commons/card_container.dart';
import '../commons/card_text_field.dart';
import '../commons/text_style.dart';

class ChequeList extends StatelessWidget {
  ChequeList({super.key});

  final ChequesListController cLC = Get.put(ChequesListController());

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
        // 1. Handle Loading State
        if (cLC.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 5, // Fake count for loading
              itemBuilder: (context, index) => _buildListItem(context, {}, true),
            ),
          );
        }

        // 2. Handle Empty State
        if (cLC.filteredList.isEmpty) {
          return Center(
            child: Text(
              "No Cheques Found",
              style: appTextStyle(color: Colors.grey),
            ),
          );
        }

        // 3. Handle List Data
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
    // Safety check for keys if data isn't loaded yet
    String chequeId = isFake ? "0" : (cheque["id"] ?? "0");
    String clientName = isFake ? "Client Name" : (cheque["clientName"] ?? "Unknown");
    String bankDetails = isFake ? "Bank - 000000" : "${cheque["bankName"]} - ${cheque["chequeNumber"]}";
    String amount = isFake ? "0" : (cheque["amount"] ?? "0");
    String date = isFake ? "01-01-2025" : (cheque["issueDate"] ?? "");

    return GestureDetector(
      onTap: () async {
        // Your existing Dialog Logic (Commented out for now)
        // You can uncomment this when you are ready to implement the Delete/Edit features
        /*
        Get.defaultDialog(
          title: "Cheque Actions",
          middleText: "Choose an action",
          // ... rest of your dialog code
        );
        */
      },
      child: Hero(
        tag: 'cheque-$chequeId',
        child: Material(
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
                      Text(
                        clientName,
                        style: appTextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        bankDetails,
                        style: appTextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
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
                    Text(
                      "₹$amount",
                      style: appTextStyle(
                          fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}