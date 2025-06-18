import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/common_form_card.dart';
import 'package:quickbill/views/commons/common_page_header.dart';

class DesignCardData {
  final TextEditingController category = TextEditingController();
  final TextEditingController totalDesigns = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController amount = TextEditingController();
}

class AddInvoice extends StatefulWidget {
  const AddInvoice({super.key});

  @override
  State<AddInvoice> createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  late AnimationController submitController;
  late Animation<double> submitScale;

  List<DesignCardData> designCardList = [DesignCardData()];
  final ScrollController _scrollController = ScrollController();

  double subtotal = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double finalTotal = 0.0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    submitScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: submitController, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    submitController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void calculateAmount(DesignCardData data) {
    final total = double.tryParse(data.totalDesigns.text) ?? 0;
    final rate = double.tryParse(data.rate.text) ?? 0;
    final result = total * rate;
    data.amount.text = result.toStringAsFixed(2);
    calculateTotals();
  }

  void calculateTotals() {
    double tempSubtotal = 0.0;
    for (var card in designCardList) {
      final amt = double.tryParse(card.amount.text) ?? 0;
      tempSubtotal += amt;
    }
    setState(() {
      subtotal = tempSubtotal;
      cgst = subtotal * 0.025;
      sgst = subtotal * 0.025;
      finalTotal = subtotal + cgst + sgst;
    });
  }

  Widget buildDesignCard(int index) {
    final data = designCardList[index];
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Design #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (designCardList.length > 1)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        designCardList.removeAt(index);
                        calculateTotals();
                      });
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.red[100]),
                        child: const Icon(Icons.close, color: Colors.red),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonFromHeading(data: "Category"),
                      const SizedBox(height: 6),
                      CommonTextField(hintText: "Category", controller: data.category),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonFromHeading(data: "Total Designs"),
                      const SizedBox(height: 6),
                      CommonTextField(
                        hintText: "Total Designs",
                        controller: data.totalDesigns,
                        onChanged: (_) => calculateAmount(data),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonFromHeading(data: "Rate"),
                      const SizedBox(height: 6),
                      CommonTextField(
                        hintText: "Rate",
                        controller: data.rate,
                        onChanged: (_) => calculateAmount(data),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonFromHeading(data: "Amount"),
                      const SizedBox(height: 6),
                      CommonTextField(hintText: "Amount", controller: data.amount, readOnly: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("₹ ${value.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: CommonPageHeader(
                    mainHeading: "Invoice",
                    subHeading: "Add New Invoice",
                    onTap: () => Get.back(),
                    icon: Icons.chevron_left_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Container(
                          width: Get.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonFromHeading(data: "Invoice No."),
                              CommonFromHeading(data: "Invoice Date"),
                              SizedBox(height: 10),
                              SizedBox(height: 15),
                              CommonFromHeading(data: "Company"),
                              SizedBox(height: 10),
                              CommonTextField(
                                autofocus: true,
                                hintText: "Company",
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          const Text("Design Details", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                designCardList.add(DesignCardData());
                              });
                              Future.delayed(const Duration(milliseconds: 300), () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                );
                              });
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                                child: const Icon(Icons.add, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(designCardList.length, buildDesignCard),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        child: Container(
                          width: Get.width,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSummaryRow("Subtotal", subtotal),
                              buildSummaryRow("CGST (2.5%)", cgst),
                              buildSummaryRow("SGST (2.5%)", sgst),
                              const Divider(thickness: 1.5),
                              buildSummaryRow("Final Total", finalTotal, isBold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          await submitController.forward();
                          await submitController.reverse();
                          // Handle submit logic
                        },
                        child: ScaleTransition(
                          scale: submitScale,
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Container(
                              width: Get.width,
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: const Color(0xff8845ec), borderRadius: BorderRadius.circular(24)),
                              child: const Text("Submit", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
