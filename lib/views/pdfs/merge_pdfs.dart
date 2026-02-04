import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../commons/page_header.dart';

class MergePdfs extends StatefulWidget {
  const MergePdfs({super.key});

  @override
  State<MergePdfs> createState() => _MergePdfsState();
}

class _MergePdfsState extends State<MergePdfs> {
  final List<PlatformFile> pdfFiles = [];
  bool isMerging = false;

  Future<void> pickPdfs() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          pdfFiles.addAll(result.files);
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Could not pick files: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removePdf(int index) => setState(() => pdfFiles.removeAt(index));

  void reorderPdfs(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final file = pdfFiles.removeAt(oldIndex);
      pdfFiles.insert(newIndex, file);
    });
  }

  void _showFileNameDialog() {
    if (pdfFiles.length < 2) {
      Get.snackbar("Alert", "Select at least 2 PDFs to merge", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final TextEditingController nameController = TextEditingController();

    Get.defaultDialog(
      title: "Save PDF As",
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(16),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: "File Name",
          hintText: "e.g. MyMergedDoc",
          suffixText: ".pdf",
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: "Merge & Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        final name = nameController.text.trim();
        if (name.isNotEmpty) {
          Get.back();

          final fileName = name.endsWith('.pdf') ? name : '$name.pdf';
          mergeAndDownload(fileName);
        } else {
          Get.snackbar("Error", "Please enter a file name");
        }
      },
    );
  }

  Future<void> mergeAndDownload(String customFileName) async {
    setState(() => isMerging = true);

    final List<PdfDocument> documentsToDispose = [];
    final PdfDocument outputDocument = PdfDocument();

    try {
      for (var file in pdfFiles) {
        final File inputPdfFile = File(file.path!);
        final List<int> bytes = await inputPdfFile.readAsBytes();

        final PdfDocument loadedDocument = PdfDocument(inputBytes: bytes);
        documentsToDispose.add(loadedDocument);

        for (int i = 0; i < loadedDocument.pages.count; i++) {
          final PdfPage inputPage = loadedDocument.pages[i];
          final Size pageSize = inputPage.size;

          final PdfTemplate template = inputPage.createTemplate();

          final PdfSection section = outputDocument.sections!.add();

          section.pageSettings.size = pageSize;
          section.pageSettings.margins.all = 0;

          if (pageSize.width > pageSize.height) {
            section.pageSettings.orientation = PdfPageOrientation.landscape;
          } else {
            section.pageSettings.orientation = PdfPageOrientation.portrait;
          }

          final PdfPage newPage = section.pages.add();

          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), Size(pageSize.width, pageSize.height));
        }
      }

      final List<int> mergedBytes = await outputDocument.save();

      final directory = await getTemporaryDirectory();
      final outputPath = '${directory.path}/$customFileName';

      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(mergedBytes);

      await Share.shareXFiles(
        [XFile(outputPath, name: customFileName)],
        text: 'Here is your merged PDF!',
        subject: customFileName,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to merge: $e", snackPosition: SnackPosition.BOTTOM);
      debugPrint("Merge Error: $e");
    } finally {
      outputDocument.dispose();
      for (var doc in documentsToDispose) {
        doc.dispose();
      }
      if (mounted) setState(() => isMerging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isMerging ? null : _showFileNameDialog,
        icon:
            isMerging
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                : const Icon(Icons.download),
        label: Text(isMerging ? "Merging..." : "Merge & Save"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              CommonPageHeader(
                mainHeading: "PDFs",
                subHeading: "Merge PDFs",
                onTap: () => Get.back(),
                icon: Icons.chevron_left_rounded,
              ),
              const SizedBox(height: 10),

              OutlinedButton.icon(onPressed: pickPdfs, icon: const Icon(Icons.add), label: const Text("Add PDF Files")),

              const SizedBox(height: 20),

              Expanded(
                child:
                    pdfFiles.isEmpty
                        ? const Center(
                          child: Text("No PDFs selected", style: TextStyle(fontSize: 16, color: Colors.grey)),
                        )
                        : ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: pdfFiles.length,
                          onReorder: reorderPdfs,
                          itemBuilder: (context, index) {
                            final file = pdfFiles[index];
                            return Card(
                              key: ValueKey(file.path ?? "${file.name}_$index"),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              child: ListTile(
                                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                title: Text(path.basename(file.name), overflow: TextOverflow.ellipsis),
                                subtitle: Text("${(file.size / 1024).toStringAsFixed(1)} KB"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => removePdf(index),
                                    ),
                                    const Icon(Icons.drag_handle, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
