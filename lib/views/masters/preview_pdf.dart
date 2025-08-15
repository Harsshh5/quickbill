import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../commons/page_header.dart';

class PreviewPdf extends StatelessWidget {
  final String pdfPath;

  const PreviewPdf({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "Invoice PDF",
                subHeading: "Preview Invoice PDF",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),
              Expanded(
                  child: SfPdfViewer.file(
                      File(pdfPath),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
