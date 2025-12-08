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
    String mode = (cheque["payment_mode"] ?? "cheque").toString().toLowerCase();

    // Determine Labels based on Mode
    String refLabel = "Cheque Number";
    IconData refIcon = Icons.credit_card;

    if (mode == "online") {
      refLabel = "Transaction ID";
      refIcon = Icons.wifi_tethering;
    } else if (mode == "cash") {
      refLabel = "Payment Type";
      refIcon = Icons.payments_outlined;
    }

    String dateLabel = (mode == "cash") ? "Received Date" : (mode == "online" ? "Transaction Date" : "Issue Date");

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Center(
        child: Hero(
          tag: 'cheque-$chequeId', // Tag matches the list item
          child: Material(
            type: MaterialType.transparency,
            child: CommonCardContainer(
              width: Get.width * 0.9,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            cheque["bankName"] ?? 'Payment Details',
                            style: appTextStyle(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- CLIENT ---
                    _buildDetailRow(
                      icon: Icons.person,
                      label: "Client",
                      value: cheque["clientName"] ?? '-',
                    ),

                    const SizedBox(height: 15),

                    // --- REFERENCE (Chq No / Trans ID) ---
                    _buildDetailRow(
                      icon: refIcon,
                      label: refLabel,
                      value: cheque["chequeNumber"] ?? '-', // "chequeNumber" holds Ref ID from controller
                    ),

                    const SizedBox(height: 15),

                    // --- AMOUNT ---
                    _buildDetailRow(
                      icon: Icons.currency_rupee_rounded,
                      label: "Amount",
                      value: cheque["amount"] ?? '-',
                      valueColor: Colors.black,
                    ),

                    const SizedBox(height: 15),

                    // --- DATE ---
                    _buildDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: dateLabel,
                      value: cheque["issueDate"] ?? '-',
                    ),

                    // --- CLEARANCE DATE (Cheque Only) ---
                    if (mode == "cheque" && (cheque["clearanceDate"] != null && cheque["clearanceDate"] != "")) ...[
                      const SizedBox(height: 15),
                      _buildDetailRow(
                        icon: Icons.event_available,
                        label: "Clearance Date",
                        value: cheque["clearanceDate"] ?? '-',
                      ),
                    ],

                    const SizedBox(height: 15),

                    // --- BILL NUMBERS ---
                    _buildDetailRow(
                      icon: Icons.receipt_long_rounded,
                      label: "Bill Numbers",
                      value: cheque["billNos"] ?? '-',
                    ),

                    // --- CASH DENOMINATIONS (Cash Only) ---
                    if (mode == "cash" && cheque["cashDenominations"] != null) ...[
                      const SizedBox(height: 15),
                      const Divider(height: 20),
                      const Text("Denominations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      _buildDenominationList(cheque["cashDenominations"]),
                    ],

                    const SizedBox(height: 15),

                    // --- NOTES ---
                    if (cheque["notes"] != null && cheque["notes"].toString().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SelectableText(
                          "Note: ${cheque["notes"]}",
                          style: const TextStyle(fontSize: 13, color: Colors.black87, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // --- ACTION BUTTONS ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red.shade50)),
                          onPressed: onDeletePressed,
                          child: const Text("DELETE", style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple.shade50)),
                          onPressed: onEditPressed,
                          child: const Text("EDIT", style: TextStyle(color: Colors.purple)),
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

  // Helper Widget to reduce code duplication
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to display cash map neatly
  Widget _buildDenominationList(dynamic denominations) {
    if (denominations is! Map) return const SizedBox.shrink();

    // Convert map to list of widgets
    List<Widget> rows = [];
    denominations.forEach((key, value) {
      int amount = int.tryParse(key.toString()) ?? 0;
      int count = int.tryParse(value.toString()) ?? 0;
      int total = amount * count;

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$amount x $count", style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text("=  ₹$total", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(children: rows),
    );
  }
}