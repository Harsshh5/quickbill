import 'package:flutter/material.dart';
import '../../../controller/home_widget_animations/list_animation_controller.dart';
import '../commons/home_page_widgets/recent_invoice_ui.dart';

class InvoiceListWrapper extends StatefulWidget {
  final int itemCount;
  final bool enableSelection;
  final String? billNo;
  final String? companyName;
  final String? invoiceDate;
  final String? invoiceAmount;
  final ValueChanged<bool>? onSelectionModeChange;
  final Future<void> Function() onRefresh;

  const InvoiceListWrapper({
    super.key,
    required this.itemCount,
    this.enableSelection = false,
    this.onSelectionModeChange,
    this.billNo,
    this.companyName,
    this.invoiceDate,
    this.invoiceAmount,
    required this.onRefresh,
  });

  @override
  State<InvoiceListWrapper> createState() => _InvoiceListWrapperState();
}

class _InvoiceListWrapperState extends State<InvoiceListWrapper>
    with TickerProviderStateMixin {
  late ListAnimationControllerHelper animController;
  Set<int> selectedIndexes = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    animController = ListAnimationControllerHelper(
      vsync: this,
      itemCount: widget.itemCount,
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  void _handleLongPress(int index) {
    if (!widget.enableSelection) return;
    setState(() {
      isSelectionMode = true;
      selectedIndexes.add(index);
      widget.onSelectionModeChange?.call(true); // notify parent
    });
  }

  void _handleTap(int index) async {
    await animController.listControllers[index].forward();
    await animController.listControllers[index].reverse();

    if (widget.enableSelection) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          if (selectedIndexes.isEmpty) {
            isSelectionMode = false;
            widget.onSelectionModeChange?.call(false);
          }
        } else {
          selectedIndexes.add(index);
        }
      });
    }
  }

  void _handleCheckboxToggle(int index, bool? val) {
    setState(() {
      if (val == true) {
        selectedIndexes.add(index);
      } else {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) {
          isSelectionMode = false;
          widget.onSelectionModeChange?.call(false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInvoiceList(
      onRefresh: widget.onRefresh,
      animController: animController,
      itemCount: widget.itemCount,
      isSelectionMode: isSelectionMode,
      selectedIndexes: selectedIndexes,
      onLongPress: _handleLongPress,
      onTap: _handleTap,
      onCheckboxToggle: widget.enableSelection ? _handleCheckboxToggle : null,

      billNo: widget.billNo,
      companyName: widget.companyName,
      invoiceDate: widget.invoiceDate,
      invoiceAmount: widget.invoiceAmount,
    );
  }
}
