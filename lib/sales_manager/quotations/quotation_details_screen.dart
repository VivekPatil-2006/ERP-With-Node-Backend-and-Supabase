// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/theme/app_colors.dart';
//
// class QuotationDetailsScreen extends StatelessWidget {
//
//   final String quotationId;
//   final String clientId;
//   final String productId;
//
//   const QuotationDetailsScreen({
//     super.key,
//     required this.quotationId,
//     required this.clientId,
//     required this.productId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "Quotation Details",
//           style: TextStyle(
//             fontWeight: FontWeight.bold, // ✅ bold title
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white, // ✅ affects title + back arrow
//       ),
//
//
//       body: FutureBuilder<DocumentSnapshot>(
//
//         future: FirebaseFirestore.instance
//             .collection("quotations")
//             .doc(quotationId)
//             .get(),
//
//         builder: (context, snapshot) {
//
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.data!.exists) {
//             return const Center(child: Text("Quotation not found"));
//           }
//
//           final data =
//           snapshot.data!.data() as Map<String, dynamic>;
//
//           final productSnapshot =
//               data['productSnapshot'] ?? {};
//
//           final status =
//               data['status'] ?? "sent";
//
//           final amount =
//               data['quotationAmount'] ?? 0;
//
//           return SingleChildScrollView(
//
//             padding: const EdgeInsets.all(16),
//
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 section("Quotation Info"),
//
//                 info("Quotation ID", quotationId),
//                 info("Status", status.toUpperCase()),
//                 info("Final Amount", "₹ $amount"),
//
//                 const Divider(height: 30),
//
//                 section("Product Info"),
//
//                 info("Product Name",
//                     productSnapshot['productName']),
//
//                 info("Quantity",
//                     productSnapshot['quantity']),
//
//                 info("Base Price",
//                     productSnapshot['basePrice']),
//
//                 info("Discount %",
//                     productSnapshot['discountPercent']),
//
//                 info("Extra Discount %",
//                     productSnapshot['extraDiscountPercent']),
//
//                 info("CGST %",
//                     productSnapshot['cgstPercent']),
//
//                 info("SGST %",
//                     productSnapshot['sgstPercent']),
//
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ================= UI HELPERS =================
//
//   Widget section(String title) {
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }
//
//   Widget info(String label, dynamic value) {
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//
//       child: Row(
//         children: [
//
//           SizedBox(
//             width: 140,
//             child: Text(
//               "$label:",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//
//           Expanded(
//             child: Text(
//               value?.toString() ?? "-",
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'services/quotation_service.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final String quotationId;

  const QuotationDetailsScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<QuotationDetailsScreen> createState() =>
      _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState
    extends State<QuotationDetailsScreen> {
  bool loading = true;
  Map<String, dynamic>? quotation;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  // =============================
  // LOAD QUOTATION DETAILS
  // =============================

  Future<void> loadDetails() async {
    try {
      quotation = await QuotationService()
          .getQuotationById(widget.quotationId);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricing =
    quotation?['pricing'] as Map<String, dynamic>?;

    final createdAt = quotation?['createdAt'] != null
        ? DateTime.tryParse(quotation!['createdAt'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quotation Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : quotation == null
          ? const Center(child: Text("Quotation not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= QUOTATION INFO =================
            buildCard(
              title: "Quotation Info",
              child: Column(
                children: [
                  infoRow(
                    "Quotation ID",
                    quotation!['quotationId'],
                  ),
                  infoRow(
                    "Created At",
                    createdAt != null
                        ? DateFormat.yMMMd()
                        .add_jm()
                        .format(createdAt)
                        : "-",
                  ),
                  const SizedBox(height: 10),
                  buildStatusChip(
                      quotation!['status']),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= PRICING DETAILS =================
            buildCard(
              title: "Pricing Breakdown",
              child: Column(
                children: [
                  infoRow(
                    "Base Amount",
                    "₹ ${pricing?['baseAmount']}",
                  ),
                  infoRow(
                    "Quantity",
                    pricing?['quantity']?.toString(),
                  ),
                  infoRow(
                    "Discount %",
                    "${pricing?['discountPercent']} %",
                  ),
                  infoRow(
                    "Extra Discount",
                    "₹ ${pricing?['extraDiscount']}",
                  ),
                  infoRow(
                    "CGST %",
                    "${pricing?['cgstPercent']} %",
                  ),
                  infoRow(
                    "SGST %",
                    "${pricing?['sgstPercent']} %",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= FINAL AMOUNT =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                  AppColors.darkBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Final Amount",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹ ${pricing?['totalAmount']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
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
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String? status) {
    Color bg;
    Color fg;

    switch (status) {
      case "approved":
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green;
        break;
      case "rejected":
        bg = Colors.red.withOpacity(0.15);
        fg = Colors.red;
        break;
      default:
        bg = Colors.orange.withOpacity(0.15);
        fg = Colors.orange;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          status?.toUpperCase() ?? "-",
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: bg,
        side: BorderSide(color: fg),
      ),
    );
  }
}
