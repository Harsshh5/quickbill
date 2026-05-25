import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickbill/config/app_constants.dart';
import 'package:quickbill/views/pdfs/pdf_download_notification.dart';
import 'package:share_plus/share_plus.dart';
import 'create_pdf.dart';
import 'package:file_saver/file_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> downloadPdf(String fileName) async {
  dynamic abb = AppConstants.abbreviation;
  final pdfCreator = CreatePdf();
  final finalName = pdfCreator.invoiceFileName;
  final pdfFile = await pdfCreator.createPdf(fileName: finalName);
  final bytes = await pdfFile.readAsBytes();

  bool isModernAndroid = false;

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    isModernAndroid = androidInfo.version.sdkInt >= 29;
  }

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

      await Share.shareXFiles([
        XFile(
          pdfFile.path,
          name: '$finalName.pdf',
          mimeType: 'application/pdf',
        ),
      ], text: 'Here is your file: $finalName.pdf');
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

      String filePath = '${subFolder.path}/$finalName.pdf';

      await pdfFile.copy(filePath);

      await showDownloadNotification(finalName, filePath);

      await Share.shareXFiles([
        XFile(
          pdfFile.path,
          name: '$finalName.pdf',
          mimeType: 'application/pdf',
        ),
      ], text: 'Here is your file: $finalName.pdf');
    } else {
      debugPrint("Storage permission denied");
    }
  }
}
