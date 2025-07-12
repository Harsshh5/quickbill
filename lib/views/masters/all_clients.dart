import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/controller/client_controller/delete_client.dart';
import 'package:quickbill/controller/client_controller/edit_client.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_colors.dart';
import '../../controller/all_client_animations/client_list_animation.dart';
import '../../controller/client_controller/client_list.dart';
import '../commons/all_clients_widgets/client_detail_dialog.dart';
import '../commons/card_text_field.dart';
import '../commons/page_header.dart';
import '../commons/text_style.dart';
import 'add_client.dart';

class AllClients extends StatefulWidget {
  const AllClients({super.key});

  @override
  State<AllClients> createState() => _AllClientsState();
}

class _AllClientsState extends State<AllClients> with TickerProviderStateMixin {
  final ClientListController clientListController = Get.put(
    ClientListController(),
  );

  final EditClientController editClientController = Get.put(
    EditClientController(),
  );

  final DeleteClientController deleteClientController = Get.put(DeleteClientController());

  late ClientListAnimations clientAnimations;

  final clientCount = Get.arguments["clientCount"];

  @override
  void initState() {
    super.initState();
    clientAnimations = ClientListAnimations(vsync: this, itemCount: clientCount);
    clientAnimations.playEntranceAnimations();
  }

  @override
  void dispose() {
    clientAnimations.dispose();
    super.dispose();
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
                mainHeading: "Clients",
                subHeading: "All Clients",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),

              SizedBox(height: 20),

              CommonTextField(
                hintText: "Search",
                suffixIcon: Icon(Icons.search, color: Colors.black),
                onChanged: (p0) {
                  clientListController.filterItems(p0);
                },
              ),

              SizedBox(height: 20),

              clientList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget clientList() {
    return Expanded(
      child: clientCount == 0
          ? Center(
        child: Text(
          "No Clients Found",
          style: appTextStyle(color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.dark,
        onRefresh: () {
          return clientListController.getClientList();
        },
        child: Obx(() => Skeletonizer(
          enabled: clientListController.isLoading.value,
          child: ListView.builder(
            itemCount: clientListController.filteredList.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var client = clientListController.filteredList[index];
              String? clientId = client["id"];

              return SlideTransition(
                position: clientAnimations.slideAnimations[index],
                child: FadeTransition(
                  opacity: clientAnimations.fadeAnimations[index],
                  child: ScaleTransition(
                    scale: clientAnimations.scaleAnimations[index],
                    child: GestureDetector(
                      onTap: () async {
                        await clientAnimations.scaleControllers[index].reverse();
                        await clientAnimations.scaleControllers[index].forward();

                        Get.to(
                              () => ClientDetailDialog(
                            client: client,
                            onDeletePressed: () {
                              Get.defaultDialog(
                                radius: 22,
                                backgroundColor: Colors.white,
                                titlePadding: EdgeInsets.only(top: 10),
                                title: "Delete Client?",
                                titleStyle: appTextStyle(),
                                content: Column(
                                  children: [
                                    Divider(),
                                    SizedBox(height: 20),
                                    Text(
                                      "Are you sure you want to \ndelete this client?",
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteClientController.removeClient(clientId!);
                                      Get.back();
                                    },
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                            onEditPressed: () {
                              Get.back();
                              editClientController.setEditableValues(client, clientId);
                              Get.to(
                                    () => AddClient(),
                                transition: Transition.fadeIn,
                                arguments: {"tag": "edit_client"},
                              );
                            },
                          ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 300),
                          opaque: false,
                          fullscreenDialog: true,
                        );
                      },
                      child: Hero(
                        tag: 'client-$clientId',
                        child: Material(
                          type: MaterialType.transparency,
                          child: CommonCardContainer(
                            width: Get.width,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${client["companyName"]}",
                                      style: appTextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "${client["clientName"]}",
                                      style: appTextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
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
                ),
              );
            },
          ),
        )),
      ),
    );
  }


}
