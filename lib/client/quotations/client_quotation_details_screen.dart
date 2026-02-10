import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../loi/client_loi_upload_screen.dart';
import '../payments/client_payment_screen.dart';
import 'services/services.dart';

class ClientQuotationDetailsScreen extends StatefulWidget {
  final String quotationId;

  const ClientQuotationDetailsScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<ClientQuotationDetailsScreen> createState() =>
      _ClientQuotationDetailsScreenState();
}

class _ClientQuotationDetailsScreenState
    extends State<ClientQuotationDetailsScreen> {
  bool loading = true;
  Map<String, dynamic>? data;

  int getStepIndex(String status) {
    if (status == "payment_done") return 2;
    if (status == "loi_sent") return 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    loadQuotation();
  }

  Future<void> loadQuotation() async {
    try {
      data = await QuotationService.getQuotationById(
        widget.quotationId,
      );
    } catch (e) {
      debugPrint("Quotation details error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("Quotation not found")),
      );
    }

    final status = data!['status'] ?? 'sent';
    final pricing = data!['pricing'] ?? {};
    final product = data!['product'] ?? {};
    final loi = data!['loi'];
    final amount = data!['quotationAmount'] ?? 0;
    final currentStep = getStepIndex(status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quotation Details"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTimeline(currentStep),
            const SizedBox(height: 20),

            buildCard(
              title: "Product Details",
              children: [
                buildRow("Product", product['title'] ?? "-"),
                buildRow("Quantity", "${pricing['quantity'] ?? '-'}"),
                buildRow(
                  "Expected Date",
                  data!['expectedDate']?.toString() ?? "-",
                ),
              ],
            ),

            buildCard(
              title: "Pricing Breakdown",
              children: [
                buildRow(
                  "Base Amount",
                  "₹ ${pricing['baseAmount'] ?? 0}",
                ),
                buildRow(
                  "Discount",
                  "${pricing['discountPercent'] ?? 0}%",
                ),
                buildRow(
                  "Extra Discount",
                  "₹ ${pricing['extraDiscount'] ?? 0}",
                ),
                buildRow(
                  "CGST",
                  "${pricing['cgstPercent'] ?? 0}%",
                ),
                buildRow(
                  "SGST",
                  "${pricing['sgstPercent'] ?? 0}%",
                ),
                const Divider(),
                buildRow(
                  "Final Amount",
                  "₹ $amount",
                  bold: true,
                ),
              ],
            ),

            buildCard(
              title: "Status",
              children: [
                buildRow("Current Status", status.toUpperCase()),
                if (loi != null)
                  buildRow(
                    "LOI Status",
                    loi['status']?.toString().toUpperCase() ?? "-",
                  ),
              ],
            ),

            const SizedBox(height: 20),

            if (status != "loi_sent" && status != "payment_done")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientLoiUploadScreen(
                          quotationId: widget.quotationId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "UPLOAD LOI",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            if (status == "loi_sent")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientPaymentScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "MAKE PAYMENT",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            if (status == "payment_done")
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    "Payment Completed ✅",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /* ================= TIMELINE ================= */

  Widget buildTimeline(int currentStep) {
    final steps = ["Quotation", "LOI", "Payment"];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final isActive = index ~/ 2 < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              color: isActive ? Colors.green : Colors.grey.shade300,
            ),
          );
        }

        final step = index ~/ 2;
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;

        Color color = Colors.grey;
        if (isCompleted) color = Colors.green;
        if (isCurrent) color = AppColors.primaryBlue;

        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                steps[step],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /* ================= UI HELPERS ================= */

  Widget buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget buildRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
