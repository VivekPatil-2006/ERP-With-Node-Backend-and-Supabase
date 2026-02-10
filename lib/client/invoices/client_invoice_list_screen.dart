import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/pdf/pdf_utils.dart';
import '../../core/theme/app_colors.dart';
import 'services.dart';

class ClientInvoiceListScreen extends StatefulWidget {
  const ClientInvoiceListScreen({super.key});

  @override
  State<ClientInvoiceListScreen> createState() =>
      _ClientInvoiceListScreenState();
}

class _ClientInvoiceListScreenState
    extends State<ClientInvoiceListScreen> {

  bool loading = true;
  List<dynamic> invoices = [];

  String searchText = "";
  String filterStatus = "all";

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  // ================= LOAD INVOICES =================
  Future<void> loadInvoices() async {
    try {
      invoices = await InvoiceService.getInvoices();
    } catch (e) {
      debugPrint("Invoice load error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= FILTER LOGIC =================
  bool filterInvoice(Map<String, dynamic> data) {

    final paymentStatus =
    (data['paymentStatus'] ?? "").toString().toLowerCase();

    final createdAt = data['createdAt'];

    final dateText = createdAt != null
        ? DateFormat.yMMMd()
        .format(DateTime.parse(createdAt))
        : "";

    final matchSearch =
    dateText.toLowerCase().contains(searchText.toLowerCase());

    final matchStatus =
        filterStatus == "all" || paymentStatus == filterStatus;

    return matchSearch && matchStatus;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Invoices",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [

          // ================= SEARCH + FILTER =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by date",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() => searchText = val);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem(
                        value: "all", child: Text("All")),
                    DropdownMenuItem(
                        value: "paid", child: Text("Paid")),
                    DropdownMenuItem(
                        value: "unpaid", child: Text("Unpaid")),
                  ],
                  onChanged: (val) {
                    setState(() => filterStatus = val!);
                  },
                ),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : invoices.isEmpty
                ? const Center(
              child: Text("No invoices available"),
            )
                : buildInvoiceList(),
          ),
        ],
      ),
    );
  }

  Widget buildInvoiceList() {

    final filtered = invoices
        .where((inv) => filterInvoice(inv))
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No matching invoices"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {

        final data = filtered[index];

        final String paymentStatus =
        (data['paymentStatus'] ?? "").toLowerCase();

        final String pdfUrl = data['pdfUrl'] ?? "";

        final createdAt = data['createdAt'];

        return Card(
          margin: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          child: ListTile(

            leading: Icon(
              Icons.receipt_long,
              color: paymentStatus == "paid"
                  ? Colors.green
                  : Colors.orange,
            ),

            title: Text(
              "Invoice #${data['invoiceNumber'] ?? data['id']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (createdAt != null)
                  Text(
                    DateFormat.yMMMd()
                        .format(DateTime.parse(createdAt)),
                  ),

                const SizedBox(height: 4),

                Text(
                  paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: paymentStatus == "paid"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                  tooltip: "View Invoice",
                  icon: const Icon(Icons.visibility),
                  onPressed: pdfUrl.isEmpty
                      ? null
                      : () {
                    PdfUtils.openPdf(pdfUrl);
                  },
                ),

                IconButton(
                  tooltip: "Download Invoice",
                  icon: const Icon(Icons.download),
                  onPressed: pdfUrl.isEmpty
                      ? null
                      : () async {
                    await PdfUtils.downloadPdf(
                      url: pdfUrl,
                      fileName:
                      "Invoice_${data['id']}",
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
