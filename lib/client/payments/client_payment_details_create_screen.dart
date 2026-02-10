import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ClientPaymentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const ClientPaymentDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(
              title: "Invoice Information",
              icon: Icons.receipt_long,
              children: [
                infoRow("Invoice No", invoice['invoiceNumber']),
                infoRow(
                  "Amount",
                  "₹ ${invoice['totalAmount']}",
                ),
                infoRow(
                  "Status",
                  invoice['status'].toUpperCase(),
                  valueColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            buildCard(
              title: "Payment Status",
              icon: Icons.check_circle,
              children: const [
                SizedBox(height: 10),
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
                SizedBox(height: 12),
                Text(
                  "Payment Completed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget infoRow(
      String label,
      String value, {
        Color? valueColor,
      }) {
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
