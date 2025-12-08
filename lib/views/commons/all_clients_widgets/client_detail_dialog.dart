import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';

import '../text_style.dart';

class ClientDetailDialog extends StatelessWidget {
  final Map<String, String> client;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  const ClientDetailDialog({super.key, required this.client, this.onEditPressed, this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4), // dim background
      body: Center(
        child: Hero(
          tag: 'client-${client["id"]}',
          child: Material(
            type: MaterialType.transparency,
            child: CommonCardContainer(
              width: Get.width * 0.94,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns icon to top if text wraps
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SelectableText(
                            client["companyName"] ?? '',
                            style: appTextStyle(),
                          ),
                        ),

                        const SizedBox(width: 10),

                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),

                    const Divider(),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.blue),
                        const SizedBox(width: 15),
                        SelectableText(
                          client["clientName"] ?? '-',
                          style: appTextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.call, size: 20, color: Colors.green),
                        const SizedBox(width: 15),
                        SelectableText(
                          "+91-${client["contact"]}",
                          style: appTextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.home_work_rounded,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: SelectableText(
                            client["address"] ?? '-',
                            style: appTextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 15),
                        SelectableText(
                          client["gstNo"] ?? '-',
                          style: appTextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.red.shade100,
                            ),
                          ),
                          onPressed: onDeletePressed,
                          child: const Text(
                            "DELETE",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                        SizedBox(width: 10),

                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.purple.shade100,
                            ),
                          ),
                          onPressed: onEditPressed,
                          child: const Text("EDIT"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
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
