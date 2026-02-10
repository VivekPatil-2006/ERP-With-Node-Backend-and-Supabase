import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/services/notification_service.dart';
import 'services/services.dart';

class LoiUploadScreen extends StatefulWidget {
  final String quotationId;
  final String salesManagerId;

  const LoiUploadScreen({
    super.key,
    required this.quotationId,
    required this.salesManagerId,
  });

  @override
  State<LoiUploadScreen> createState() => _LoiUploadScreenState();
}

class _LoiUploadScreenState extends State<LoiUploadScreen> {

  File? file;
  bool loading = false;

  // ================= PICK FILE =================
  Future<void> pickFile() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  // ================= UPLOAD LOI =================
  Future<void> uploadLoi() async {

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select LOI file")),
      );
      return;
    }

    try {
      setState(() => loading = true);

      // ================= UPLOAD FILE =================
      final attachmentUrl =
      await CloudinaryService().uploadFile(file!);

      final fileType =
      file!.path.endsWith(".pdf") ? "pdf" : "image";

      // ================= CREATE / UPDATE LOI =================
      await LoiService.createOrUpdateLoi(
        quotationId: widget.quotationId,
        attachmentUrl: attachmentUrl,
        fileType: fileType,
        status: "pending",
      );

      // ================= UPDATE QUOTATION =================
      await LoiService.updateQuotationStatus(
        quotationId: widget.quotationId,
        status: "loi_sent",
      );

      // ================= NOTIFY SALES MANAGER =================
      // await NotificationService().sendNotification(
      //   userId: widget.salesManagerId,
      //   role: "sales_manager",
      //   title: "LOI Received",
      //   message: "Client uploaded LOI document",
      //   type: "loi",
      //   referenceId: widget.quotationId,
      // );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("LOI Uploaded Successfully")),
      );

      Navigator.pop(context);

    } catch (e) {

      debugPrint("LOI Upload Error => $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload LOI")),
        );
      }

    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload LOI"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Select LOI File"),
              onPressed: loading ? null : pickFile,
            ),

            const SizedBox(height: 10),

            file == null
                ? const Text("No file selected")
                : Text(
              "Selected: ${file!.path.split('/').last}",
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : uploadLoi,
                child: loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("SUBMIT LOI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
