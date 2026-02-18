import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/client_drawer.dart';
import 'client_quotation_details_screen.dart';
import 'services/services.dart';

class ClientQuotationListScreen extends StatefulWidget {
  const ClientQuotationListScreen({super.key});

  @override
  State<ClientQuotationListScreen> createState() =>
      _ClientQuotationListScreenState();
}

class _ClientQuotationListScreenState
    extends State<ClientQuotationListScreen> {
  bool loading = true;
  List<Map<String, dynamic>> quotations = [];

  @override
  void initState() {
    super.initState();
    loadQuotations();
  }

  Future<void> loadQuotations() async {
    try {
      quotations = await QuotationService.getMyQuotations();
    } catch (e) {
      debugPrint("Load quotations error: $e");
      quotations = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "loi_sent":
        return Colors.orange;
      case "payment_done":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget statusChip(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      // ================= DRAWER =================
      drawer: const ClientDrawer(
        currentRoute: '/clientQuotations',
      ),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          "My Quotations",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ================= BODY =================
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : quotations.isEmpty
          ? const Center(
        child: Text(
          "No quotations yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          setState(() => loading = true);
          await loadQuotations();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: quotations.length,
          itemBuilder: (context, index) {
            final q = quotations[index];

            final double amount =
            (q['quotationAmount'] ?? 0).toDouble();
            final String status = q['status'] ?? '';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ClientQuotationDetailsScreen(
                          quotationId: q['id'],
                        ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color:
                      Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                      getStatusColor(status)
                          .withOpacity(0.15),
                      child: Icon(
                        Icons.description,
                        color:
                        getStatusColor(status),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₹ ${amount.toStringAsFixed(2)}",
                            style:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            q['enquiryTitle']
                                ?.toString()
                                .isNotEmpty ==
                                true
                                ? q['enquiryTitle']
                                : "Quotation Amount",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    statusChip(status),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
