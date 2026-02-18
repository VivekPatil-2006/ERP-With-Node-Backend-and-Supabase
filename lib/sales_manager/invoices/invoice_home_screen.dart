import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared_widgets/sales_drawer.dart';
import 'invoice_list_screen.dart';

class InvoiceHomeScreen extends StatelessWidget {
  const InvoiceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SalesDrawer(currentRoute: '/salesInvoices'),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          SalesDrawer.getTitle('/salesInvoices'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: const InvoiceListScreen(),
    );
  }
}
