import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import 'services.dart';

class ClientPaymentCreateScreen extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const ClientPaymentCreateScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<ClientPaymentCreateScreen> createState() =>
      _ClientPaymentCreateScreenState();
}

class _ClientPaymentCreateScreenState
    extends State<ClientPaymentCreateScreen> {
  File? proof;
  bool loading = false;

  // ================= PICK PROOF =================

  Future<void> pickProof() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => proof = File(picked.path));
    }
  }

  // ================= SUBMIT PAYMENT =================

  Future<void> submit() async {
    if (proof == null) {
      showMsg("Upload payment proof");
      return;
    }

    try {
      setState(() => loading = true);

      final url = await CloudinaryService().uploadFile(proof!);

      await PaymentService.createPayment(
        amount: widget.invoice['totalAmount'].toDouble(),
        clientId: widget.invoice['clientId'],
        companyId: widget.invoice['companyId'],
        invoiceId: widget.invoice['id'],
        quotationId: widget.invoice['quotationId'],
        paymentMode: "upi",
        paymentType: "online",
        phase: "final",
        invoicePdfUrl: url,
      );

      if (!mounted) return;

      showMsg("Payment Successful ✅");
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Payment error => $e");
      showMsg("Payment failed");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Payment"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: loading ? null : submit,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            "SUBMIT PAYMENT",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(
              title: "Invoice Summary",
              icon: Icons.receipt_long,
              child: Column(
                children: [
                  infoRow(
                    "Invoice No",
                    widget.invoice['invoiceNumber'],
                  ),
                  infoRow(
                    "Amount",
                    "₹ ${widget.invoice['totalAmount']}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            buildCard(
              title: "Payment Proof",
              icon: Icons.upload_file,
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: pickProof,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Proof"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        proof == null
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: proof == null
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        proof == null
                            ? "No file selected"
                            : "Proof uploaded",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
