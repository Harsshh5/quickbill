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

  final RegisterClientController registerClientController = Get.put(RegisterClientController());
  final EditClientController editClientController = Get.put(EditClientController());

  final String tag = Get.arguments["tag"];

  void _submitOnTap() {
    String companyName = capitalizeEachWord(registerClientController.companyName.text.trim());
    String clientName = capitalizeEachWord(registerClientController.clientName.text.trim());
    String contact = registerClientController.contact.text.trim();
    String address = capitalizeEachWord(registerClientController.address.text.trim());
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

    registerClientController.registerClient(companyName, clientName, contact, address, gstNo);
  }

  void _updateOnTap() {
    String companyName = capitalizeEachWord(editClientController.companyName.text.trim());
    String clientName = capitalizeEachWord(editClientController.clientName.text.trim());
    String contact = editClientController.contact.text.trim();
    String address = capitalizeEachWord(editClientController.address.text.trim());
    String gstNo = editClientController.gstNo.text.trim();

    editClientController.companyError.value = '';
    editClientController.clientError.value = '';
    editClientController.contactError.value = '';
    editClientController.addressError.value = '';
    editClientController.gstError.value = '';

    if (companyName.isEmpty) {
      editClientController.companyError.value = "Enter company name.";
      editClientController.companyFocus.requestFocus();
      return;
    }

    if (clientName.isEmpty) {
      editClientController.clientError.value = "Enter client name.";
      editClientController.clientFocus.requestFocus();
      return;
    }

    if (contact.isEmpty) {
      editClientController.contactError.value = "Enter contact.";
      editClientController.contactFocus.requestFocus();
      return;
    }

    if (address.isEmpty) {
      editClientController.addressError.value = "Enter address.";
      editClientController.addressFocus.requestFocus();
      return;
    }

    if (gstNo.isEmpty) {
      editClientController.gstError.value = "Enter GST number.";
      editClientController.gstFocus.requestFocus();
      return;
    }

    editClientController.editClient(
      companyName,
      clientName,
      editClientController.clientEditId,
      contact,
      address,
      gstNo,
    );
  }

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
                                      (tag == "add_client")
                                          ? registerClientController.companyFocus
                                          : editClientController.companyFocus,
                                  errorText:
                                      (tag == "add_client")
                                          ? (registerClientController.companyError.value.isEmpty
                                              ? null
                                              : registerClientController.companyError.value)
                                          : (editClientController.companyError.value.isEmpty
                                              ? null
                                              : editClientController.companyError.value),
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_client") {
                                      registerClientController.companyError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_client") {
                                      editClientController.companyError.value = '';
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
                                      (tag == "add_client")
                                          ? registerClientController.clientFocus
                                          : editClientController.clientFocus,
                                  errorText:
                                      (tag == "add_client")
                                          ? (registerClientController.clientError.value.isEmpty
                                              ? null
                                              : registerClientController.clientError.value)
                                          : (editClientController.clientError.value.isEmpty
                                              ? null
                                              : editClientController.clientError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_client") {
                                      registerClientController.clientError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_client") {
                                      editClientController.clientError.value = '';
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  controller:
                                      (tag == "add_client")
                                          ? registerClientController.contact
                                          : editClientController.contact,
                                  focusNode:
                                      (tag == "add_client")
                                          ? registerClientController.contactFocus
                                          : editClientController.contactFocus,
                                  errorText:
                                      (tag == "add_client")
                                          ? (registerClientController.contactError.value.isEmpty
                                              ? null
                                              : registerClientController.contactError.value)
                                          : (editClientController.contactError.value.isEmpty
                                              ? null
                                              : editClientController.contactError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_client") {
                                      registerClientController.contactError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_client") {
                                      editClientController.contactError.value = '';
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
                                  focusNode:
                                      (tag == "add_client")
                                          ? registerClientController.gstFocus
                                          : editClientController.gstFocus,
                                  errorText:
                                      (tag == "add_client")
                                          ? (registerClientController.gstError.value.isEmpty
                                              ? null
                                              : registerClientController.gstError.value)
                                          : (editClientController.gstError.value.isEmpty
                                              ? null
                                              : editClientController.gstError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_client") {
                                      registerClientController.gstError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_client") {
                                      editClientController.gstError.value = '';
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
                                      (tag == "add_client")
                                          ? registerClientController.addressFocus
                                          : editClientController.addressFocus,
                                  errorText:
                                      (tag == "add_client")
                                          ? (registerClientController.addressError.value.isEmpty
                                              ? null
                                              : registerClientController.addressError.value)
                                          : (editClientController.addressError.value.isEmpty
                                              ? null
                                              : editClientController.addressError.value),

                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty && tag == "add_client") {
                                      registerClientController.addressError.value = '';
                                    } else if (value.trim().isNotEmpty && tag != "add_client") {
                                      editClientController.addressError.value = '';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        CommonSubmit(
                          data: (tag == "add_client") ? "Submit" : "Update",
                          onTap: (tag == "add_client") ? _submitOnTap : _updateOnTap,
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
