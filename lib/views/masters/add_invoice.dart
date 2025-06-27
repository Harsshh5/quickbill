import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/page_header.dart';
import 'package:quickbill/views/commons/submit_button.dart';
import 'package:quickbill/views/commons/text_style.dart';

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

  List<DesignCardData> designCardList = [DesignCardData()];
  final ScrollController _scrollController = ScrollController();

  double subtotal = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double finalTotal = 0.0;

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
    return CommonCardContainer(
      cardMargin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      width: Get.width,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Design ${index + 1}",
                style: appTextStyle(fontSize: 16),
              ),
              if (designCardList.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      designCardList.removeAt(index);
                      calculateTotals();
                    });
                  },
                  child: CommonIconCardContainer(
                    height: 35,
                    width: 35,
                    child: const Icon(Icons.close, color: Colors.red),
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
                    const CommonFromHeading(data: "Category"),
                    const SizedBox(height: 6),
                    CommonTextField(
                      hintText: "Category",
                      controller: data.category,
                    ),
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
                    CommonTextField(
                      hintText: "Amount",
                      controller: data.amount,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹ ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
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
              CommonPageHeader(
                mainHeading: "Invoice",
                subHeading: "Add New Invoice",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonCardContainer(
                        width: Get.width,
                        padding: EdgeInsets.all(10),
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

                      SizedBox(height: 20),

                      Row(
                        children: [
                          Text(
                            "Design Details",
                            style: appTextStyle(fontSize: 18),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                designCardList.add(DesignCardData());
                              });
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                },
                              );
                            },
                            child: CommonIconCardContainer(
                              height: 40,
                              width: 40,
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ...List.generate(designCardList.length, buildDesignCard),

                      const SizedBox(height: 20),

                      CommonCardContainer(
                        width: Get.width,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSummaryRow("Subtotal", subtotal),
                            buildSummaryRow("CGST (2.5%)", cgst),
                            buildSummaryRow("SGST (2.5%)", sgst),

                            const Divider(thickness: 1.5),

                            buildSummaryRow(
                              "Final Total",
                              finalTotal,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      CommonSubmit(
                        onTap: (){},
                        data: "Submit",
                      ),

                      const SizedBox(height: 20),
                    ],
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
