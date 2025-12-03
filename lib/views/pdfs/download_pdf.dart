import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/pdfs/pdf_download_notification.dart';
import 'create_pdf.dart';
import 'package:file_saver/file_saver.dart'; // Add this package
import 'package:device_info_plus/device_info_plus.dart'; // Add this package

Future<void> downloadPdf(String fileName) async {
  dynamic abb = AppConstants.abbreviation;
  final pdfFile = await CreatePdf().createPdf();
  final bytes = await pdfFile.readAsBytes();

  bool isModernAndroid = false;

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    isModernAndroid = androidInfo.version.sdkInt >= 29;
  }

  String cleanName = fileName.replaceAll('.pdf', '');
  String finalName = '$abb-$cleanName';

  // --- LOGIC FOR ANDROID 10+ (Scoped Storage) ---
  if (isModernAndroid) {
    try {
      String path = await FileSaver.instance.saveFile(
        name: finalName,
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      debugPrint("File Saved at: $path");

      await showDownloadNotification(finalName, path);

    } catch (e) {
      debugPrint("Error saving file: $e");
    }
  }
  // --- LOGIC FOR OLDER ANDROID (< 10) ---
  else {
    if (await Permission.storage.request().isGranted) {
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

      await showDownloadNotification(fileName, filePath);
    } else {
      debugPrint("Storage permission denied");
    }
  }
}