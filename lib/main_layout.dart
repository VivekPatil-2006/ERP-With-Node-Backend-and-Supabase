import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';

// ================= SALES MANAGER =================
import 'sales_manager/dashboard/sales_dashboard.dart';
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';
import 'sales_manager/clients/client_list_screen.dart';
import 'sales_manager/quotations/quotation_list_sales.dart';
import 'sales_manager/loi/loi_ack_screen.dart';
import 'sales_manager/invoices/invoice_home_screen.dart';
import 'sales_manager/profile/sales_profile_screen.dart';

// ================= CLIENT =================
import 'client/enquiries/client_enquiry_list_screen.dart';
import 'client/quotations/client_quotation_list_screen.dart';
import 'client/payments/client_payment_screen.dart';
import 'client/payments/list_client_payments_screen.dart';
import 'client/profile/client_profile_screen.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';

/// ================= ENUMS =================

enum SalesPage {
  dashboard,
  enquiries,
  clients,
  quotations,
  loi,
  invoices,
  profile,
}

enum ClientPage {
  enquiries,
  quotations,
  payments,
  invoices,
  profile,
}

/// ================= MAIN LAYOUT =================

class MainLayout extends StatefulWidget {
  final String role; // "sales_manager" | "client"

  const MainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  SalesPage salesPage = SalesPage.dashboard;
  ClientPage clientPage = ClientPage.enquiries;

  String get uid => auth.currentUser!.uid;

  // ================= BODY SWITCHER =================

  Widget _buildBody() {
    if (widget.role == 'sales_manager') {
      switch (salesPage) {
        case SalesPage.dashboard:
          return const SalesDashboard();
        case SalesPage.enquiries:
          return const SalesEnquiryListScreen();
        case SalesPage.clients:
          return const ClientListScreen();
        case SalesPage.quotations:
          return const QuotationListSales();
        case SalesPage.loi:
          return const LoiAckScreen();
        case SalesPage.invoices:
          return const InvoiceHomeScreen();
        case SalesPage.profile:
          return const SalesProfileScreen();
      }
    }

    // ================= CLIENT =================
    switch (clientPage) {
      case ClientPage.enquiries:
        return const ClientEnquiryListScreen();
      case ClientPage.quotations:
        return const ClientQuotationListScreen();
      case ClientPage.payments:
        return const ClientPaymentScreen();
      case ClientPage.invoices:
        return const ListClientPaymentsScreen();
      case ClientPage.profile:
        return ClientProfileScreen(clientId: uid);
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          widget.role == 'sales_manager' ? 'Sales Manager' : 'Client',
        ),
      ),

      body: _buildBody(),
    );
  }

  // ================= DRAWER =================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkBlue,
      child: Column(
        children: [
          _buildProfileHeader(),

          if (widget.role == 'sales_manager') ...[
            _menu('Dashboard', Icons.dashboard,
                    () => _selectSales(SalesPage.dashboard)),
            _menu('Enquiries', Icons.assignment,
                    () => _selectSales(SalesPage.enquiries)),
            _menu('Clients', Icons.people,
                    () => _selectSales(SalesPage.clients)),
            _menu('Quotations', Icons.description,
                    () => _selectSales(SalesPage.quotations)),
            _menu('LOI Approvals', Icons.verified,
                    () => _selectSales(SalesPage.loi)),
            _menu('Invoices', Icons.receipt_long,
                    () => _selectSales(SalesPage.invoices)),
            _menu('Profile', Icons.person,
                    () => _selectSales(SalesPage.profile)),
          ],

          if (widget.role == 'client') ...[
            _menu('Enquiries', Icons.assignment,
                    () => _selectClient(ClientPage.enquiries)),
            _menu('Quotations', Icons.description,
                    () => _selectClient(ClientPage.quotations)),
            _menu('Payments', Icons.payment,
                    () => _selectClient(ClientPage.payments)),
            _menu('Invoices', Icons.receipt_long,
                    () => _selectClient(ClientPage.invoices)),
            _menu('Profile', Icons.person,
                    () => _selectClient(ClientPage.profile)),
          ],

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _buildProfileHeader() {
    final email = auth.currentUser?.email ?? '';

    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.navy),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Icon(
              widget.role == 'sales_manager'
                  ? Icons.person
                  : Icons.business,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            widget.role == 'sales_manager' ? 'Sales Manager' : 'Client',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  void _selectSales(SalesPage page) {
    Navigator.pop(context);
    setState(() => salesPage = page);
  }

  void _selectClient(ClientPage page) {
    Navigator.pop(context);
    setState(() => clientPage = page);
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (_) => false,
    );
  }

  Widget _menu(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonBlue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
