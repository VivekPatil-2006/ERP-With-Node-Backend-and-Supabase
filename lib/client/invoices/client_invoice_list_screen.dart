import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/client_drawer.dart';
import '../payments/client_payment_create_screen.dart';
import '../payments/client_payment_details_create_screen.dart';
import '../payments/services.dart';

class ClientInvoiceListScreen extends StatefulWidget {
  const ClientInvoiceListScreen({super.key});

  @override
  State<ClientInvoiceListScreen> createState() =>
      _ClientInvoiceListScreenState();
}

class _ClientInvoiceListScreenState
    extends State<ClientInvoiceListScreen> {
  bool loading = true;
  String filter = "all"; // all | paid | unpaid
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      invoices = await PaymentService.getInvoices();
    } catch (e) {
      debugPrint("Invoice load error: $e");
      invoices = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (filter == "all") return invoices;
    return invoices.where((i) => i['status'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      // ✅ DRAWER ADDED
      drawer: const ClientDrawer(
        currentRoute: '/clientInvoices',
      ),

      appBar: AppBar(
        title: const Text(
          "Invoices",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 10),
            buildFilters(),
            const Divider(),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                child: Text("No invoices found"),
              )
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final inv = filtered[i];
                  final isPaid =
                      inv['status'] == "paid";

                  return ListTile(
                    leading: Icon(
                      isPaid
                          ? Icons.check_circle
                          : Icons.pending,
                      color: isPaid
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(
                      inv['invoiceNumber'],
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.bold),
                    ),
                    subtitle: Text(
                      "₹ ${inv['totalAmount']}",
                    ),
                    trailing: Text(
                      inv['status']
                          .toUpperCase(),
                      style: TextStyle(
                        color: isPaid
                            ? Colors.green
                            : Colors.orange,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isPaid
                              ? ClientPaymentDetailsScreen(
                            invoice: inv,
                          )
                              : ClientPaymentCreateScreen(
                            invoice: inv,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        filterBtn("ALL", "all"),
        filterBtn("PAID", "paid"),
        filterBtn("PENDING", "unpaid"),
      ],
    );
  }

  Widget filterBtn(String label, String value) {
    final active = filter == value;

    return TextButton(
      onPressed: () => setState(() => filter = value),
      child: Text(
        label,
        style: TextStyle(
          fontWeight:
          active ? FontWeight.bold : FontWeight.normal,
          color:
          active ? AppColors.darkBlue : Colors.grey,
        ),
      ),
    );
  }
}
