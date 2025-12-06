import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/text_style.dart';

import 'card_container.dart';

class ChequeDetailDialog extends StatelessWidget {
  final Map<String, dynamic> cheque;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const ChequeDetailDialog({
    super.key,
    required this.cheque,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    String chequeId = cheque["id"] ?? "0";

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Center(
        child: Hero(
          tag: 'cheque-$chequeId',
          child: Material(
            type: MaterialType.transparency,
            child: CommonCardContainer(
              width: Get.width * 0.9,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SelectableText(cheque["bankName"] ?? '', style: appTextStyle()),

                        Spacer(),

                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Client",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            SelectableText(cheque["clientName"] ?? '-', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.credit_card, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cheque Number",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            SelectableText(cheque["chequeNumber"] ?? '-', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_rounded, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            SelectableText(cheque["amount"] ?? '-', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            SelectableText(cheque["issueDate"] ?? '-', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bill Numbers",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            SelectableText(cheque["billNos"] ?? '-', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    (cheque["notes"] != "")
                        ? SelectableText(
                          "Notes : ${cheque["notes"]}",
                          style: TextStyle(fontSize: 13, color: Colors.black, fontStyle: FontStyle.italic),
                        )
                        : SizedBox.shrink(),

                    const SizedBox(height: 10),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red.shade100)),
                          onPressed: onDeletePressed,
                          child: const Text("DELETE", style: TextStyle(color: Colors.red)),
                        ),

                        SizedBox(width: 10),

                        TextButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple.shade100)),
                          onPressed: onEditPressed,
                          child: const Text("EDIT"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
