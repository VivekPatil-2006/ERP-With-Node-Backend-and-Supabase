import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import '../shared_widgets/client_drawer.dart';
import 'services.dart';

class ClientPaymentScreen extends StatefulWidget {
  const ClientPaymentScreen({super.key});

  @override
  State<ClientPaymentScreen> createState() =>
      _ClientPaymentScreenState();
}

class _ClientPaymentScreenState
    extends State<ClientPaymentScreen> {

  String? selectedInvoiceId;
  Map<String, dynamic>? selectedInvoice;

  String phase = "phase1";
  String paymentMode = "upi";

  final amountCtrl = TextEditingController();
  File? proofFile;

  bool loading = false;
  bool invoiceLoading = true;
  List<dynamic> invoices = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  // ================= LOAD INVOICES =================
  Future<void> loadInvoices() async {
    try {
      invoices = await PaymentService.getInvoices();
    } catch (e) {
      debugPrint("Invoice load error: $e");
    } finally {
      if (mounted) setState(() => invoiceLoading = false);
    }
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => proofFile = File(picked.path));
    }
  }

  // ================= SUBMIT PAYMENT =================
  Future<void> submitPayment() async {
    if (proofFile == null ||
        selectedInvoice == null ||
        selectedInvoiceId == null ||
        amountCtrl.text.isEmpty) {
      showMsg("Complete all fields");
      return;
    }

    try {
      setState(() => loading = true);

      final proofUrl =
      await CloudinaryService().uploadFile(proofFile!);

      final paymentType =
      (paymentMode == "upi" || paymentMode == "net_banking")
          ? "online"
          : "offline";

      final amount =
          double.tryParse(amountCtrl.text) ?? 0;

      await PaymentService.createPayment(
        amount: amount,
        clientId: selectedInvoice!['clientId'],
        companyId: selectedInvoice!['companyId'],
        invoiceId: selectedInvoiceId!,
        quotationId: selectedInvoice!['quotationId'],
        paymentMode: paymentMode,
        paymentType: paymentType,
        phase: phase,
        invoicePdfUrl: proofUrl,
      );

      showMsg("Payment Successful ✅");
      Navigator.pop(context);

    } catch (e) {
      debugPrint("Payment Error => $e");
      showMsg("Payment Failed");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      // ✅ DRAWER ADDED
      drawer: const ClientDrawer(
        currentRoute: '/clientPayments',
      ),

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          "Make Payment",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: loading ? null : submitPayment,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SUBMIT PAYMENT"),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            buildCard(
              title: "Invoice Selection",
              icon: Icons.receipt_long,
              child: buildInvoiceDropdown(),
            ),

            const SizedBox(height: 16),

            buildCard(
              title: "Payment Details",
              icon: Icons.payment,
              child: Column(
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildPhaseDropdown(),
                  const SizedBox(height: 12),
                  buildModeDropdown(),
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
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Proof"),
                    onPressed: pickImage,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        proofFile == null
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: proofFile == null
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        proofFile == null
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

  // ================= INVOICE DROPDOWN =================
  Widget buildInvoiceDropdown() {

    if (invoiceLoading) {
      return const CircularProgressIndicator();
    }

    if (invoices.isEmpty) {
      return const Text("No pending invoices");
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedInvoiceId,
      decoration: const InputDecoration(
        labelText: "Select Invoice",
        border: OutlineInputBorder(),
      ),
      items: invoices.map((inv) {
        return DropdownMenuItem<String>(
          value: inv['id'],
          child: Text(
            "${inv['invoiceNumber']}  |  ₹${inv['totalAmount']}",
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val == null) return;
        final inv =
        invoices.firstWhere((i) => i['id'] == val);
        setState(() {
          selectedInvoiceId = val;
          selectedInvoice = inv;
          amountCtrl.text = inv['totalAmount'].toString();
        });
      },
    );
  }

  Widget buildPhaseDropdown() {
    return DropdownButtonFormField<String>(
      value: phase,
      decoration: const InputDecoration(
        labelText: "Payment Phase",
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: "phase1", child: Text("Advance")),
        DropdownMenuItem(value: "phase2", child: Text("Interim")),
        DropdownMenuItem(value: "phase3", child: Text("Final")),
      ],
      onChanged: (val) => setState(() => phase = val!),
    );
  }

  Widget buildModeDropdown() {
    return DropdownButtonFormField<String>(
      value: paymentMode,
      decoration: const InputDecoration(
        labelText: "Payment Mode",
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: "upi", child: Text("UPI")),
        DropdownMenuItem(value: "net_banking", child: Text("Net Banking")),
        DropdownMenuItem(value: "cash", child: Text("Cash")),
        DropdownMenuItem(value: "cheque", child: Text("Cheque")),
      ],
      onChanged: (val) => setState(() => paymentMode = val!),
    );
  }

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
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }
}
