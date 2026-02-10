import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'client_payment_details_create_screen.dart';
import 'client_payment_create_screen.dart';
import 'services.dart';

class ListClientPaymentsScreen extends StatefulWidget {
  const ListClientPaymentsScreen({super.key});

  @override
  State<ListClientPaymentsScreen> createState() =>
      _ListClientPaymentsScreenState();
}

class _ListClientPaymentsScreenState
    extends State<ListClientPaymentsScreen> {
  bool loading = true;
  String filter = "all"; // all | paid | unpaid
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    invoices = await PaymentService.getInvoices();
    if (mounted) setState(() => loading = false);
  }

  List<Map<String, dynamic>> get filtered {
    if (filter == "all") return invoices;
    return invoices.where((i) => i['status'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final inv = filtered[i];
                final isPaid = inv['status'] == "paid";

                return ListTile(
                  leading: Icon(
                    isPaid
                        ? Icons.check_circle
                        : Icons.pending,
                    color:
                    isPaid ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    inv['invoiceNumber'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "₹ ${inv['totalAmount']}",
                  ),
                  trailing: Text(
                    inv['status'].toUpperCase(),
                    style: TextStyle(
                      color: isPaid
                          ? Colors.green
                          : Colors.orange,
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
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? AppColors.darkBlue : Colors.grey,
        ),
      ),
    );
  }
}
