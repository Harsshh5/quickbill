import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/client_controller/edit_client.dart';
import 'package:quickbill/controller/client_controller/register_client.dart';
import 'package:quickbill/views/commons/capitalize_text.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/card_text_field.dart';
import 'package:quickbill/views/commons/page_header.dart';

import '../commons/submit_button.dart';

class AddClient extends StatelessWidget {
  AddClient({super.key});

  final RegisterClientController registerClientController = Get.put(
    RegisterClientController(),
  );
  final EditClientController editClientController = Get.put(
    EditClientController(),
  );

  final String tag = Get.arguments["tag"];

  void _submitOnTap() {
    String companyName = capitalizeEachWord(
      registerClientController.companyName.text.trim(),
    );
    String clientName = capitalizeEachWord(
      registerClientController.clientName.text.trim(),
    );
    String contact = registerClientController.contact.text.trim();
    String address = capitalizeEachWord(
      registerClientController.address.text.trim(),
    );
    String gstNo = registerClientController.gstNo.text.trim();

    registerClientController.companyError.value = '';
    registerClientController.clientError.value = '';
    registerClientController.contactError.value = '';
    registerClientController.addressError.value = '';
    registerClientController.gstError.value = '';

    if (companyName.isEmpty) {
      registerClientController.companyError.value = "Enter company name.";
      registerClientController.companyFocus.requestFocus();
      return;
    }

    if (clientName.isEmpty) {
      registerClientController.clientError.value = "Enter client name.";
      registerClientController.clientFocus.requestFocus();
      return;
    }

    if (contact.isEmpty) {
      registerClientController.contactError.value = "Enter contact.";
      registerClientController.contactFocus.requestFocus();
      return;
    }

    if (address.isEmpty) {
      registerClientController.addressError.value = "Enter address.";
      registerClientController.addressFocus.requestFocus();
      return;
    }

    if (gstNo.isEmpty) {
      registerClientController.gstError.value = "Enter GST number.";
      registerClientController.gstFocus.requestFocus();
      return;
    }

    registerClientController.registerClient(
      companyName,
      clientName,
      contact,
      address,
      gstNo,
    );
  }

  void _updateOnTap() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: SafeArea(
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Client",
                subHeading: "Add New Client",
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  Get.back();
                },
              ),

              SizedBox(height: 20),
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
                              CommonFromHeading(data: "Company Name"),

                              SizedBox(height: 10),

                              Obx(
                                () => CommonTextField(
                                  autofocus: true,
                                  hintText: "Company Name",
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.companyName
                                          : editClientController.companyName,
                                  focusNode:
                                      registerClientController.companyFocus,
                                  errorText:
                                      registerClientController
                                              .companyError
                                              .value
                                              .isEmpty
                                          ? null
                                          : registerClientController
                                              .companyError
                                              .value,
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      registerClientController
                                          .companyError
                                          .value = '';
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: 15),

                              CommonFromHeading(data: "Client Name"),

                              SizedBox(height: 10),

                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  hintText: "Client Name",
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.clientName
                                          : editClientController.clientName,
                                  focusNode:
                                      registerClientController.clientFocus,
                                  errorText:
                                      registerClientController
                                              .clientError
                                              .value
                                              .isEmpty
                                          ? null
                                          : registerClientController
                                              .clientError
                                              .value,
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      registerClientController
                                          .clientError
                                          .value = '';
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: 15),

                              CommonFromHeading(data: "Contact"),

                              SizedBox(height: 10),

                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  hintText: "Contact",
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.contact
                                          : editClientController.contact,
                                  focusNode:
                                      registerClientController.contactFocus,
                                  errorText:
                                      registerClientController
                                              .contactError
                                              .value
                                              .isEmpty
                                          ? null
                                          : registerClientController
                                              .contactError
                                              .value,
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      registerClientController
                                          .contactError
                                          .value = '';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        CommonCardContainer(
                          width: Get.width,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonFromHeading(data: "GST NO."),
                              SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  hintText: "GST NO.",
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.gstNo
                                          : editClientController.gstNo,
                                  focusNode: registerClientController.gstFocus,
                                  errorText:
                                      registerClientController
                                              .gstError
                                              .value
                                              .isEmpty
                                          ? null
                                          : registerClientController
                                              .gstError
                                              .value,
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      registerClientController.gstError.value =
                                          '';
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: 15),

                              CommonFromHeading(data: "Address"),
                              SizedBox(height: 10),
                              Obx(
                                () => CommonTextField(
                                  autofocus: false,
                                  hintText: "Address",
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.address
                                          : editClientController.address,
                                  focusNode:
                                      registerClientController.addressFocus,
                                  errorText:
                                      registerClientController
                                              .addressError
                                              .value
                                              .isEmpty
                                          ? null
                                          : registerClientController
                                              .addressError
                                              .value,
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      registerClientController
                                          .addressError
                                          .value = '';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        CommonSubmit(data: (tag == "add_client") ? "Submit" : "Update", onTap: (tag == "add_client") ? _submitOnTap : _updateOnTap),

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
