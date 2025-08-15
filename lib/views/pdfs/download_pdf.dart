import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/pdfs/pdf_download_notification.dart';
import 'create_pdf.dart';

Future<void> downloadPdf(String fileName) async {
  dynamic abb = AppConstants.abbreviation;
  if (await Permission.storage.request().isGranted) {
    final pdfFile = await CreatePdf().createPdf();

    Directory? downloadsDir = Directory('/storage/emulated/0/Download');

    Directory quickbillFolder = Directory('${downloadsDir.path}/Quickbill');
    if (!await quickbillFolder.exists()) {
      await quickbillFolder.create(recursive: true);
    }

    Directory subFolder = Directory('${quickbillFolder.path}/$abb');
    if (!await subFolder.exists()) {
      await subFolder.create(recursive: true);
    }

    String filePath = '${subFolder.path}/$fileName.pdf';

    await pdfFile.copy(filePath);

    await showDownloadNotification(fileName);
  } else {
    debugPrint("Storage permission denied");
  }
}
